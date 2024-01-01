//
//  MapView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/9/23.
//

import SwiftUI
import MapKit
import Combine

struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var dataService = DataService.shared
    
    @State private var mapFeature : UUID?
    @State private var isSelected: Bool = false
    @State private var isSheetPresented: Bool = false
    
    @ViewBuilder
    var searchList: some View {
        if locationManager.shouldShow, !locationManager.search.isEmpty {
            List {
                ForEach(locationManager.searchResults, id:\.self) { result in
                    VStack(alignment: .leading, spacing: 0) {
                        SearchCompleterLabelView(searchResult: result, locVM: locationManager)
                    }
                    .onTapGesture {
                        isSelected = false
                        locationManager.search(result)
                        locationManager.shouldShow = false
                    }
                }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        } else {
            EmptyView()
        }
    }
    
    var map: some View {
        Map(position: $locationManager.cameraPosition.animation(), selection:$mapFeature) {
            ForEach($dataService.currentPosts) { $post in
                if let latitude = post.latitude, let longitude = post.longitude {
                    Marker(post.title, coordinate: .init(latitude: latitude, longitude: longitude))
                        .tag(post.id)
                }
            }
            
            ForEach($locationManager.list) { $poi in
                Marker(poi.name, coordinate: poi.coordinate)
            }
            
            Annotation("My Home", coordinate: .init(latitude: 40.74800852005587, longitude: -73.94445404565252)) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.yellow)
                    Text("🏠")
                        .padding(5)
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd, { context in
            
            let newCameraPosition = MapCameraPosition.camera(context.camera)
            if newCameraPosition != locationManager.userCameraPosition {
                locationManager.userCameraPosition = newCameraPosition
                
                locationManager.locationService.region = .init(context.rect)
                locationManager.region = .init(context.rect)
            }
        })
        .mapFeatureSelectionDisabled { _ in false }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapUserLocationButton()
        }
        .mapControlVisibility(.visible)
        .onChange(of: mapFeature) {
            withAnimation {
                isSelected = false
                locationManager.focusOn(mapFeature)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                map
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                VStack {
                    searchList
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AddPostButton(onTap: {
                            isSelected = false
                            isSheetPresented = true
                        })
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                }
            }
        }
        .searchable(text: $locationManager.search, isPresented: $isSelected)
        .sheet(isPresented: $isSheetPresented) {
            InfoSheet(sheetPresented: $isSheetPresented)
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var shouldShow: Bool = false
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.automatic
    var userCameraPosition = MapCameraPosition.automatic
    
    @Published var list: [POI] = [
//        .init(name: "Empire State Building", coordinate: .init(latitude: 40.748817, longitude: -73.985428)),
//        .init(name: "Times Square", coordinate: .init(latitude: 40.758896, longitude: -73.985130))
    ]
    
    let manager = SharedLocationManager.shared
    var currentLocation: CLLocation?
    @Published var region: MKCoordinateRegion?
    @Published var location: CLLocationCoordinate2D?
    @Published var name: String = ""
    @Published var search: String = ""

    @Published var searchResults = [MKLocalSearchCompletion]()
    var publisher: AnyCancellable?
    var cancellables = Set<AnyCancellable>()
    
    let locationService: LocationSearchService = LocationSearchService()

    override init() {
        super.init()
        manager.locationPublisher
            .compactMap { $0 }
            .sink { error in
                // do nothing
            } receiveValue: { [weak self] location in
                guard let self else { return }
                self.currentLocation = location
                self.updateRegionIfNecessary()
            }
            .store(in: &cancellables)

        locationService.publisher.sink { error in
            // do nothing
        } receiveValue: { [weak self] completions in
            guard let self else { return }
            if completions.count < 5 {
                self.searchResults = completions
            } else {
                self.searchResults = Array(completions[0...4])
            }
        }
        .store(in: &cancellables)

//        searchCompleter.delegate = self
//        searchCompleter.region = self.region
//
        self.publisher = $search
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .filter { !$0.isEmpty }
            .sink(receiveValue: { [weak self] (str) in
//                self?.searchCompleter.queryFragment = str
                self?.locationService.search(query: str)
                self?.shouldShow = true
        })
    }
    
    private func updateRegionIfNecessary() {
        guard region == nil else { return }
        guard let location = self.currentLocation else { return }
        let newRegion = MKCoordinateRegion(center: .init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 500, longitudinalMeters: 500)
        region = newRegion
        if locationService.region == nil {
            locationService.prepareSearch(region: newRegion, resultTypes: [.address, .pointOfInterest])
        }
    }
    
    func focusOn(_ id: UUID?) {
        guard let id else { return }
        if let coordinate = list.filter({ poi in
            return poi.id == id
        }).first?.coordinate {
            cameraPosition = .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        }
    }
    
    func search(_ text: MKLocalSearchCompletion) {
        guard let region else { return }
        search = ""
        let searchRequest = MKLocalSearch.Request(completion: text)
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = region
        
        // Include only point-of-interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .pointOfInterest
        
        let localSearch = MKLocalSearch(request: searchRequest)
        DispatchQueue.global().async {
            localSearch.start { [unowned self] (response, error) in
                guard error == nil else {
                    //                self.displaySearchError(error)
                    return
                }
                
                if let item = response?.mapItems.first, let region = response?.boundingRegion {
                    self.list.removeAll()
                    self.list.append(.init(name: item.name ?? "Result", coordinate: .init(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)))
                    
                    self.cameraPosition = MapCameraPosition.region(region)
                    //                MapCameraPosition.item(item, allowsAutomaticPitch: true)
                }
            }
        }
    }
}

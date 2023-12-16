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
    @State private var mapFeature : UUID?
    @State private var isSelected: Bool = false
    
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
            .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        } else {
            EmptyView()
        }
    }
    
    var map: some View {
        Map(position: $locationManager.cameraPosition.animation(), selection:$mapFeature) {
            ForEach(locationManager.list) { poi in
                Marker(poi.name, coordinate: poi.coordinate)
                    .tint(.orange)
                    .tag(poi.id)
                
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
                
                locationManager.searchCompleter.region = .init(context.rect)
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
                    .ignoresSafeArea(.all, edges: .bottom)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AddPostButton(onTap: {
                            isSelected = false
                            print(locationManager.cameraPosition.camera?.centerCoordinate)
                            print(locationManager.cameraPosition.camera?.distance)
                        })
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                }
            }
        }
        .searchable(text: $locationManager.search, isPresented: $isSelected)
        .searchSuggestions {
            searchList
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    
    @Published var shouldShow: Bool = false
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.automatic
    var userCameraPosition = MapCameraPosition.automatic
    
    @Published var list: [POI] = [
        .init(name: "Empire State Building", coordinate: .init(latitude: 40.748817, longitude: -73.985428)),
        .init(name: "Times Square", coordinate: .init(latitude: 40.758896, longitude: -73.985130))
    ]
    
    func focusOn(_ id: UUID?) {
        guard let id else { return }
        if let coordinate = list.filter({ poi in
            return poi.id == id
        }).first?.coordinate {
            cameraPosition = .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        }
    }
    
    func search(_ text: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request()
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = region
        searchRequest.naturalLanguageQuery = text.title
        
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
                    self.list.append(.init(name: item.name ?? "Result", coordinate: .init(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)))
                    
                    self.cameraPosition = MapCameraPosition.region(region)
                    //                MapCameraPosition.item(item, allowsAutomaticPitch: true)
                }
            }
        }
    }
    
    let manager = CLLocationManager()
    @Published var region: MKCoordinateRegion
    @Published var location: CLLocationCoordinate2D?
    @Published var name: String = ""
    @Published var search: String = ""

    @Published var searchResults = [MKLocalSearchCompletion]()
    var publisher: AnyCancellable?
    var searchCompleter = MKLocalSearchCompleter()

    override init() {
        let latitude = 0
        let longitude = 0
        self.region = MKCoordinateRegion(center:CLLocationCoordinate2D(latitude:
                                                                        CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), span:
                                            MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        super.init()
        manager.delegate = self
        searchCompleter.delegate = self
        searchCompleter.region = self.region

        self.publisher = $search
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (str) in
                self?.searchCompleter.queryFragment = str
                self?.shouldShow = true
        })
    }
    

    func requestLocation() {
        manager.requestLocation()
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        if completer.results.count < 5 {
            searchResults = completer.results
        } else {
            searchResults = Array(completer.results[0...4])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        searchCompleter.region = MKCoordinateRegion(center: .init(latitude: location?.longitude ?? 0, longitude: location?.latitude ?? 0), span: .init(latitudeDelta: 0.25, longitudeDelta: 0.25))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }
}

//#Preview {
//    MapView()
//}

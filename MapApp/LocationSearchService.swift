//
//  LocationSearchService.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/26/23.
//

import Foundation
import Combine
import MapKit

class LocationSearchService: NSObject {
    
    var publisher = PassthroughSubject<[MKLocalSearchCompletion], Error>()
    
    private var searchCompleter: MKLocalSearchCompleter
    
    var region: MKCoordinateRegion? = nil {
        willSet {
            if let newValue {
                searchCompleter.region = newValue
            }
        }
    }
    
    override init() {
        searchCompleter = MKLocalSearchCompleter()
        super.init()
        
        searchCompleter.delegate = self
    }
    
    func prepareSearch(
        region: MKCoordinateRegion,
        resultTypes: MKLocalSearchCompleter.ResultType?
    ) {
        if let types = resultTypes {
            searchCompleter.resultTypes = types
        }
        searchCompleter.region = region
        self.region = region
    }
    
    func search(
        query: String,
        region: MKCoordinateRegion? = nil,
        resultTypes: MKLocalSearchCompleter.ResultType? = nil
    ) {
        if let region {
            searchCompleter.region = region
        }
        if let resultTypes {
            searchCompleter.resultTypes = resultTypes
        }
        searchCompleter.queryFragment = query
    }
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        publisher.send(completer.results)
    }
}

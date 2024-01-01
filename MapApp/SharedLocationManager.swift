//
//  LocationManager.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/31/23.
//

import Foundation
import CoreLocation
import Combine

class SharedLocationManager: NSObject {
    
    static let shared = SharedLocationManager()
    
    private let manager = CLLocationManager()
    
    let locationPublisher = CurrentValueSubject<CLLocation?, Error>(nil)
    let permissionPublisher = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    func start() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.requestLocation()
    }
}

extension SharedLocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // Handle changes if location permissions
        permissionPublisher.send(status)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            locationPublisher.send(location)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        if error._code == CLError.Code.denied.rawValue {
            manager.stopUpdatingLocation()
        }
    }
}

//
//  LaunchDelegate.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/9/23.
//

import Foundation
import CoreLocation

class LaunchDelegate: NSObject {
    private let locationManager: CLLocationManager!
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
    }
    
    var hasInUseAuthorization: Bool {
        return locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LaunchDelegate: CLLocationManagerDelegate {
    
}

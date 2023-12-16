//
//  Models.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/11/23.
//

import Foundation
import MapKit

struct POI: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct ReportInfo {
    let title: String
    let subtitle: String?
    let timeInMinutes: Int
}

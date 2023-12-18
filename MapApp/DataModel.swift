//
//  DataModel.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/17/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestoreInternal

struct Post: Codable, Identifiable {
    var id = UUID()
    let title: String
    let isDummy: Bool
    let description: String?
    let longitude: Double?
    let latitude: Double?
    let imageUrl: String?
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

//
//  SearchListView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/11/23.
//

import Foundation
import SwiftUI
import MapKit

struct SearchCompleterLabelView: View {
    @State private var distance: String?
    let searchResult: MKLocalSearchCompletion
    @ObservedObject var locVM: LocationManager

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "pin")
                VStack(alignment: .leading, spacing: 10) {
                    Text(searchResult.title)
                    Text(searchResult.subtitle)
                    if let distance = distance {
                        Text(distance)
                    }
                }
            }
        }
    }
}

struct SearchCompleter: View {
    @ObservedObject var locVM: LocationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search..", text: $locVM.search)
                    .textFieldStyle(.roundedBorder)
                List(locVM.searchResults,id: \.self) {res in
                    VStack(alignment: .leading, spacing: 0) {
                        SearchCompleterLabelView(searchResult: res, locVM: locVM)
                    }
                    .onTapGesture {
                        locVM.name = res.title
//                        locVM.reverseUpdate()
                        dismiss()
                    }
                }
            }.padding()
                .navigationTitle(Text("Search For Place"))
        }
    }
}

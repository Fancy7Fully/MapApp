//
//  ContentView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/9/23.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Text(searchText)
            }
            .padding()
        }
    }
}

//#Preview {
//    ContentView()
//}

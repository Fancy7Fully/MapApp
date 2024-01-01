//
//  InfoSheet.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/25/23.
//

import SwiftUI

struct InfoSheet: View {
    
    var sheetPresented: Binding<Bool>
    
    let uuid1: UUID = UUID()
    let uuid2: UUID = UUID()
    
    @State var nameText: String = ""
    @State var descriptionText: String = ""
    @FocusState var isFocused: UUID?
    
    @ViewBuilder
    var blueRectangle: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.blue, lineWidth: 2)
    }
    
    var body: some View {
        VStack {
            Form {
                DynamicTextField(text: $nameText, suggestion:"Name", isFocused: _isFocused, identfiier: uuid1)
                DynamicTextField(text: $descriptionText, suggestion: "description", isFocused: _isFocused, identfiier: uuid2)
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isFocused = nil
                    }
                }
            }
            LocationField()
        }
    }
    
    init(sheetPresented: Binding<Bool>) {
        self.sheetPresented = sheetPresented
//        self.uuid = UUID()
        self.isFocused = nil
    }
}


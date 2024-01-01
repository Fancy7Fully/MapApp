//
//  DynamicTextField.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/25/23.
//

import SwiftUI

struct DynamicTextField: View {
    
    @FocusState var isFocused: UUID?
    
    let text: Binding<String>
    
    let suggestion: String
    
    let identifier: UUID
    
    let linelimit: Int
    
    @State var showStuffs: Bool = false
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text(suggestion)
                    .font(.footnote)
                    .opacity(showStuffs ? 1 : 0)
                
                TextField("", text: self.text, axis: .vertical)
                    .lineLimit(linelimit)
            }
            .padding(.horizontal)
            .overlay {
                if !showStuffs {
                    HStack {
                        Text(suggestion)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        isFocused = identifier
                    }
                }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 2)
        }
        .focused($isFocused, equals:identifier)
        .onChange(of: isFocused) { oldValue, newValue in
            if text.wrappedValue.count == 0, newValue == identifier || oldValue == identifier {
                
                withAnimation(.easeInOut) {
                    showStuffs.toggle()
                }
            }
        }
    }
    
    init(text: Binding<String>, suggestion: String, isFocused: FocusState<UUID?>, identfiier: UUID, linelimit: Int = 1) {
        self.text = text
        self.suggestion = suggestion
        self._isFocused = isFocused
        self.identifier = identfiier
        self.linelimit = linelimit
    }
}

struct LocationField: View {
    
    @State var text: String = ""
    @State var some: String = ""
    
    var body: some View {
        TextField("ss", text: $text)
            .searchable(text: $some)
            .searchSuggestions {
                Text("🍎 Apple").searchCompletion("apple")
                Text("🍐 Pear").searchCompletion("pear")
                Text("🍌 Banana").searchCompletion("banana")
            }
    }
}

//
//  AddPostButton.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/12/23.
//

import SwiftUI

struct AddPostButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var onTap: (() -> ())? = nil
    
    init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap
    }
    
    var body: some View {
        GeometryReader { proxy in
            Group {
                Circle()
                    .foregroundColor(.blue)
                    .shadow(color: colorScheme == .dark ? .white : .black, radius: proxy.size.width * 0.05, x: 2.5, y: 2.5)
                    .overlay {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: proxy.size.width * 0.5, height: proxy.size.width * 0.5)
                    }
            }
            .onTapGesture {
                onTap?()
            }
        }
    }
}

#Preview {
    AddPostButton()
}

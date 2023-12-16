//
//  AccountView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/16/23.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    var body: some View {
        VStack {
            Button {
                print(Auth.auth().currentUser?.email)
            } label: {
                Text("print email")
                    .foregroundStyle(.blue)
            }
            
            Button {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error)
                }
            } label: {
                Text("sign out")
                    .foregroundStyle(.blue)
            }
        }
    }
}

//
//  ResetPasswordView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/17/23.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn
import FirebaseAuth

struct ResetPasswordView: View {
    
    @State var email: String = ""
    @State var hasSentEmail: Bool = false
    @State var countDown: Int = 60
    @State var hasError: Bool = false
    
    func sendVerificationLink() {
        hasError = false
        Auth.auth().useAppLanguage()
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                hasError = true
                return
            }
            hasError = false
            hasSentEmail = true
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                countDown -= 1
                
                if countDown < 1 {
                    hasSentEmail = false
                    timer.invalidate()
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()
            Text("Please enter your account email address")
                .foregroundStyle(.black)
                .padding(.horizontal)
            TextField("Email", // how to create a secure text field
                      text: $email,
                      prompt: Text("Email").foregroundColor(.red))
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .foregroundColor(.black)
            .autocapitalization(.none)
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.blue, lineWidth: 2)
            }
            .padding(.horizontal)
            
            if hasError {
                Text("Something went wrong. Please check your email again.")
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            if hasSentEmail {
                Text("A password reset email has been sent. If you have not received it, you can send another one in \(countDown) seconds.")
                    .foregroundStyle(.black)
                    .padding(.horizontal)
            } else {
                EmptyView()
            }
            
            Spacer()
            Button {
                sendVerificationLink()
            } label: {
                Text("Send verification link")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
            .background(
                hasSentEmail ? .gray : .blue
            )
            .disabled(hasSentEmail)
            .cornerRadius(20)
            .padding()
        }
        .background(.white)
    }
}

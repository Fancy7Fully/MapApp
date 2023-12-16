//
//  SignInView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/13/23.
//

import SwiftUI

struct SignInView: View {
    
    private let delegate: AppDelegate
    
    @StateObject var model: Model
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
        _model = StateObject(wrappedValue:Model(appDelegate: delegate))
    }
    
    class Model: ObservableObject {
        let appDelegate: AppDelegate
        
        init(appDelegate: AppDelegate) {
            self.appDelegate = appDelegate
        }
        
        @Published var name: String = "" {
            didSet {
                if !name.isEmpty && !password.isEmpty {
                    isSignInButtonDisabled = false
                } else {
                    isSignInButtonDisabled = true
                }
            }
        }
        @Published var password: String = "" {
            didSet {
                if !name.isEmpty && !password.isEmpty {
                    isSignInButtonDisabled = false
                } else {
                    isSignInButtonDisabled = true
                }
            }
        }
        @Published var showPassword: Bool = false
        @Published var isSignInButtonDisabled = false
        
        func signIn() {
            appDelegate.userService.signIn(with: name, password: password)
        }
        
        func createUser() {
            appDelegate.userService.createUser(with: name, password: password)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()
            
            TextField("Name",
                      text: $model.name ,
                      prompt: Text("Login").foregroundColor(.blue)
            )
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.blue, lineWidth: 2)
            }
            .padding(.horizontal)
            .autocorrectionDisabled()

            HStack {
                Group {
                    if model.showPassword {
                        TextField("Password", // how to create a secure text field
                                  text: $model.password,
                                    prompt: Text("Password").foregroundColor(.red))
                        .autocorrectionDisabled()
                        // How to change the color of the TextField Placeholder
                    } else {
                        SecureField("Password", // how to create a secure text field
                                    text: $model.password,
                                    prompt: Text("Password").foregroundColor(.red)) // How to change the color of the TextField Placeholder
                    }
                }
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
                }

                Button {
                    model.showPassword.toggle()
                } label: {
                    Image(systemName: model.showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.red) // how to change image based in a State variable
                }

            }.padding(.horizontal)
            
            Button {
                model.createUser()
            } label: {
                Text("Create new user")
                    .bold()
                    .foregroundColor(.blue)
            }


            Spacer()

            Button {
                model.signIn()
            } label: {
                Text("Sign In")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
            .background(
                model.isSignInButtonDisabled ? // how to add a gradient to a button in SwiftUI if the button is disabled
                LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .disabled(model.isSignInButtonDisabled) // how to disable while some condition is applied
            .padding()
        }
    }
}


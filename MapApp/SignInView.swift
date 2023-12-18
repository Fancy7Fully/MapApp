//
//  SignInView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/13/23.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn
import FirebaseAuth

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
        @Published var verifyPassword: String = ""
        @Published var showPassword: Bool = false
        @Published var isSignInButtonDisabled = false
        @Published var isSignInMode = false
        @Published var hasFailedAuthentication = false
        @Published var processing = false
        
        func signIn() {
            processing = true
            appDelegate.userService.signIn(with: name, password: password) { [weak self] _ in
                self?.hasFailedAuthentication = true
                self?.processing = false
            }
        }
        
        func createUser() {
            processing = true
            appDelegate.userService.createUser(with: name, password: password) { [weak self] _ in
                self?.hasFailedAuthentication = true
                self?.processing = false
            }
        }
        
        func handleSignInButton() {
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(with: .init(clientID: Constants.clientId()), presenting: presentingViewController) { user, error in
                guard error == nil else { return }
                guard let token = user?.authentication.idToken,
                      let access = user?.authentication.accessToken else {
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: token,
                                                               accessToken: access)
                Auth.auth().signIn(with: credential)
            }
        }
    }
    
    @ViewBuilder
    var redRectangle: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.red, lineWidth: 2)
    }
    
    @ViewBuilder
    var blueRectangle: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.blue, lineWidth: 2)
    }
    
    @ViewBuilder
    var emailView: some View {
        TextField("Email",
                  text: $model.name ,
                  prompt: Text("Email").foregroundColor(.blue)
        )
        .keyboardType(.alphabet)
        .foregroundColor(.black)
        .padding(10)
        .overlay {
            if model.hasFailedAuthentication {
                redRectangle
            } else {
                blueRectangle
            }
        }
        .padding(.horizontal)
        .autocorrectionDisabled()
        .autocapitalization(.none)
    }
    
    @ViewBuilder
    var verifyPasswordView: some View {
        if model.isSignInMode {
            EmptyView()
        } else {
            Group {
                if model.showPassword {
                    TextField("Repeat password", // how to create a secure text field
                              text: $model.verifyPassword,
                              prompt: Text("Repeat password").foregroundColor(.red))
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                    // How to change the color of the TextField Placeholder
                } else {
                    SecureField("Repeat password", // how to create a secure text field
                                text: $model.verifyPassword,
                                prompt: Text("Repeat password").foregroundColor(.red))
                    .foregroundColor(.black) // How to change the color of the TextField Placeholder
                }
            }
            .padding(10)
            .overlay {
                if model.hasFailedAuthentication {
                    redRectangle
                } else {
                    blueRectangle
                }
            }
        }
    }
    
    @ViewBuilder
    var passwordView: some View {
        Group {
            if model.showPassword {
                TextField("Password", // how to create a secure text field
                          text: $model.password,
                            prompt: Text("Password").foregroundColor(.red))
                .keyboardType(.alphabet)
                .autocorrectionDisabled()
                .foregroundColor(.black)
                .autocapitalization(.none)
                // How to change the color of the TextField Placeholder
            } else {
                SecureField("Password", // how to create a secure text field
                            text: $model.password,
                            prompt: Text("Password").foregroundColor(.red))
                .foregroundColor(.black) // How to change the color of the TextField Placeholder
            }
        }
        .padding(10)
        .overlay {
            if model.hasFailedAuthentication {
                redRectangle
            } else {
                blueRectangle
            }
        }
    }
    
    @ViewBuilder
    var tabView: some View {
        HStack(spacing: 10) {
            Button {
                if !model.isSignInMode {
                    model.isSignInMode.toggle()
                }
            } label: {
                Text("Sign in")
                    .underline()
                    .foregroundStyle(.black)
                    .font(.title)
                    .bold(model.isSignInMode)
            }
            
            Button {
                if model.isSignInMode {
                    model.isSignInMode.toggle()
                }
            } label: {
                Text("Register")
                    .underline()
                    .foregroundStyle(.black)
                    .font(.title)
                    .bold(!model.isSignInMode)
            }
            
            Spacer()
        }
        .padding([.horizontal, .vertical])
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                tabView
                
                Spacer()
                
                emailView
                
                HStack {
                    passwordView
                    Button {
                        model.showPassword.toggle()
                    } label: {
                        Image(systemName: model.showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.red) // how to change image based in a State variable
                    }
                }.padding(.horizontal)
                
                if model.isSignInMode {
                    Group {
                        NavigationLink {
                            ResetPasswordView()
                        } label: {
                            Text("Forgot password?")
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    verifyPasswordView
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical, 20)
                
                GoogleSignInButton(action: model.handleSignInButton)
                    .padding(.horizontal)
                
                
                Spacer()
                
                Button {
                    if model.isSignInMode {
                        model.signIn()
                    } else {
                        model.createUser()
                    }
                } label: {
                    if model.isSignInMode {
                        Text("Sign In")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                    } else {
                        Text("Register")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                    }
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
            .background(.white)
            .overlay {
                if model.processing {
                    ProgressView()
                        .controlSize(.large)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                } else {
                    EmptyView()
                }
            }
        }
    }
}


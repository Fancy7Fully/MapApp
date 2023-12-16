//
//  MapAppApp.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/9/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Combine

class UserService {
    var handler: AuthStateDidChangeListenerHandle?
    var publisher: CurrentValueSubject<User?, Never>?
    
    static func start() -> UserService {
        let service = UserService()
        service.publisher = CurrentValueSubject<User?, Never>.init(nil)
        service.subscribeToStateChange()
        return service
    }
    
    func subscribeToStateChange() {
        handler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
          // ...
            guard let self else { return }
            self.publisher?.send(user)
            print(auth)
            print(user)
        }
    }
    
    func createUser(with email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print("error is \(error)")
            } else {
                print("result is \(result)")
            }
        }
    }
    
    func signIn(with email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print("sign in error is \(error)")
            } else {
                print("sign in result is \(result)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    lazy var userService: UserService = {
        return UserService.start()
    }()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Colors application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
        FirebaseApp.configure()
        
        return true
    }
    
    func printSomething() {
        print("yes here is the delegate")
    }
}

@main
struct MapAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let launchDelegate = LaunchDelegate()
    
    init() {
        if !launchDelegate.hasInUseAuthorization {
            launchDelegate.requestLocationAuthorization()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LandingScreen(delegate: delegate)
        }
    }
}

struct LandingScreen: View {
    
    @StateObject var model: Model
    
    let delegate: AppDelegate
    
    class Model: ObservableObject {
        let appDelegate: AppDelegate
        
        @Published var hasSignedIn: Bool = false
        
        var cancellables = Set<AnyCancellable>()
        
        init(appDelegate: AppDelegate) {
            self.appDelegate = appDelegate
            
            appDelegate.userService.publisher?.sink(receiveValue: { [weak self] user in
                self?.hasSignedIn = user != nil
            })
            .store(in: &cancellables)
        }
    }
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
        _model = StateObject(wrappedValue: Model(appDelegate: delegate))
    }
    
    var body: some View {
        if !model.hasSignedIn {
            SignInView(delegate: delegate)
        } else {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Received", systemImage: "tray.and.arrow.down.fill")
                    }
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                AccountView()
                    .badge("!")
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle.fill")
                    }
            }
        }
    }
}

//
//  AccountView.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/16/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestoreInternal

struct AccountView: View {
    
    let model = Model()
    
    class Model: ObservableObject {
        
        lazy var docRef: DocumentReference = {
            return Firestore.firestore().document("test/tesetImages")
        }()
        
        func upload(_ name: String) {
            
        }
        
        func uploadAssorted() {
            let uuid = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "locationPics/\(uuid)")
            guard let imageData = UIImage(named: "Assorted")?.jpegData(compressionQuality: 0.7) else { return }
            let uploadMetadata = StorageMetadata.init()
            uploadMetadata.contentType = "image/jpeg"
            
            let taskReference = ref.putData(imageData, metadata: uploadMetadata) { [weak self] downloadMetadata, error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                print("Database image saved")
                
                ref.downloadURL { url, error in
                    if let error {
                        print(error.localizedDescription)
                        return
                    }
                    print("Database url downloaded")
                    if let url {
                        self?.writeToDoc(url)
                    }
                }
            }
        }
        
        private func randomPost(_ url: URL) -> Post {
            let rand = Int.random(in: 1...3)
            if rand == 1 {
                return Post(
                    title: "tower 28",
                    isDummy: false,
                    description: "This is tower 28",
                    longitude: -73.93959407611281,
                    latitude: 40.74961150921874,
                    imageUrl: url.absoluteString)
            }
            
            if rand == 2 {
                return Post(title: "knock knock", isDummy: false, description: "This is knock knock", longitude: -73.94216504064606, latitude: 40.74969763124088,
                            imageUrl: url.absoluteString)
            }
            
            return Post(
                title: "new post",
                isDummy: false,
                description: "This is a new post to the document",
                longitude:  -73.93546426277251,
                latitude: 40.74205708336585,
                imageUrl: url.absoluteString)
        }
        
        func writeToDoc(_ url: URL) {
            
            let newPost = randomPost(url)
            if let post = try? newPost.asDictionary() {
                docRef.updateData([
                    "posts" : FieldValue.arrayUnion([post])
                ]) { error in
                    if let error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    print("Database new post added")
                }
            }
        }
    }
    
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
            
            Button {
                model.uploadAssorted()
            } label: {
                Text("upload assorted")
                    .foregroundStyle(.blue)
            }
            
            Button {
                model.uploadAssorted()
            } label: {
                Text("upload assorted")
                    .foregroundStyle(.blue)
            }
            
            Button {
                model.uploadAssorted()
            } label: {
                Text("upload assorted")
                    .foregroundStyle(.blue)
            }
        }
    }
}

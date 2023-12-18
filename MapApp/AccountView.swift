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
        
        func writeToDoc(_ url: URL) {
            let newPost = Post(
                title: "new post",
                isDummy: false,
                description: "This is a new post to the document",
                longitude:  -73.93546426277251, 
                latitude: 40.74205708336585,
                imageUrl: url.absoluteString)
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

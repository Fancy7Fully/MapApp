//
//  DataService.swift
//  MapApp
//
//  Created by Zhiyuan Zhou on 12/17/23.
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseCore
import FirebaseFirestoreInternal

class DataService: ObservableObject {
    @Published var currentPosts: [Post] = []
    let publisher = PassthroughSubject<Post, Never>()
    
    lazy var docRef: DocumentReference = {
        return Firestore.firestore().document("test/tesetImages")
    }()
    
    static let shared = DataService()
    
    private init() {
        fetchPosts()
        setupListener()
    }
    
    private func setupListener() {
        docRef.addSnapshotListener { snapshot, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            if let snapshot, snapshot.exists, let data = snapshot.data() {
                self.currentPosts = self.convertDataToPost(data)
            }
        }
    }
    
    private func fetchPosts() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            self.docRef.getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data() {
                    DispatchQueue.main.async {
                        self.currentPosts = self.convertDataToPost(data)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    private func convertDataToPost(_ data: [String : Any]) -> [Post] {
        guard let posts = data["posts"] as? [Any] else { return [] }
        var result: [Post] = []
        for post in posts {
            if let casted = post as? [String : Any] {
                let newPost = Post(
                    title: casted["title"] as? String ?? "",
                    isDummy: casted["is_dummy"] as? Bool ?? true,
                    description: casted["description"] as? String,
                    longitude: casted["longitude"] as? Double,
                    latitude: casted["latitude"] as? Double,
                    imageUrl: casted["imageUrl"] as? String)
                result.append(newPost)
            }
        }
        print(result)
        return result
    }
}

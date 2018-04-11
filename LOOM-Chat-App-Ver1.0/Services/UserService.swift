//
//  UserService.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/7/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    // User-related network code
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    // Check if the user resister a partner
    static func showPartner(forUID user: User, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference().child("usersInfo").child(user.username).child("partner")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let partner = snapshot.value else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func create(_ firUser: FirebaseAuth.User, username: String, completion: @escaping (User?) -> Void) {
        print("User Service create")
        let userAttrs = ["username": username]
        
        // add info to "users"
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure("Error: \(error.localizedDescription)")
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
}

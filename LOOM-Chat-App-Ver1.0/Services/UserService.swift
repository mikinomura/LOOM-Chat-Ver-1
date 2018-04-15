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
        let ref = Database.database().reference().child("usersInfo").child(user.username).child("followingPartner")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                print("Partner doesn't exist")
                return completion(false)
            }
            print("snapshot value: \(snapshot.value)")
            
            return completion(true)
        })
    }
    
    static func showFollowerPartner(forUID user: User, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference().child("usersInfo").child(user.username).child("followerPartner")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                print("Follower doesn't exist")
                return completion(false)
            }
            print("snapshot value: \(snapshot.value)")
            
            return completion(true)
        })
    }
    
    static func showPartnerStatus(forUID user: User, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference().child("usersInfo").child(user.username).child("followingPartner")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                print("Partner doesn't exist")
                return completion(false)
            }
            
            print("snapshot value: \(snapshot.value)")
            let value = snapshot.value as? NSDictionary
            let status = value?["status"] as? Int ?? 0
            print("status: \(status)")
            if status == 0 {
                return completion(false)
            }
            return completion(true)
        })
    }
    
    static func showFollowerPartnerStatus(forUID user: User, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference().child("usersInfo").child(user.username).child("followerPartner")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                print("Partner request doesn't exist")
                return completion(false)
            }
            
            let value = snapshot.value as? NSDictionary
            let status = value?["status"] as? Int ?? 0
            if status == 0 {
                return completion(false)
            }
            return completion(true)
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

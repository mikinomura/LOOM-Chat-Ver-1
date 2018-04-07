//
//  User.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/7/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {
    // MARK: Properties
    let uid: String
    let username: String
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot as? [String: Any],
            let username = dict["username"] as? String
            else { return nil}
        
        self.uid = snapshot.key
        self.username = username
        
    }
}

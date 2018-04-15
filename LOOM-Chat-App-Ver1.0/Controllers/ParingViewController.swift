//
//  ParingViewController.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/10/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class ParingViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBAction
    @IBAction func FindButtonTapped(_ sender: UIButton) {
        // Check if the username exists or not
        let partnerUsername = inputTextField.text
        let ref = Database.database().reference()
        let query = ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: partnerUsername)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // If partners' username is found, set it as a partner
            if snapshot.value != nil {
                // The user's info
                let infoRef = ref.child("usersInfo").child(User.current.username).child("followingPartner")
                let infoFollowerRef = ref.child("usersInfo").child(User.current.username).child(byAppendingPath: "followerPartner")
                let followingPartnerAttrs = ["username": partnerUsername!, "status": true] as [String : Any]
                let followerAttrs = ["username": partnerUsername!, "status": false] as [String: Any]
                
                // Follower's info
                let partnerInfoRef = ref.child("usersInfo").child(partnerUsername!).child("followerPartner")
                let follwerPartnerAtts = ["username": User.current.username, "status": true] as [String : Any]
                
                infoRef.setValue(followingPartnerAttrs)  { (error, ref) in
                    if let error = error {
                        assertionFailure("Error: \(error.localizedDescription)")
                        return
                    }
                }
                
                infoFollowerRef.setValue(followerAttrs) { (error, ref) in
                    if let error = error {
                        assertionFailure("Error: \(error.localizedDescription)")
                        return
                    }
                    
                }
                
                partnerInfoRef.setValue(follwerPartnerAtts) { (error, ref) in
                    if let error = error {
                        assertionFailure("Error: \(error.localizedDescription)")
                        return
                    }
                    
                }
                
                // If exists, go to the waiting page
                self.performSegue(withIdentifier: Constants.Segue.waitingForPartner, sender: self)
                
            } else {
                print("Your partner's username can't be found")
                // Show Text Message
            }
        })
    }
}

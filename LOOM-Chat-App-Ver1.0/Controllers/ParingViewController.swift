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
    @IBOutlet weak var inviteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteButton.layer.cornerRadius = 21
        
        setupBorder()
    }
    
    private func setupBorder() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Constants.Color.lightBlue.cgColor
        border.frame = CGRect(x: 0, y: inputTextField.frame.size.height - width, width:  inputTextField.frame.size.width, height: inputTextField.frame.size.height)
        
        border.borderWidth = width
        inputTextField.layer.addSublayer(border)
        inputTextField.layer.masksToBounds = true
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
                let partnerFollowingInfoRef = ref.child("usersInfo").child(partnerUsername!).child("followingPartner")
                let follwerPartnerAtts = ["username": User.current.username, "status": true] as [String : Any]
                let followingPartnerInfoAttrs = ["username": User.current.username, "status": false] as [String: Any]
                
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
                
                partnerFollowingInfoRef.setValue(followingPartnerInfoAttrs) { (error, ref) in
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

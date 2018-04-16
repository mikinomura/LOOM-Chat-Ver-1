//
//  AcceptRequestViewController.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/15/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AcceptRequestViewController: UIViewController {
    
    // MARK: -- Property
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var requestFromLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPartnerName()
        
        setButtonFormat()
    }
    
    private func setButtonFormat() {
        acceptButton.layer.cornerRadius = 21
    }
    
    // MARK: -- IBAction
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        // Change the firebase status
        ChangeFollowingStatus()
        
        // Create a conversation room name
        CreateRoomName()
        
    }
    
    private func setPartnerName() {
        let ref = Database.database().reference().child("usersInfo").child(User.current.username).child("followingPartner")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                return
            }
            
            let partnerName = value["username"] as? String ?? ""
            self.requestFromLabel.text = "Request from \(partnerName)"
        })
    }
    
    
    private func ChangeFollowingStatus(){
        let ref = Database.database().reference().child("usersInfo").child(User.current.username).child("followingPartner")
        let childUpdates = ["status": true]
        ref.updateChildValues(childUpdates)
    }
    
    private func CreateRoomName() {
        let username = User.current.username
        let ref = Database.database().reference().child("usersInfo").child(username)
        let followingRef = ref.child("followingPartner")
        let roomRef = ref.child(byAppendingPath: "room")
        
        var roomName = ""
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let partnerUsername = value?["username"] as? String ?? ""
            
            let partnerRef = Database.database().reference().child("usersInfo").child(partnerUsername)
            let partnerRoomRef = partnerRef.child(byAppendingPath: "room")
            
            roomName = username + partnerUsername
            let roomNameAttr = ["roomName": roomName]
            
            // Set values to the user and the partner's room
            roomRef.setValue(roomNameAttr)
            partnerRoomRef.setValue(roomNameAttr)
            
            let messageViewController = MessageViewController()
            messageViewController.senderDisplayname = roomName
            
            // Go to the main screen
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

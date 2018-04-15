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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -- IBAction
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        // Change the firebase status
        ChangeFollowingStatus()
        
        // Go to the main screen
    }
    
    private func ChangeFollowingStatus(){
        let ref = Database.database().reference().child("usersInfo").child(User.current.username).child("followingPartner")
        let childUpdates = ["status": true]
        ref.updateChildValues(childUpdates)
    }
}

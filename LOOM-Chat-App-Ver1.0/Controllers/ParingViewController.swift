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
                let infoRef = ref.child("usersInfo").child(User.current.username).child("partner")
                let partnerAttrs: [String: Bool] = [partnerUsername!: false]
                infoRef.setValue(partnerAttrs)  { (error, ref) in
                    if let error = error {
                        assertionFailure("Error: \(error.localizedDescription)")
                        return
                    }
                }
                
                // If exists, go to the main storyboard
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                
            } else {
                print("Your partner's username can't be found")
                // Show Text Message
            }
        })
    }
}

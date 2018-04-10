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
        
        let query = ref.queryOrdered(byChild: "users").queryEqual(toValue: partnerUsername)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                print(child)
            }
        })
        
        // If exists, go to the main storyboard
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
        
    }
}

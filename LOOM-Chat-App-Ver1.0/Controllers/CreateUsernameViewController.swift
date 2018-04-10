//
//  CreateUsernameViewController.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/7/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: IB Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        print("Next button tapped")
        
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        // Send user data to the Firebase database
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else { return }
            print("Create a new user: \(user.username)")
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            // Back to the main storyboard
            // let initialViewController = UIStoryboard.initialViewController(for: .main)
            // self.view.window?.rootViewController = initialViewController
            // self.view.window?.makeKeyAndVisible()
        }
    }
}

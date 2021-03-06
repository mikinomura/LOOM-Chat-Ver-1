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
        
        setupBorder()
        nextButton.layer.cornerRadius = 21
    }
    
    private func setupBorder() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Constants.Color.lightBlue.cgColor
        border.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - width, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        
        border.borderWidth = width
        usernameTextField.layer.addSublayer(border)
        usernameTextField.layer.masksToBounds = true
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
            
            //If the user already has a request from a partner, show an accept screen.
            if self.checkIfHasPartner() {
                // Go to an accept screen
                self.performSegue(withIdentifier: Constants.Segue.acceptScreen, sender: self)
            } else {
                // Go to a pairng screen
                self.performSegue(withIdentifier: Constants.Segue.signupToFindPartner, sender: self)
            }
        }
    }
    
    private func checkIfHasPartner() -> Bool {
        
        return false
    }
}

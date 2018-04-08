//
//  LoginViewController.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/7/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var loginButton: UIButton!
    
    typealias FIRUser = FirebaseAuth.User
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IB Actions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        print("Login Button Tapped!")
        
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        authUI.delegate = self
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    }
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // Error handling
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        
        guard let user = user
            else { return }
        
        let userRef = Database.database().reference().child("users").child(user.uid)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                print("Welcome back: \(user.username)")
                // Ser a current user
                User.setCurrent(user)
                
                // Go to the main storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                if let initialViewController = storyboard.instantiateInitialViewController() {
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                }
            } else {
                print("New user!")
                self.performSegue(withIdentifier: "toCreateUsername", sender: self)
            }
            
        })
        
        print("Handle User Sign-up / login")
    }
}

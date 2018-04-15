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
        
        // moveFindUserScreen()
        
        UserService.show(forUID: user.uid) { (user) in
            if let user = user {
                User.setCurrent(user, writeToUserDefaults: true)
                
                // Check if the user has a follower
                UserService.showFollowerPartner(forUID: user) { (bool) in
                    
                    // If user has a follower, check whether the user has accepted the follower already or not
                    if bool == true {
                        print("The user has a follower!")
                        UserService.showPartnerStatus(forUID: user, completion: { (status) in
                            // If accepted, go to the main screen
                            if status == true {
                                
                                // Go to the main screen
                                let initialViewController = UIStoryboard.initialViewController(for: .main)
                                self.view.window?.rootViewController = initialViewController
                                self.view.window?.makeKeyAndVisible()
                                
                            } else {
                                
                                // Go to the accept screen
                                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                let waitingView = storyboard.instantiateViewController(withIdentifier: "acceptRequestViewController") as! AcceptRequestViewController
                                self.navigationController?.pushViewController(waitingView, animated: true)
                                
                            }
                        })
                    } else {
                        // if the user doesn't have a follower, check if the user has a following partner
                        UserService.showFollowerPartner(forUID: user) { (bool) in
                            if bool == true {
                                UserService.showPartnerStatus(forUID: user, completion: { (status) in
                                    // If a partner has approved the request
                                    if status == true {
                                        let initialViewController = UIStoryboard.initialViewController(for: .main)
                                        self.view.window?.rootViewController = initialViewController
                                        self.view.window?.makeKeyAndVisible()
                                    } else {
                                        // If the request has not been approved, show the waiting screen
                                        let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                        let waitingView = storyboard.instantiateViewController(withIdentifier: "waitingForYourPartner") as! WaitingForThePartnerViewController
                                        self.navigationController?.pushViewController(waitingView, animated: true)
                                    }
                                })
                            } else {
                                self.performSegue(withIdentifier: Constants.Segue.signupToFindPartner, sender: self)
                            }
                        }
                    }
                }
            } else {
                self.performSegue(withIdentifier: Constants.Segue.createUsername, sender: self)
            }
            
        }
    }
    
    private func moveFindUserScreen() {
        if Auth.auth().currentUser != nil {
            UserService.show(forUID: User.current.uid) { (user) in
                // If user already logined, show find partner screen
                if let user = user {
                    User.setCurrent(user, writeToUserDefaults: true)
                    
                    // Check if the user has a follower
                    UserService.showFollowerPartner(forUID: user) { (bool) in
                        
                        // If user has a follower, check whether the user has accepted the follower already or not
                        if bool == true {
                            print("The user has a follower!")
                            UserService.showPartnerStatus(forUID: user, completion: { (status) in
                                // If accepted, go to the main screen
                                if status == true {
                                    
                                    // Go to the main screen
                                    let initialViewController = UIStoryboard.initialViewController(for: .main)
                                    self.view.window?.rootViewController = initialViewController
                                    self.view.window?.makeKeyAndVisible()
                                    
                                } else {
                                    
                                    // Go to the accept screen
                                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                    let waitingView = storyboard.instantiateViewController(withIdentifier: "acceptRequestViewController") as! AcceptRequestViewController
                                    self.navigationController?.pushViewController(waitingView, animated: true)
                                    
                                }
                            })
                        } else {
                            // if the user doesn't have a follower, check if the user has a following partner
                            UserService.showFollowerPartner(forUID: user) { (bool) in
                                if bool == true {
                                    UserService.showPartnerStatus(forUID: user, completion: { (status) in
                                        // If a partner has approved the request
                                        if status == true {
                                            let initialViewController = UIStoryboard.initialViewController(for: .main)
                                            self.view.window?.rootViewController = initialViewController
                                            self.view.window?.makeKeyAndVisible()
                                        } else {
                                            // If the request has not been approved, show the waiting screen
                                            let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                            let waitingView = storyboard.instantiateViewController(withIdentifier: "waitingForYourPartner") as! WaitingForThePartnerViewController
                                            self.navigationController?.pushViewController(waitingView, animated: true)
                                        }
                                    })
                                } else {
                                    self.performSegue(withIdentifier: Constants.Segue.signupToFindPartner, sender: self)
                                }
                            }
                        }
                    }
                } else {
                    self.performSegue(withIdentifier: Constants.Segue.createUsername, sender: self)
                }
                
            }
        }
    }
}

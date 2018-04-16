//
//  Constants.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/8/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Segue {
        static let createUsername = "toCreateUsername"
        static let signupToFindPartner = "signupToFindPartner"
        static let waitingForPartner = "toWaitingForPartner"
        static let acceptScreen = "toAcceptScreen"
    }
    
    struct UserDefaults {
        static let currentUser = "currentUser"
        static let uid = "uid"
        static let username = "username"
        static let roomName = "roomName"
    }
    
    struct Color {
        static let primaryBlue = UIColor(red: 85/255, green: 123/244, blue: 226/255, alpha: 1)
        static let primaryGreen = UIColor(red: 58/255, green: 207/255, blue: 213/255, alpha: 1)
        static let secondPurple = UIColor(red: 238/255, green: 242/255, blue: 252/255, alpha: 1)
        static let lightBlue = UIColor(red: 58/255, green: 207/255, blue: 213/255, alpha: 1)
    }
}

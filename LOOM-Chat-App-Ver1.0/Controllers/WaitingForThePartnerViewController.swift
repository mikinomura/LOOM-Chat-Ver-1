//
//  WaitingForThePartnerViewController.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/11/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation
import UIKit

class WaitingForThePartnerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe the partner's accept
        // if true
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
}

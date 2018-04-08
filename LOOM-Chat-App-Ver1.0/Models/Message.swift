//
//  Message.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/8/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import Foundation

struct Message {
    let message: String
    let isSender: Bool
    
    init(message: String, isSender: Bool) {
        self.message = message
        self.isSender = isSender
    }
}

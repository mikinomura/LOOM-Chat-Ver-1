//
//  MessageViewCell.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/8/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import UIKit

class MessageViewCell: UICollectionViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var bubbleView: UIView!
    
    func displayContent(message: String){
        messageLabel.text = message
    }
}

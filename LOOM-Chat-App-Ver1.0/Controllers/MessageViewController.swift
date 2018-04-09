//
//  MessageViewController.swift
//  LOOM-Chat-App-Ver1.0
//
//  Created by Miki Nomura on 4/8/18.
//  Copyright © 2018 Miki Nomura. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: Properties
    var senderDisplayname: String = "Luke & Miki"
    var senderID = ""
    var messages: [Message] = []
    private var newMessageRefHandle: DatabaseHandle?
    
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        senderID = User.current.uid
        
        addMessage(isSender: true, message: "hello!")
        
        observeMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(messages.count)
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageViewCell", for: indexPath) as! MessageViewCell
        
        // Caluculate the width based on the character count, then decide the size of the cell view
        let size = CGSize(width: view.frame.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedHeight = NSString(string: messages[indexPath.item].message).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
        
        var defaultWidth = estimatedHeight.width
        var defaultHeight = estimatedHeight.height
        
        if estimatedHeight.width < 50 {
            defaultWidth = 100
        }
        
        // If the message is from the sender, the cell is blue
        if messages[indexPath.item].isSender == false {
            // Adjust a size of the bubble and the text
            cell.bubbleView.frame = CGRect(x: 0, y: 0
                , width: defaultWidth, height: estimatedHeight.height + 60)
            cell.messageLabel.frame = CGRect(x: 5, y: 10, width: defaultWidth + 8, height: estimatedHeight.height + 60)
            
            // Create a Bubble style cell
            let rectShape = CAShapeLayer()
            rectShape.bounds = cell.bubbleView.frame
            rectShape.position = cell.bubbleView.center
            rectShape.path = UIBezierPath(roundedRect: cell.bubbleView.bounds, byRoundingCorners: [.bottomRight , .topRight], cornerRadii: CGSize(width: 35, height: 35)).cgPath
            
            cell.bubbleView.layer.masksToBounds = true
            cell.bubbleView.backgroundColor = Constants.Color.primaryBlue
            cell.messageLabel.textColor = UIColor.white
            cell.bubbleView.layer.mask = rectShape
            
            cell.displayContent(message: messages[indexPath.item].message)
            
        } else {
            // Adjust a size of the blue bubble and the text
            cell.bubbleView.frame = CGRect(x: view.frame.width - defaultWidth - 30, y: 0, width: defaultWidth + 50, height: estimatedHeight.height + 60)
            cell.messageLabel.frame = CGRect(x: view.frame.width - defaultWidth, y: 0, width: defaultWidth + 8 , height: estimatedHeight.height + 60)
            
            // Create a blue Bubble style
            let rectShape = CAShapeLayer()
            rectShape.bounds = cell.bubbleView.frame
            rectShape.position = cell.bubbleView.center
            rectShape.path = UIBezierPath(roundedRect: cell.bubbleView.bounds, byRoundingCorners: [.bottomLeft , .topLeft], cornerRadii: CGSize(width: 35, height: 35)).cgPath
            
            cell.bubbleView.layer.masksToBounds = true
            cell.bubbleView.backgroundColor = Constants.Color.primaryGreen
            cell.messageLabel.textColor = UIColor.white
            cell.bubbleView.layer.mask = rectShape
            
            cell.displayContent(message: messages[indexPath.item].message)
        }
            
        cell.displayContent(message: messages[indexPath.item].message)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Set the cell's width to the width of the screen
        let size = CGSize(width: view.frame.width, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let estimatedHeight = NSString(string: messages[indexPath.item].message).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
        
        return CGSize(width: view.frame.width, height: estimatedHeight.height + 60)
    }
 
    
    // Append messages
    func addMessage(isSender: Bool, message: String) {
        let newMessage = Message(message: message, isSender: isSender)
        messages.append(newMessage)
        collectionView?.reloadData()
    }
    
    // Send message to Firebase
    func sendMessage(message: String) {
        let ref = Database.database().reference().child("messages").child("Luke and Miki").childByAutoId()
        let message = ["message": message, "sender": senderID]
        ref.setValue(message)
    }
    
    private func observeMessages() {
        let messageRef = Database.database().reference().child("messages").child("Luke and Miki")
        
        // Creating a query that limits the synchronization to the last 25 messages.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let value = snapshot.value as! NSDictionary
            if let text = value["message"] as? String, text.count > 0 {
                if value["sender"] as? String == self.senderID {
                    self.addMessage(isSender: true, message: text)
                } else {
                    self.addMessage(isSender: false, message: text)
                }
            }
            
        })
    }
    
    // MARK: IBAction
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let messageText = messageTextField.text {
            //addMessage(isSender: true, message: messageText)
            sendMessage(message: messageText)
            messageTextField.text = ""
        }
        
    }
    
}

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
        cell.displayContent(message: messages[indexPath.item].message)
        
        return cell
    }
    
    // Append messages
    func addMessage(isSender: Bool, message: String) {
        var newMessage = Message(message: message, isSender: isSender)
        messages.append(newMessage)
        collectionView?.reloadData()
    }
    
    // Send message to Firebase
    func sendMessage(message: String) {
        let ref = Database.database().reference().child("messages").child("Luke and Miki").childByAutoId()
        var message = ["message": message, "sender": senderID]
        ref.setValue(message)
    }
    
    private func observeMessages() {
        var messageRef = Database.database().reference().child("messages").child("Luke and Miki")
        
        // Creating a query that limits the synchronization to the last 25 messages.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let messageData = snapshot.value as? NSDictionary
            
            let value = snapshot.value as! NSDictionary
            if let text = value["message"] as? String, text.characters.count > 0 {
                if value["sender"] as? String == self.senderID {
                    self.addMessage(isSender: true, message: text)
                } else {
                    self.addMessage(isSender: false, message: text)
                }
            }
            
            /*
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let value = snap.value as! NSDictionary
                
                if let text = value["message"] as? String, text.characters.count > 0 {
                    // Check if the message is sent by the user or by another user
                    if value["sender"] as? String == self.senderID {
                        self.addMessage(isSender: true, message: text)
                    } else {
                        self.addMessage(isSender: false, message: text)
                    }
                } else {
                    print("Error! Could not decode message data")
                }
            }
 */
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

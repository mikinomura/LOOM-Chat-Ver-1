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
    var senderDisplayname: String = ""
    var senderID = ""
    var messages: [Message] = []
    private var newMessageRefHandle: DatabaseHandle?
    var bottomConstraint: NSLayoutConstraint?
    
    let messageInputContainerview: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.secondPurple
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: [])
        button.setTitleColor(Constants.Color.primaryBlue, for: [])
        return button
    }()
    
    
    // MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    
        senderID = User.current.uid
        
        // If paring isn't completed, send a message from the server "Waiting for your partner's accept"
        // Until the accept, the user can't send messages - hide the keyboard
        
        // Add a text view
        view.addSubview(messageInputContainerview)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerview)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerview)
        setupInputComponents()
        
        // Text Field Constraint
        bottomConstraint =  NSLayoutConstraint(
            item:       messageInputContainerview,
            attribute:  .bottom,
            relatedBy:  .equal,
            toItem:     view,
            attribute:  .bottom,
            multiplier: 1.0,
            constant:   0
        )
        
        view.addConstraint(bottomConstraint!)
        observeMessages()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardNotification(note:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardNotification(note:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    private func SetRoomName() {
        let username = User.current.username
        let ref = Database.database().reference().child("usersInfo").child(username).child("room").child("roomName")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let room = snapshot.value {
                print("ROOM: \(room)")
            }
            
            print("roomname: \(snapshot.value)")
            let value = snapshot.value as? String
            // let roomName = value?["roomName"] as? String ?? ""
            
            self.senderDisplayname = value!
            
        })
    }
    
    private func checkIfPartnerAccept() -> Bool {
        return false
    }
    
    private func setupInputComponents(){
        messageInputContainerview.addSubview(inputTextField)
        messageInputContainerview.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        messageInputContainerview.addConstraintsWithFormat(format: "H:|-0-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerview.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerview.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
    }
    
    @objc func handleKeyboardNotification(note: Notification) {
        print("Handle Keyboard Notification")
        if let userInfo = note.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            
            let isKeyboardShowing = note.name == Notification.Name.UIKeyboardWillShow
        
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay:0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion:{ _ in
                if self.messages.count > 0 {
                    let indexPath = NSIndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
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
                , width: defaultWidth + 30, height: estimatedHeight.height + 60)
            cell.messageLabel.frame = CGRect(x: 5, y: 0, width: defaultWidth + 8, height: estimatedHeight.height + 60)
            
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
        
        cell.layer.zPosition = 0
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
        let ref = Database.database().reference().child("messages").child(senderDisplayname).childByAutoId()
        let message = ["message": message, "sender": senderID]
        ref.setValue(message)
    }
    
    private func observeMessages() {
        let username = User.current.username
        let ref = Database.database().reference().child("usersInfo").child(username).child("room").child("roomName")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let room = snapshot.value {
                print("ROOM: \(room)")
            }
            
            print("roomname: \(snapshot.value)")
            let value = snapshot.value as? String
            // let roomName = value?["roomName"] as? String ?? ""
            
            self.senderDisplayname = value!
            
            let messageRef = Database.database().reference().child("messages").child(self.senderDisplayname)
            
            // Creating a query that limits the synchronization to the last 25 messages.
            let messageQuery = messageRef.queryLimited(toLast:25)
            
            // We can use the observe method to listen for new
            // messages being written to the Firebase DB
            self.newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
                
                let value = snapshot.value as! NSDictionary
                if let text = value["message"] as? String, text.count > 0 {
                    if value["sender"] as? String == self.senderID {
                        self.addMessage(isSender: true, message: text)
                    } else {
                        self.addMessage(isSender: false, message: text)
                    }
                }
                
            })
            
        })
        
    }
    
    @objc func sendButtonTapped(sender: UIButton!) {
        if let messageText = inputTextField.text {
            //addMessage(isSender: true, message: messageText)
            sendMessage(message: messageText)
            inputTextField.text = ""
            inputTextField.endEditing(true)
        }
        
    }
    
}


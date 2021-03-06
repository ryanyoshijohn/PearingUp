//
//  MessageViewController.swift
//  Pearing_Up
//
//  Created by aaa117 on 7/31/18.
//  Copyright © 2018 Manan Maniyar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var behindMessage: UIView!
    
    var messageId : String!
    var messages = [Message]()
    var message : Message!
    
    
    
    var recipient : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        behindMessage.layer.shadowRadius = 1.5
        behindMessage.layer.masksToBounds = false
        behindMessage.layer.shadowOpacity = 0.5
        behindMessage.layer.shadowOffset = CGSize.zero
        behindMessage.layer.cornerRadius = 2.0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        contactNameLabel.text = recipient
        
        print(messageId)
        
        if (messageId != "" && messageId != nil) {
            loadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.moveToBottom()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backButton(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Message") as? MessagesCell {
            
            cell.configCell(message: message)
            
            return cell
        }
        else {
            return MessagesCell()
        }
    }
    
    func loadData() {
        Database.database().reference().child("messages").child(messageId).observe(.value, with : { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                self.messages.removeAll()
                
                for data in snapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        
                        let key = data.key
                        
                        let post = Message(messageKey: key, postData: postDict)
                        
                        self.messages.append(post)
                    }
                }
                
            }
            self.tableView.reloadData()
        })
    }
    
    func moveToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section : 0)
            
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    @IBAction func sendButton(_ sender: Any) {
        if (messageField.text != nil && messageField.text != "") {
            if messageId == nil {
                let post : Dictionary<String, AnyObject> = [
                    "message" : messageField.text as AnyObject,
                    "sender" : User.Data.username as AnyObject]
                
                let message : Dictionary<String, AnyObject> = [
                    "lastmessage" : messageField.text as AnyObject,
                    "recipient" : User.Data.username as AnyObject]
                
                let recipientMessage : Dictionary<String, AnyObject> = [
                    "lastmessage" : messageField.text as AnyObject,
                    "recipient" : User.Data.username as AnyObject]
                
                messageId = Database.database().reference().child("messages").childByAutoId().key
                
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                firebaseMessage.setValue(post)
                
                let recipientMsg = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                
                recipientMsg.setValue(recipientMessage)
                
                let userMessage = Database.database().reference().child("users").child(User.Data.username).child("messages").child(messageId)
                
                userMessage.setValue(message)
                
                loadData()
            } else if messageId != "" {
                let post : Dictionary<String, AnyObject> = [
                    "message" : messageField.text as AnyObject,
                    "sender" : recipient as AnyObject]
                
                let message : Dictionary<String, AnyObject> = [
                    "lastmessage" : messageField.text as AnyObject,
                    "recipient" : recipient as AnyObject]
                
                let recipientMessage : Dictionary<String, AnyObject> = [
                    "lastmessage" : messageField.text as AnyObject,
                    "recipient" : User.Data.username as AnyObject]
                
                let firebaseMessage = Database.database().reference().child("messages").child(messageId).childByAutoId()
                
                firebaseMessage.setValue(post)
                
                let recipientMsg = Database.database().reference().child("users").child(recipient).child("messages").child(messageId)
                
                recipientMsg.setValue(recipientMessage)
                
                let userMessage = Database.database().reference().child("users").child(User.Data.username).child("messages").child(messageId)
                
                userMessage.setValue(message)
                
                loadData()
            }
            messageField.text = ""
        }
        moveToBottom()
        printMessages()
    }
    
    func printMessages() {
        if(messages.count > 0) {
            for i in (0...(messages.count - 1)) {
                print(messages[i].sender + ": " + messages[i].message)
            }
        }
    }
    
    @IBAction func rateButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toRating", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRating" {
                if let destination = segue.destination as? RatingViewController {
                    print("b4 " , recipient)
                    destination.person = recipient
                    if (messages[0].sender != recipient) {
                        destination.ratingType = "picker"
                    }
                    else {
                        destination.ratingType = "owner"
                    }
                }
            }
        }
}

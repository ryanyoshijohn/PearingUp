//
//  InboxViewController.swift
//  Pearing_Up
//
//  Created by Grace Kim on 2018-07-03.
//  Copyright © 2018 Manan Maniyar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var contactTableView: UITableView!
    
    let myGroup = DispatchGroup()
    
    
    func get_RequestData(completion: @escaping (String) -> Void) {
        self.myGroup.enter()
        populate()
        self.myGroup.leave()
    }
    
    // Ge
    func populate()
    {
        self.myGroup.enter()
        let url = "https://pearingup.herokuapp.com/" + User.Data.username + "/getContacts"
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if(response.result.isSuccess) {
                let json : JSON = JSON(response.result.value!)
                print(json)
                let requested_people = json["result"].array
                
                
                print(requested_people)
                if(requested_people != nil){
                    for people in requested_people! {
                            self.nameList.append(people.string!)
                            //self.descriptionList.append(people["add_msg"].string!)
                        }
                }
                self.myGroup.leave()
            } else {
                print("Contacts View Controller Error")
                self.myGroup.leave()
            }
        }
    }
    
    var messageDetail = [MessageDetail]()
    
    var detail : MessageDetail!
    
    var recipient : String!
    
    var messageId : String!
    
    func update_data() {
        print("Came at update_Data()")
        self.contactTableView.reloadData()
    }
    
    
    //populate this array with names of senders
    var nameList : [String] = []
    
    //populate this array with attached messages
    var descriptionList : [String] = []
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return(nameList.count)
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let messageDet = messageDetail[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as! ContactListTableViewCell
        
        cell.configureCell(messageDetail: messageDet)
        cell.nameLabel.text = nameList[indexPath.row]
        //cell.descriptionLabel.text = descriptionList[indexPath.row]
        
        return(cell)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactTableView.dataSource = self
        self.contactTableView.delegate = self
        
        Database.database().reference().child("users").child(User.Data.username).child("messages").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                self.messageDetail.removeAll()
                
                for data in snapshot {
                    if let messageDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        
                        let info = MessageDetail(messageKey: key, messageData: messageDict)
                    
                        self.messageDetail.append(info)
                    }
                }
            }
            self.contactTableView.reloadData()
        })
        
        //populate(uname : "manan")
        self.get_RequestData() { data in
            print("Came here")
        }
        myGroup.notify(queue: .main) {
            self.update_data()
        }
        self.tabBarController?.tabBar.isHidden = false
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.update_data()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "expandRequest", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageId = messageDetail[indexPath.row].messageRef.key
    }
    
    @IBAction func requestButton(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swipe(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessages" {        
            // Push data of cell into next view
            if let collectionCell: ContactListTableViewCell = sender as? ContactListTableViewCell {
                if let destination = segue.destination as? MessageViewController {
                    destination.recipient = collectionCell.nameLabel.text
                    destination.messageId = messageId
                }
            }
        }
    }
    
}

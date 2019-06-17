//
//  AdminChatVC.swift
//  Drewel
//
//  Created by Octal on 01/10/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Firebase

class AdminChatVC: BaseViewController {
    
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var const_textview_height: NSLayoutConstraint!
    
    
    let myChatRef = Database.database().reference()
    var msgObserver: DatabaseHandle?
    var readObserver: DatabaseHandle?
    var userId = String()
    
    var arrMessage = Array<[String:String]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtMessage.text = ""
        self.title = languageHelper.LocalString(key: "chatSupport")
        self.observeMessages()
        self.enterChat()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.myChatRef.removeObserver(withHandle: msgObserver!)
        self.myChatRef.child("total_chats").child(userId).child("admin_unread").setValue("0")
    }
    
    // MARK: - UIButton Action
    
    @IBAction func btnSendAction(_ sender: UIButton) {
        
        let timestamp = "\(Int(Date().timeIntervalSince1970 * 1000))"
        let messageItem = [
            "timestamp"   : timestamp,
            "message"     : (self.txtMessage.text)!,
            "type"        : "admin"
        ]
        self.myChatRef.child("chat").child(userId).child(timestamp).setValue(messageItem)
        user_unread = user_unread + 1
        self.myChatRef.child("total_chats").child(userId).child("user_unread").setValue("\(user_unread)")
        self.myChatRef.child("total_chats").child(userId).child("timestamp").setValue("\(timestamp)")
        self.txtMessage.text = ""
        self.const_textview_height.constant = 35
    }
    
    
    // MARK: - Firebase Methods
    
    func observeMessages() {
        let messageQuery = self.myChatRef.child("chat").child(userId).queryOrderedByKey()
        msgObserver = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            if snapshot.exists() {
                if let messageData = snapshot.value as? [String:String] {
                    print(messageData)
                    
                    self.arrMessage.append(messageData)
                    self.tblChat.reloadData()
                    
                    DispatchQueue.main.async {
                        self.tblChat.scrollToRow(at: IndexPath.init(row: (self.arrMessage.count - 1), section: 0), at: UITableViewScrollPosition.none, animated: false)
                    }
                }
            }
        })
    }
    
    func enterChat() {
        self.myChatRef.child("total_chats").child(userId).child("admin_unread").setValue("0")
    }
}


// MARK: -
//UITableView Delegate & Datasource
extension AdminChatVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDict = self.arrMessage[indexPath.row]
        let reuseId = ("\(messageDict["type"] ?? "")" == "user") ? "CellAdmin" : "CellUser"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! ChatCell
        cell.lblMessage.text = "\(messageDict["message"] ?? "")"
        cell.lblTime.text = "01:57 pm"
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: -
//UITextView Delegate
extension AdminChatVC : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.location > 100 && text != "" {
            return false
        }
        
        let lastText = String(textView.text.last ?? Character.init("0"))
        if text == "\n" {
            print("change line")
            if self.const_textview_height.constant <= 51 {
                UIView.animate(withDuration: 0.5) {
                    self.const_textview_height.constant = self.const_textview_height.constant + 15
                }
            }
        }else if lastText == "\n" && text == "" && range.length == 1 {
            let newLineCount = textView.text.components(separatedBy: "\n")
            if self.const_textview_height.constant > 47 && newLineCount.count <= 3 {
                UIView.animate(withDuration: 0.5) {
                    self.const_textview_height.constant = self.const_textview_height.constant - 15
                }
            }
        }
        return true
    }
    
}

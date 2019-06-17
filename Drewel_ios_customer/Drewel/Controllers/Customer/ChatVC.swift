//
//  ChatVC.swift
//  Drewel
//
//  Created by Octal on 28/09/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: BaseViewController {
    
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var const_textview_height: NSLayoutConstraint!
    
    
    let myChatRef = Database.database().reference().child("chatmodel")
    var msgObserver: DatabaseHandle?
    var readObserver: DatabaseHandle?
    var tap = UITapGestureRecognizer()
    let strTextDescribe = languageHelper.LocalString(key: "writeComment")
    
    var arrMessage = Array<[String:String]>()
    
    var viewHeight = CGFloat()
    var strAdminId = String()
    var strAdminName = "Admin"
    
    var timer : Timer!
    var isShowMsg = true
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.viewHeight = self.view.frame.size.height
        }
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.txtMessage.text = languageHelper.LocalString(key: "writeComment")
        self.title = languageHelper.LocalString(key: "chatSupport")
        self.observeMessages()
        self.enterChat()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUnreadCount), name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        self.tblChat.keyboardDismissMode = .onDrag
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        if user_unread > 0 {
            self.myChatRef.child(self.getChannelName()).child("channel_info").child("user_count").setValue(0)
        }
        self.myChatRef.removeObserver(withHandle: msgObserver!)
//        self.myChatRef.child("total_chats").child(self.userData.user_id).child("user_unread").setValue("0")
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
    }
    
    
    // MARK: - Keyboard Show/Hide
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("notification: Keyboard will show")
            self.view.frame.size.height = self.viewHeight - keyboardSize.height
            self.view.layoutSubviews()
            self.tblChat.reloadData()
            DispatchQueue.main.async {
                if self.arrMessage.count > 0 {
                    self.tblChat.scrollToRow(at: IndexPath.init(row: (self.arrMessage.count - 1), section: 0), at: UITableViewScrollPosition.none, animated: false)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
                self.view.frame.size.height = self.viewHeight //+ keyboardSize.height
                self.view.layoutSubviews()
    }
    
    // MARK: - UIButton Action
    
    func getChannelName() -> String {
        let channel = "\(strAdminId)\(self.userData.user_id)"
        return channel
    }
    
    @IBAction func btnSendAction(_ sender: UIButton) {
        if (self.txtMessage.text!).trimWhitespaces == "" {
            
            return
        }
        let timestamp = "\(Int(Date().timeIntervalSince1970 * 1000))"
        let messageItem = [
            "message"       : (self.txtMessage.text)!,
            "msg_channel"   : self.getChannelName(),
            "receiver_id"   : strAdminId,
            "receiver_name" : strAdminName,
            "receiver_profile_image" : "",
            "sender_id"     : self.userData.user_id,
            "sender_name"   : self.userData.first_name,
            "sender_profile_image"  : self.userData.img,
            "time"          : timestamp
        ]
        // Send New message
        self.myChatRef.child(getChannelName()).child("messages").childByAutoId().setValue(messageItem)
        
        admin_unread = admin_unread + 1
        // Update Channel info
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("admin_count").setValue(admin_unread)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("message").setValue((self.txtMessage.text)!)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("receiver_id").setValue(strAdminId)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("receiver_name").setValue(strAdminName)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("receiver_profile_image").setValue("")
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("sender_id").setValue(self.userData.user_id)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("time").setValue(timestamp)
        
        self.txtMessage.text = ""
        self.const_textview_height.constant = 35
        if self.isShowMsg {
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: false)
        }
    }
    
    @objc func updateTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.showMessage()
    }
    
    func showMessage() {
        let timestamp = "\(Int(Date().timeIntervalSince1970 * 1000))"
        let messageItem = [
            "message"       : languageHelper.LocalString(key: "Chat_Default_Msg"),
            "msg_channel"   : self.getChannelName(),
            "receiver_id"   : self.userData.user_id,
            "receiver_name" : self.userData.first_name,
            "receiver_profile_image" : "",
            "sender_id"     : strAdminId,
            "sender_name"   : strAdminName,
            "sender_profile_image"  : self.userData.img,
            "time"          : timestamp
        ]
        // Send New message
        self.myChatRef.child(getChannelName()).child("messages").childByAutoId().setValue(messageItem)
        
//        admin_unread = admin_unread + 1
        // Update Channel info
//        self.myChatRef.child(self.getChannelName()).child("channel_info").child("admin_count").setValue(admin_unread)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("message").setValue((self.txtMessage.text)!)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("receiver_id").setValue(strAdminId)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("receiver_name").setValue(strAdminName)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("receiver_profile_image").setValue("")
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("sender_id").setValue(self.userData.user_id)
        self.myChatRef.child(self.getChannelName()).child("channel_info").child("time").setValue(timestamp)
        
        self.isShowMsg = false
    }
    
    // MARK: - Firebase Methods
    
    func observeMessages() {
        let messageQuery = self.myChatRef.child(self.getChannelName()).child("messages")
        msgObserver = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.exists() {
                if let messageData = snapshot.value as? [String:String] {
                    print(messageData)
                    self.arrMessage.append(messageData)
                    self.tblChat.reloadData()
                    DispatchQueue.main.async {
                        self.tblChat.scrollToRow(at: IndexPath.init(row: (self.arrMessage.count - 1), section: 0), at: UITableViewScrollPosition.none, animated: false)
                    }
                    if ("\(messageData["receiver_id"] ?? "")" == self.userData.user_id) {
                        if self.timer != nil {
                            self.timer?.invalidate()
                            self.timer = nil
                            self.isShowMsg = false
                        }
                    }
                }
            }
        })
    }
    
    func enterChat() {
        if user_unread > 0 {
            self.myChatRef.child(self.getChannelName()).child("channel_info").child("user_count").setValue(0)
        }
    }
    
    @objc func reloadUnreadCount() {
        if user_unread > 0 {
            self.myChatRef.child(self.getChannelName()).child("channel_info").child("user_count").setValue(0)
        }
    }
}


// MARK: -
//UITableView Delegate & Datasource
extension ChatVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDict = self.arrMessage[indexPath.row]
        let reuseId = ("\(messageDict["receiver_id"] ?? "")" == self.userData.user_id) ? "CellAdmin" : "CellUser"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! ChatCell
        cell.lblMessage.text = "\(messageDict["message"] ?? "")"
        
        let timestampe = Double("\(messageDict["time"] ?? "0.0")") ?? 0.0
        let date = Date.init(timeIntervalSince1970: (timestampe > 0 ? timestampe/1000 : timestampe))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yy HH:mm a"
        cell.lblTime.text = formatter.string(from: date)
        
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
extension ChatVC : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(sender:)))
//        self.view.addGestureRecognizer(tap)
        if self.txtMessage.text == strTextDescribe {
            self.txtMessage.text = "";
            self.txtMessage.textColor = UIColor.black;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.removeGestureRecognizer(tap)
        if self.txtMessage.text.isEmpty {
            self.txtMessage.text = strTextDescribe;
            self.txtMessage.textColor = UIColor.lightGray;
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
        if self.txtMessage.text.isEmpty {
            self.txtMessage.text = strTextDescribe;
            self.txtMessage.textColor = UIColor.lightGray;
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.location > 100 && text != "" {
            return false
        }
        
        var strText = textView.text!
        if range.length > 0 {
            let dropCount = (textView.text!.count - range.location - 1)
            strText = String(strText.dropLast(dropCount < 0 ? 0 : dropCount))
        }
        let lastText = String(strText.last ?? Character.init("0"))
        if text == "\n" {
            print("change line")
            if self.const_textview_height.constant <= 52 {
                UIView.animate(withDuration: 0.5) {
                    self.const_textview_height.constant = self.const_textview_height.constant + 17
                }
            }
        }else if lastText == "\n" && text == "" && range.length == 1 {
            let newLineCount = textView.text.components(separatedBy: "\n")
            if self.const_textview_height.constant > 47 && newLineCount.count <= 3 {
                UIView.animate(withDuration: 0.5) {
                    self.const_textview_height.constant = self.const_textview_height.constant - 17
                }
            }
        }
        return true
    }
}

class ChatCell: UITableViewCell {
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
}


//                if self.arrMessages.count > 1 {
//                    let descriptor = NSSortDescriptor.init(key: "chat_time", ascending: true)
//                    let descriptors = NSArray.init(object: descriptor)
//                    let sortedArray = self.arrMessages.sortedArray(using: descriptors as! [NSSortDescriptor]);
//                    self.arrMessages.removeAllObjects()
//                    self.arrMessages = NSMutableArray(array : sortedArray)
//                }

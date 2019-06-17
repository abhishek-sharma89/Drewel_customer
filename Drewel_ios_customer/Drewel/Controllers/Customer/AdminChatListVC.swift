//
//  AdminChatListVC.swift
//  Drewel
//
//  Created by Octal on 01/10/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AdminChatListVC: UIViewController {
    @IBOutlet weak var tblChat: UITableView!
    
    let myChatRef = Database.database().reference()
    var msgObserver: DatabaseHandle?
    
    var arrMessage = Array<[String:String]>()
    var arrUserIds = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeMessages()
        self.observeNewChats()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Firebase Methods
    
    func observeMessages() {
        let messageQuery = self.myChatRef.child("total_chats").queryOrdered(byChild: "timestamp")
        msgObserver = messageQuery.observe(.childChanged, with: { (snapshot) -> Void in
            
            if snapshot.exists() {
                if let messageData = snapshot.value as? [String:String] {
                    print(messageData)
                    let userId = snapshot.key
                    let index = self.arrUserIds.index(of: userId)
                    if self.arrMessage.count > index {
                        self.arrUserIds.removeObject(at: index)
                        self.arrMessage.remove(at: index)
                        self.arrMessage.insert(messageData, at: 0)
                        self.arrUserIds.insert(userId, at: 0)
                    }
                    self.tblChat.reloadData()
                }
            }
        })
    }
    
    func observeNewChats() {
        let messageQuery = self.myChatRef.child("total_chats").queryOrdered(byChild: "timestamp")
        msgObserver = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            if snapshot.exists() {
                if let messageData = snapshot.value as? [String:String] {
                    print(messageData)
                    let userId = snapshot.key
                    let timestamp = "\(messageData["timestamp"] ?? "")"
                    if self.arrMessage.count > 0 && timestamp != "" {
                        self.arrMessage.insert(messageData, at: 0)
                        self.arrUserIds.insert(userId, at: 0)
                    }else {
                        self.arrMessage.append(messageData)
                        self.arrUserIds.add(userId)
                    }
                    self.tblChat.reloadData()
                }
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: -
//UITableView Delegate & Datasource
extension AdminChatListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDict = self.arrMessage[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell.contentView.viewWithTag(1) as! UILabel).text = "\(messageDict["user_name"] ?? "")"
        (cell.contentView.viewWithTag(2) as! UILabel).text = "\(messageDict["admin_unread"] ?? "")"
        (cell.contentView.viewWithTag(2) as! UILabel).isHidden = (Int("\(messageDict["admin_unread"] ?? "")") ?? 0) == 0
        
        let img = "\(messageDict["user_img"] ?? "")"
        let url = URL.init(string: img)
        if (url != nil) {
            (cell.contentView.viewWithTag(11) as! UIImageView).kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "cart_big_theme"), options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage), progressBlock: nil, completionHandler: nil)
        }else {
            (cell.contentView.viewWithTag(11) as! UIImageView).image = #imageLiteral(resourceName: "cart_big_theme")
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "AdminChatVC") as! AdminChatVC
        vc.userId = "\(self.arrUserIds[indexPath.row])"
        self.navigationController?.show(vc, sender: nil)
    }
}

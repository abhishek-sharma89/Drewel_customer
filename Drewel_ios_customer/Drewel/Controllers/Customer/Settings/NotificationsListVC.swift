//
//  NotificationsListVC.swift
//  Drewel
//
//  Created by Octal on 13/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class NotificationsListVC: UIViewController {
    @IBOutlet weak var tblNotificationsList: UITableView!
    
    var userData = UserData.sharedInstance;
    var arrNotifications = Array<NotificationData>()
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "notification")
        self.getNotificationsListAPI()
    }
    
    @IBAction func btnClearAllAction(_ sender: UIButton) {
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "ALL_NOTIFICATION_DELETE_MSG"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
            self.deleteNotificationAPI(index: 0, notificationId: "")
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - WebService Method
    func getNotificationsListAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Notifications_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrNotifications.removeAll()
                
                let dict = result.removeNullValueFromDict()
                let arr = dict.value(forKey: "Notifications") as! NSArray
                
                for i in 0..<arr.count {
                    let notification = arr[i] as! NSDictionary
                    var notData = NotificationData()
                    
                    var strNote = "\(notification.value(forKey: (languageHelper.isArabic() ? "message_arabic" : "message")) ?? "")"
                    strNote = strNote.count <= 0 ? ("\(notification.value(forKey: "message") ?? "")") : strNote
                    
                    notData.id      = "\(notification.value(forKey: "id") ?? "")"
                    notData.message = strNote
                    notData.created = "\(notification.value(forKey: "created") ?? "")"
                    notData.user_id = "\(notification.value(forKey: "user_id") ?? "")"
                    notData.type    = "\(notification.value(forKey: "type") ?? "")"
                    notData.send_by = "\(notification.value(forKey: "send_by") ?? "")"
                    notData.name    = "\(notification.value(forKey: "name") ?? "")"
                    notData.is_read = "\(notification.value(forKey: "is_read") ?? "")"
                    notData.item_id = "\(notification.value(forKey: "item_id") ?? "")"
                    
                    self.arrNotifications.append(notData);
                }
                 UIApplication.shared.applicationIconBadgeNumber = Int("\(result.removeNullValueFromDict().value(forKey: "unread") ?? "0")") ?? 0
                self.tblNotificationsList.reloadData()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func readNotificationAPI(index : Int, notificationId : String) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                              "notification_id" : notificationId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Read_Notification, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrNotifications[index].is_read = "1"
                self.tblNotificationsList.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                UIApplication.shared.applicationIconBadgeNumber = Int("\(result.removeNullValueFromDict().value(forKey: "unread") ?? "0")") ?? 0
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func deleteNotificationAPI(index : Int, notificationId : String) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "notification_id" : notificationId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Notification, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                if notificationId == "" {
                    self.arrNotifications.removeAll()
                }else {
                    self.arrNotifications.remove(at: index)
                }
                self.tblNotificationsList.reloadData()
                UIApplication.shared.applicationIconBadgeNumber = Int("\(result.removeNullValueFromDict().value(forKey: "unread") ?? "0")") ?? 0
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: -
//UITableView Delegate & Datasource
extension NotificationsListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationListCell
        
        cell.lblMessage.text = self.arrNotifications[indexPath.row].message
        
        cell.backgroundColor = self.arrNotifications[indexPath.row].is_read == "0" ? UIColor.white : UIColor.groupTableViewBackground;
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = formatter.date(from: self.arrNotifications[indexPath.row].created) ?? Date()
        formatter.locale = languageHelper.getLocale()
        formatter.dateFormat = "dd MMM, yy"
        cell.lblDate.text = formatter.string(from: date)
        
        formatter.dateFormat = "hh:mm aa"
        cell.lblTime.text = formatter.string(from: date)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.readNotificationAPI(index: indexPath.row, notificationId: self.arrNotifications[indexPath.row].id)
        let type = self.arrNotifications[indexPath.row].type
        let item_id = self.arrNotifications[indexPath.row].item_id
        if type == "deliveryStatusChange" || type == "deliveryBoyAssigned" || type == "orderPlaced" || type == "orderCancelled" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderDtailsVC") as! OrderDtailsVC
            vc.orderId = item_id
            self.navigationController?.show(vc, sender: nil)
        }else if type == "productAvailable" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsTableVC
            vc.product_id = item_id
            self.navigationController?.show(vc, sender: nil)
        }else if type == "pendingCart" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "NOTIFICATION_DELETE_MSG"), preferredStyle: .alert)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
                self.deleteNotificationAPI(index: indexPath.row, notificationId: self.arrNotifications[indexPath.row].id)
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}


class NotificationListCell: UITableViewCell {
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
}

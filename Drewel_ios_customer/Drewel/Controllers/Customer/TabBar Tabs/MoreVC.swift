//
//  MoreVC.swift
//  Drewel
//
//  Created by Octal on 12/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import MessageUI
import Kingfisher

class MoreVC: BaseViewController, SetDefaultAddressDelegate {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var tblSettings: UITableView!
    
    var arrTitle = [String]()
    
    var arrImages = [String]()
    
    var isSwitchOn : Bool = true;
    var emailTitle = "Feedback"
    var messageBody = "Feature request or bug report?"
    var toRecipents = ["support@drewel.om"]
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUnreadCount), name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
        self.lblUserName.text = self.userData.first_name + " " + self.userData.last_name
        self.lblUserEmail.text = self.userData.email
        
        if self.userData.img.count > 0
        {
            self.imgUserProfile.kf.setImage(with:
                URL.init(string: self.userData.img)!,
                                            placeholder: #imageLiteral(resourceName: "appicon.png"),
                                            options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                            progressBlock: nil,
                                            completionHandler: nil)
        }
        else
        {
            self.imgUserProfile.image = #imageLiteral(resourceName: "appicon.png")
        }
        
        self.tblSettings.reloadData()
    }
    
    func setInitialValues() {
        
        if userData.user_id == "1"
        {
            arrTitle = [languageHelper.LocalString(key:"notificationSettings"),
                        languageHelper.LocalString(key:"notification"),
                        languageHelper.LocalString(key:"transactions"),
                        languageHelper.LocalString(key:"deliveryAddress"),
                        languageHelper.LocalString(key:"changeLanguage"),
                        languageHelper.LocalString(key:"changePassword"),
                        languageHelper.LocalString(key:"aboutApp"),
                        languageHelper.LocalString(key:"rateUs"),
                        languageHelper.LocalString(key:"contactUs"),
                        languageHelper.LocalString(key:"login")]
            arrImages = ["notification",
                         "notification",
                         "wallet",
                         "deliveryaddress",
                         "changelanguage",
                         "password",
                         "aboutapp",
                         "rateapp",
                         "contactus",
                         "signout"]
        }
        else
        {
            arrTitle = [languageHelper.LocalString(key:"notificationSettings"),
                        languageHelper.LocalString(key:"notification"),
                        languageHelper.LocalString(key:"transactions"),
                        languageHelper.LocalString(key:"deliveryAddress"),
                        languageHelper.LocalString(key:"changeLanguage"),
                        languageHelper.LocalString(key:"changePassword"),
                        languageHelper.LocalString(key:"aboutApp"),
                        languageHelper.LocalString(key:"rateUs"),
                        languageHelper.LocalString(key:"contactUs"),
                        languageHelper.LocalString(key:"signOut")]
            
            arrImages = ["notification",
                         "notification",
                         "wallet",
                         "deliveryaddress",
                         "changelanguage",
                         "password",
                         "aboutapp",
                         "rateapp",
                         "contactus",
                         "signout"]
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Roboto", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]
//        self.title = languageHelper.LocalString(key: "settings")
        self.navigationItem.title = languageHelper.LocalString(key: "settings")
        self.isSwitchOn = self.userData.is_notification == "1"
        DispatchQueue.main.async {
            self.imgUserProfile.layer.cornerRadius = self.imgUserProfile.bounds.size.width/2
        }
    }
    
    @objc func reloadUnreadCount() {
        self.tblSettings.reloadData()
    }
    
    //MARK: - Action Method
    @IBAction func btnSwitchNotificaiton(_ sender: UISwitch) {
        
        if userData.user_id == "1"
        {
            UserDefaults.standard.set(false, forKey: kAPP_SOCIAL_LOG)
            UserDefaults.standard.set(false, forKey: kAPP_IS_LOGEDIN)
            UserDefaults.standard.removeObject(forKey: kDefaultAddress)
            UserDefaults.standard.synchronize()
            let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ViewController")
            UIApplication.shared.keyWindow?.rootViewController = vc
            
            return
        }
        
        let alert = UIAlertController(title: kAPPName, message: self.isSwitchOn ? languageHelper.LocalString(key: "Notifications_Off") : languageHelper.LocalString(key: "Notifications_On"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
            self.isSwitchOn = sender.isOn;
            self.changeNotificatonStatusAPI()
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: { _ in
            sender.isOn = self.isSwitchOn
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - SetDefaultAddress Delegate
    
    func seDefaultAddress(dict: NSDictionary) {
        UserDefaults.standard.set(dict, forKey: kDefaultAddress)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - WebService Method
    func logoutUserAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Logout_User, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                UserDefaults.standard.set(false, forKey: kAPP_SOCIAL_LOG)
                UserDefaults.standard.set(false, forKey: kAPP_IS_LOGEDIN)
                UserDefaults.standard.removeObject(forKey: kDefaultAddress)
                UserDefaults.standard.synchronize()
                let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ViewController")
                UIApplication.shared.keyWindow?.rootViewController = vc
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func changeNotificatonStatusAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "is_notification" : self.isSwitchOn ? "on" : "off"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Notification_Status, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.tblSettings.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                
                self.userData.is_notification = self.isSwitchOn ? "1" : "0"
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.isSwitchOn ? "1" : "0", forKey: "is_notification")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
            }else {
                self.isSwitchOn = !self.isSwitchOn
                self.tblSettings.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func startChatAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Add_Chat, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                vc.strAdminId = "\(result.removeNullValueFromDict().value(forKey: "admin_id") ?? "1")"
                self.navigationController?.show(vc, sender: nil)
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
extension MoreVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.row == 0 {
            (cell.contentView.viewWithTag(4) as! UISwitch).isOn = self.isSwitchOn
            (cell.contentView.viewWithTag(4) as! UISwitch).addTarget(self, action: #selector(btnSwitchNotificaiton(_:)), for: .valueChanged)
        }
        (cell.contentView.viewWithTag(11) as! UIImageView).image = UIImage.init(named: self.arrImages[indexPath.row])
        (cell.contentView.viewWithTag(4) as! UISwitch).isHidden = indexPath.row > 0
        (cell.contentView.viewWithTag(2) as! UILabel).text = arrTitle[indexPath.row];
        (cell.contentView.viewWithTag(5) as! UILabel).text = "\(UIApplication.shared.applicationIconBadgeNumber)"
        (cell.contentView.viewWithTag(5) as! UILabel).isHidden = !(((UIApplication.shared.applicationIconBadgeNumber) > 0 && indexPath.row == 1) || (user_unread > 0 && indexPath.row == 8))
        if indexPath.row == 8 {
            (cell.contentView.viewWithTag(5) as! UILabel).text = "\(user_unread)"
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell.contentView.viewWithTag(4) as! UISwitch).transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if userData.user_id == "1" && indexPath.row != 6
        {
            UserDefaults.standard.set(false, forKey: kAPP_SOCIAL_LOG)
            UserDefaults.standard.set(false, forKey: kAPP_IS_LOGEDIN)
            UserDefaults.standard.removeObject(forKey: kDefaultAddress)
            UserDefaults.standard.synchronize()
            let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ViewController")
            UIApplication.shared.keyWindow?.rootViewController = vc
            
            return
        }
        
        
        if indexPath.row == 1 {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "NotificationsListVC")
            self.navigationController?.show(vc, sender: nil)
        }else if indexPath.row == 2 {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
            self.navigationController?.show(vc, sender: self)
        }else if indexPath.row == 3 {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "SearchAddressVC") as! SearchAddressVC
            vc.delegate = self
            self.navigationController?.show(vc, sender: self)
        }else if indexPath.row == 4 {
            let alert = UIAlertController(title: nil, message: languageHelper.LocalString(key: "selectLanguage"), preferredStyle: .actionSheet)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "English"), style: UIAlertActionStyle.default) { _ in
                if languageHelper.isArabic() {
                    languageHelper.changeLanguageTo(lang: "en")
                    UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabControllerCustomer")
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Arabic"), style: UIAlertActionStyle.default) { _ in
                if !languageHelper.isArabic() {
                    languageHelper.changeLanguageTo(lang: "ar")
                    UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabControllerCustomer")
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else if indexPath.row == 5 {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ChangePasswordVC")
            self.navigationController?.show(vc, sender: nil)
        }else if indexPath.row == 6 {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "AboutUsVC")
            self.navigationController?.show(vc, sender: nil)
        }else if indexPath.row == 7 {
//            https://itunes.apple.com/us/app/octalworld/id1317776331?ls=1&mt=8
//            UIApplication.shared.openURL(NSURL(string: "itms://itunes.apple.com/us/app/octalworld/id1317776331?ls=1&mt=8")!)
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1317776331"),
                UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else if indexPath.row == 8 {
            
            let alert = UIAlertController(title: nil, message: languageHelper.LocalString(key: "contactUs"), preferredStyle: .actionSheet)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "callUs"), style: UIAlertActionStyle.default) { _ in
                var str = "tel://+96892227392"
                str = str.replacingOccurrences(of: " ", with: "")
                
                if let url = URL(string: str), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "mailUs"), style: UIAlertActionStyle.default) { _ in
                let mc: MFMailComposeViewController? = MFMailComposeViewController()
                mc?.mailComposeDelegate = self
                mc?.setSubject(self.emailTitle)
                mc?.setMessageBody(self.messageBody, isHTML: false)
                mc?.setToRecipients(self.toRecipents)
                
                if (mc != nil) {
                    self.present(mc!, animated: true, completion: nil)
                }
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "chatUs"), style: UIAlertActionStyle.default) { _ in
                self.startChatAPI()
            })
            
//            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Admin Chat"), style: UIAlertActionStyle.default) { _ in
//                self.navigationController?.show(kStoryboard_Customer.instantiateViewController(withIdentifier: "AdminChatListVC"), sender: nil)
//            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }else if indexPath.row == 9 {
            
            let alert = UIAlertController(title: nil, message: languageHelper.LocalString(key: "MESSAGE_LOGOUT"), preferredStyle: .alert)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
                self.logoutUserAPI()
            })
            
            self.present(alert, animated: true, completion: nil)
            print("alert")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MoreVC : MFMailComposeViewControllerDelegate  {
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error?.localizedDescription ?? "error")")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

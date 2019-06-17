//
//  FirstVC.swift
//  Drewel
//
//  Created by Octal on 27/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Kingfisher

class FirstVC: UIViewController {
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var collectionTutorial: UICollectionView!
    @IBOutlet weak var pageControllBanner: UIPageControl!
    @IBOutlet weak var btnSkip: UIButton!

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
    
    func setInitialValues() {
        let sd = DispatchIO.IntervalFlags.ArrayLiteralElement.self
        print(sd)
        DispatchQueue.main.async {
            self.btnRegister.layer.cornerRadius = self.btnRegister.frame.size.height/2
            self.btnLogin.layer.cornerRadius = self.btnLogin.frame.size.height/2
            self.btnFacebook.layer.cornerRadius = self.btnFacebook.frame.size.height/2
            self.setupLayout()
        }
    }
    
    // MARK: - UIButton Action
    
    @IBAction func btnSkipAction(_ sender: UIButton)
    {
        let userData = UserData.sharedInstance;
        userData.user_id            = "1"
        userData.first_name         = ""
        userData.last_name          = ""
        userData.mobile_number      = ""
        userData.role_id            = "2"
        userData.email              = ""
        userData.latitude           = ""
        userData.longitude          = ""
        userData.img                = ""
        userData.modified           = ""
        userData.is_notification    = ""
        userData.remember_token     = ""
        userData.is_mobileverify    = ""
        userData.fb_id              = ""
        userData.country_code       = ""
        userData.cart_id            = ""
        userData.cart_quantity      = ""
        
        userData.address_name       = ""
        userData.address_longitude  = ""
        userData.address_latitude   = ""
        userData.address            = ""
        
        userData.landmark           = ""
        userData.full_address       = ""
        userData.address_id         = ""
        userData.user_name          = ""
        userData.user_mobile        = ""
        userData.zip_code           = ""
        userData.delivery_address_type = ""
        
        if userData.role_id == "2" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "tabControllerCustomer")
            UIApplication.shared.keyWindow?.rootViewController = vc
        }else {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "tabControllerCustomer")
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    
    
    @IBAction func btnChangeLanguageAction(_ sender: UIButton) {
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "selectLanguage"), preferredStyle: .actionSheet)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "English"), style: UIAlertActionStyle.default) { _ in
            if languageHelper.isArabic() {
                languageHelper.changeLanguageTo(lang: "en")
                UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Arabic"), style: UIAlertActionStyle.default) { _ in
            if !languageHelper.isArabic() {
                languageHelper.changeLanguageTo(lang: "ar")
                UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
//        languageHelper.changeLanguageTo(lang: languageHelper.isArabic() ? "en" : "ar")
//        UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
//        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "register", sender: nil);
    }
    
    @IBAction func btnLoginAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "login", sender: nil);
    }
    
    @IBAction func btnFacebookLoginAction(_ sender: UIButton) {
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) -> Void in
//            if error != nil {
//                print(error?.localizedDescription ?? "")
//                self.getFBUserInfo()
//                self.dismiss(animated: true, completion: nil)
//            } else if (result?.isCancelled)! {
//                print("Cancelled")
//                self.dismiss(animated: true, completion: nil)
//            } else
//            {
//                self.getFBUserInfo()
//            }
//        }
        
        let facebook = Facebook()
        facebook.controller = self
        facebook.getFields = ["fields": "id, name, first_name, last_name, email"]
        facebook.logIn(success: { (accessToken, responseDic) in
            print(responseDic)
            let signupDict : NSDictionary = ["email" : responseDic["email"] as? String ?? "", "id": (responseDic["id"] as? String)!, "fname" : (responseDic["first_name"] as? String) ?? "", "lname" : (responseDic["last_name"] as? String) ?? "", "type" : "fb"]
            
            let dict : NSDictionary = ["device_id": UserDefaults.standard.value(forKey: kAPP_DEVICE_ID) as? String ?? "ksbjiojgr3q904tjdfg834jnelr834laj809239fjs",
                                       "device_type":kAPP_DEVICETYPE,
                                       "fb_id":(responseDic["id"] as? String)!,
                                       "language":languageHelper.language]
            
            self.socialLoginAPI(dict: dict,signupDict: signupDict)
            
        }) { (responseDic) in
            print(responseDic)
        }
    }
    
    //MARK: - FB Login
    
    func getFBUserInfo() {
        //        appConfig.ShowHud()
//        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,first_name, last_name,email,picture"]).start(completionHandler: { (connection, result, error) -> Void in
//            if (error == nil) {
//                let fbDetails = result as! NSDictionary
//                print("fb result:\(fbDetails)")
//                //                self.profilePic = "\("https://graph.facebook.com/\((fbDetails.value(forKey: "id") as? String)!)/picture?type=large")"
//                let signupDict : NSDictionary = ["email" : fbDetails.value(forKey: "email") as? String ?? "", "id": (fbDetails.value(forKey: "id") as? String)!, "fname" : (fbDetails.value(forKey: "first_name") as? String) ?? "", "lname" : (fbDetails.value(forKey: "last_name") as? String) ?? "", "type" : "fb"]
//
//                let dict : NSDictionary = ["device_id": UserDefaults.standard.value(forKey: kAPP_DEVICE_ID) as? String ?? "ksbjiojgr3q904tjdfg834jnelr834laj809239fjs",
//                                           "device_type":kAPP_DEVICETYPE,
//                                           "fb_id":(fbDetails.value(forKey: "id") as? String)!,
//                                           "language":languageHelper.language]
//
//                self.socialLoginAPI(dict: dict,signupDict: signupDict)
//            }else{
//
//            }
//        })
        
        let facebook = Facebook()
        facebook.controller = self
        facebook.getFields = ["fields": "id, name, first_name, last_name, email"]
        facebook.logIn(success: { (accessToken, responseDic) in
            print(responseDic)
            let signupDict : NSDictionary = ["email" : responseDic["email"] as? String ?? "", "id": (responseDic["id"] as? String)!, "fname" : (responseDic["first_name"] as? String) ?? "", "lname" : (responseDic["last_name"] as? String) ?? "", "type" : "fb"]
            
            let dict : NSDictionary = ["device_id": UserDefaults.standard.value(forKey: kAPP_DEVICE_ID) as? String ?? "ksbjiojgr3q904tjdfg834jnelr834laj809239fjs",
                                       "device_type":kAPP_DEVICETYPE,
                                       "fb_id":(responseDic["id"] as? String)!,
                                       "language":languageHelper.language]
            
            self.socialLoginAPI(dict: dict,signupDict: signupDict)
            
        }) { (responseDic) in
            print(responseDic)
        }
    }
    
    // MARK: - WebService Method
    
    func socialLoginAPI(dict: NSDictionary, signupDict : NSDictionary) {
        HelperClass.requestForAllApiWithBody(param: dict, serverUrl: kURL_Social_Login, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
                let dict : NSMutableDictionary = result.removeNullValueFromDict().mutableCopy() as! NSMutableDictionary
                let userData = UserData.sharedInstance;
                userData.user_id            = "\(dict.value(forKey: "user_id") ?? "")"
                userData.first_name         = "\(dict.value(forKey: "first_name") ?? "")"
                userData.last_name          = "\(dict.value(forKey: "last_name") ?? "")"
                userData.mobile_number      = "\(dict.value(forKey: "mobile_number") ?? "")"
                userData.role_id            = "\(dict.value(forKey: "role_id") ?? "")"
                userData.email              = "\(dict.value(forKey: "email") ?? "")"
                userData.latitude           = "\(dict.value(forKey: "latitude") ?? "")"
                userData.longitude          = "\(dict.value(forKey: "longitude") ?? "")"
                userData.img                = "\(dict.value(forKey: "img") ?? "")"
                userData.modified           = "\(dict.value(forKey: "modified") ?? "")"
                userData.is_notification    = "\(dict.value(forKey: "is_notification") ?? "")"
                userData.remember_token     = "\(dict.value(forKey: "remember_token") ?? "")"
                userData.is_mobileverify    = "\(dict.value(forKey: "is_mobileverify") ?? "")"
                userData.fb_id              = "\(dict.value(forKey: "fb_id") ?? "")"
                userData.country_code       = "\(dict.value(forKey: "country_code") ?? "")"
                userData.cart_id            = "\(dict.value(forKey: "cart_id") ?? "")"
                userData.cart_quantity      = "\(dict.value(forKey: "cart_quantity") ?? "")"
                
                userData.address_name       = "\(dict.value(forKey: "address_name") ?? "")"
                userData.address_longitude  = "\(dict.value(forKey: "address_longitude") ?? "")"
                userData.address_latitude   = "\(dict.value(forKey: "address_latitude") ?? "")"
                userData.address            = "\(dict.value(forKey: "address") ?? "")"
                
                userData.landmark           = "\(dict.value(forKey: "landmark") ?? "")"
                userData.full_address       = "\(dict.value(forKey: "full_address") ?? "")"
                userData.address_id         = "\(dict.value(forKey: "address_id") ?? "")"
                userData.user_name          = "\(dict.value(forKey: "user_name") ?? "")"
                userData.user_mobile        = "\(dict.value(forKey: "user_mobile") ?? "")"
                userData.zip_code           = "\(dict.value(forKey: "zip_code") ?? "")"
                userData.delivery_address_type = "\(dict.value(forKey: "delivery_address_type") ?? "")"
                
                UserDefaults.standard.set(false, forKey: kAPP_SOCIAL_LOG)
                UserDefaults.standard.set(true, forKey: kAPP_IS_LOGEDIN)
                helper.saveDataToDefaults(dataObject: dict, key: kAPPUSERDATA)
                
                
                if userData.role_id == "2" {
                    let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "tabControllerCustomer")
                    UIApplication.shared.keyWindow?.rootViewController = vc
                }else {
                    let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "tabControllerCustomer")
                    UIApplication.shared.keyWindow?.rootViewController = vc
                }
                
            }else {
                self.performSegue(withIdentifier: "register", sender: signupDict);
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "register" {
            let vc = segue.destination as! SignupVC
            vc.isFromLogin = false
            vc.isSocialLogin = false
            if sender != nil {
                vc.isSocialLogin = true;
                vc.socialSignupDict = sender as! NSDictionary
            }
        }
    }
 

}

// MARK: -
// UICollectionView Delegate & Datasource
extension FirstVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let strURL =  ""
        if !strURL.isEmpty {
            (cell.viewWithTag(11) as! UIImageView).kf.setImage(with: URL.init(string: strURL)!,
                                                               placeholder: #imageLiteral(resourceName: "appicon.png"),
                                                               options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                                               progressBlock: nil,
                                                               completionHandler: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControllBanner.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    fileprivate func setupLayout() {
        //setup collection view layout
        let cellWidth = (self.collectionTutorial.frame.size.width);
        let cellheight : CGFloat = (self.collectionTutorial.frame.size.height);
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = self.collectionTutorial.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        self.collectionTutorial.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControllBanner.currentPage = self.collectionTutorial.indexPathsForVisibleItems[0].row
    }

}

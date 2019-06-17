//
//  LoginVC.swift
//  Drewel
//
//  Created by Octal on 27/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate, SetEmailAddressDelegate {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowPass: UIButton!
    
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
        self.title = languageHelper.LocalString(key: "Login")
    }
    
    func setEmailAddress(userName: String) {
        DispatchQueue.main.async {
            self.txtEmail.becomeFirstResponder()
            self.txtEmail.text = userName
            self.txtEmail.resignFirstResponder()
        }
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnChangeLanguageAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnShowPasswordAction(_ sender: UIButton) {
        if sender.tag == 0 {
            self.txtPassword.isSecureTextEntry = false
            self.btnShowPass.setImage(#imageLiteral(resourceName: "eye_password"), for: .normal)
            sender.tag = 1
        }else {
            self.txtPassword.isSecureTextEntry = true
            self.btnShowPass.setImage(#imageLiteral(resourceName: "show_pass"), for: .normal)
            sender.tag = 0
        }
    }
    
    @IBAction func btnLoginAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (self.txtEmail.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_LENGTH"), title: kAPPName)
        }else if !(self.txtEmail.text?.isEmail)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_VALID"), title: kAPPName)
        }else if (self.txtPassword.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "PASS_ENTER"), title: kAPPName)
        }else if !HelperClass.isValidPassword(self.txtPassword.text!) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "PASS_VALID"), title: kAPPName)
        }else {
            self.loginAPI()
        }
    }
    
    @IBAction func btnForgotPasswordAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "resetPassword", sender: nil)
    }
    
    @IBAction func btnSignupAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "register", sender: nil)
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtEmail {
            self.txtPassword.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.txtEmail {
            if range.location >= 55 {
                return false
            }
        }else if textField == self.txtPassword {
            if range.location >= 35 {
                return false
            }else if string == " " {
                return false
                
            }
        }
        return true;
    }
    
    // MARK: - WebService Method
    func loginAPI() {
        let param : NSDictionary = ["device_id": UserDefaults.standard.value(forKey: kAPP_DEVICE_ID) as? String ?? "0000",
                                    "device_type":kAPP_DEVICETYPE,
                                    "email": self.txtEmail.text ?? "",
                                    "password" : self.txtPassword.text ?? "",
                                    "language": languageHelper.isArabic() ? "ara" : "eng"]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Login, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let otp = (result.value(forKey: "authotp") as? String ?? "")
                if !otp.isEmpty {
                    self.performSegue(withIdentifier: "verifyOtp", sender: result)
                }else {
                    
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
                }
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "register" {
            let vc = segue.destination as! SignupVC
            vc.isFromLogin = true
            vc.isSocialLogin = false
        }else if segue.identifier == "verifyOtp" {
            let vc = segue.destination as! VerifyOtpVC
            if sender != nil {
                vc.userDict = sender as! NSDictionary
            }
        }else if segue.identifier == "resetPassword" {
            let vc = segue.destination as! ForgotPasswordVC
            vc.delegate = self
        }
    }
    

}

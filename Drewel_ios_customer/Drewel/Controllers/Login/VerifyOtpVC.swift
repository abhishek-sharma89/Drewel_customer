//
//  VerifyOtpVC.swift
//  Drewel
//
//  Created by Octal on 28/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

protocol TextDeleteDelegate {
    func deleteFromKeyboard(txtField : UITextField);
}

@objc protocol VerifyOtpDelegate
{
    func OtpVerification(success : Bool)
}

class OtpTextField: UITextField {
    var delegete : TextDeleteDelegate!
    override func deleteBackward() {
        if self.delegete != nil {
            self.delegete.deleteFromKeyboard(txtField: self)
        }
        super.deleteBackward()
    }
}

class VerifyOtpVC: UIViewController , UITextFieldDelegate, TextDeleteDelegate {
    
    @IBOutlet weak var txtOtp: UITextField!
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var txtOtp2: UITextField!
    @IBOutlet weak var txtOtp3: OtpTextField!
    @IBOutlet weak var txtOtp4: OtpTextField!
    @IBOutlet weak var txtOtp5: OtpTextField!
    
    @IBOutlet weak var btnResendOtp: UIButton!
    
    @IBOutlet weak var lblTimerText: UILabel!
    @IBOutlet weak var viewTimerLabel: UIView!
    
    var delegete : VerifyOtpDelegate!
    
    var userDict = NSDictionary();
    var otp = String()
    
    var timer = Timer()
    var endTime = Date()
    
    var isSocialLogin = Bool()
    
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
        self.title = languageHelper.LocalString(key: "enterOtp")
        
        self.viewMain.semanticContentAttribute = .forceLeftToRight
        
        self.otp = (self.userDict.value(forKey: "authotp") as? String ?? "")
//        self.txtOtp.text = self.otp
//        self.setOTP()
        
        self.txtOtp3.delegete = self
        self.txtOtp4.delegete = self
        self.txtOtp5.delegete = self
        
        endTime = Date().addingTimeInterval(61)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setTimerData), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func setOTP() {
        let str1Arr = Array(self.otp.characters)
        
        self.txtOtp2.text = "\(str1Arr[0])"
        self.txtOtp3.text = "\(str1Arr[1])"
        self.txtOtp4.text = "\(str1Arr[2])"
        self.txtOtp5.text = "\(str1Arr[3])"
    }
    
    func clearOTP() {
        self.txtOtp2.text = ""
        self.txtOtp3.text = ""
        self.txtOtp4.text = ""
        self.txtOtp5.text = ""
    }
    
    func otpString() -> String {
        return (self.txtOtp2.text! + self.txtOtp3.text! + self.txtOtp4.text! + self.txtOtp5.text!);
    }
    
    @objc func setTimerData() {
        let time : Int = Int(endTime.timeIntervalSince(Date()))
        if time <= 0 {
            timer.invalidate()
            self.btnResendOtp.isHidden = false
//            self.btnResendOtp.setTitleColor(kThemeColor2, for: .normal)
//            self.btnResendOtp.setTitle(languageHelper.LocalString(key: "resendCode"), for: .normal)
            self.viewTimerLabel.isHidden = time <= 0
        }else {
            self.lblTimerText.text = "\(Int(time)) \(languageHelper.LocalString(key: "seconds"))"
        }
    }
    
    func deleteFromKeyboard(txtField: UITextField) {
        switch txtField.tag {
        case 4:
            if (txtField.text?.isEmpty)! {
                self.txtOtp4.text = ""
                self.txtOtp4.becomeFirstResponder()
            }
        case 3:
            if (txtField.text?.isEmpty)! {
                self.txtOtp3.text = ""
                self.txtOtp3.becomeFirstResponder()
            }
        case 2:
            if (txtField.text?.isEmpty)! {
                self.txtOtp2.text = ""
                self.txtOtp2.becomeFirstResponder()
            }
        default:
            txtField.text = ""
        }
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnChangeLanguageAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnShowPasswordAction(_ sender: UIButton) {
        if sender.tag == 0 {
            self.txtOtp.isSecureTextEntry = false
            sender.tag = 1
        }else {
            self.txtOtp.isSecureTextEntry = true
            sender.tag = 0
        }
    }
    
    @IBAction func btnResendOtpAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.resendOtpAPI()
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.otpString().isEmpty {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key:"OTP_LENGTH"), title: kAPPName)
        }else if self.otp != self.otpString() {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key:"VALID_OTP"), title: kAPPName)
        }else {
            self.verifyAPI()
        }
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            self.txtOtp2.becomeFirstResponder()
        case 2:
            self.txtOtp3.becomeFirstResponder()
        case 3:
            self.txtOtp4.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        //        if textField == self.txtOtp1 || textField == self.txtOtp2 || textField == self.txtOtp3 || textField == self.txtOtp4 {
        if range.location >= 1 {
            return false
        }else if string == " " {
            return false
        }
        //        }
        if range.length == 0 {
            DispatchQueue.main.async {
                switch textField.tag {
                case 1:
                    self.txtOtp3.becomeFirstResponder()
                case 2:
                    self.txtOtp4.becomeFirstResponder()
                case 3:
                    self.txtOtp5.becomeFirstResponder()
                default:
                    textField.resignFirstResponder()
                }
            }
        }else {
            print("Location : \(range.location)")
            print("Length : \(range.length)")
        }
        return true;
    }
    
    // MARK: - WebService Method
    func verifyAPI() {
        
        
        
        let param : NSDictionary = ["mobile_number" : (self.userDict.value(forKey: "country_code") as? String ?? "") + (self.userDict.value(forKey: "mobile_number") as? String ?? ""),
                                    "user_id"       : self.userDict.value(forKey: "user_id") ?? "",
                                    "otp"           : self.otpString(),
                                    "language"      : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Verify_Otp, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                if (self.delegete != nil) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegete.OtpVerification(success: true)
                    return
                }
                
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
                
                UserDefaults.standard.set(self.isSocialLogin, forKey: kAPP_SOCIAL_LOG)
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
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func resendOtpAPI() {
        let param : NSDictionary = ["user_id"       : self.userDict.value(forKey: "user_id") ?? "",
                                    "language"      : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Resend_Otp, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
                self.endTime = Date().addingTimeInterval(61)
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setTimerData), userInfo: nil, repeats: true)
                self.timer.fire()
                self.btnResendOtp.isHidden = true
                self.viewTimerLabel.isHidden = false
                
                
                self.otp = (result.value(forKey: "authotp") as? String ?? "")
//                self.txtOtp.text = ""
                self.clearOTP()
//                self.setOTP()
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
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

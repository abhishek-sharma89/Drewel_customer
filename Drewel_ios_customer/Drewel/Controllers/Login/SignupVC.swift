//
//  SignupVC.swift
//  Drewel
//
//  Created by Octal on 28/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class SignupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtCountryCode: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var btnShowPass: UIButton!
    @IBOutlet weak var const_btnSignup_top: NSLayoutConstraint!
    
    @IBOutlet weak var btnShowConfirmPass: UIButton!
    
    @IBOutlet weak var viewPasswordBorder: UIView!
    @IBOutlet weak var viewConfirmPassBorder: UIView!
    
    // MARK: - Properties
    var isFromLogin = Bool()
    var isSocialLogin = Bool()
    var socialSignupDict = NSDictionary();
    var fb_Id = ""
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
        if isSocialLogin {
            self.hidePasswordForSocialLogin()
            self.showSocialSignupData()
        }
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "signup")
    }
    
    func hidePasswordForSocialLogin() {
        self.txtPassword.isHidden = true
        self.txtConfirmPassword.isHidden = true
        self.viewPasswordBorder.isHidden = true
        self.viewConfirmPassBorder.isHidden = true
        self.btnShowPass.isHidden = true
        self.btnShowConfirmPass.isHidden = true
        self.const_btnSignup_top.constant = ((self.txtPassword.frame.size.height + 10) * -2)
    }
    
    func showSocialSignupData() {
        self.txtFirstName.text = socialSignupDict.value(forKey: "fname") as? String ?? "";
        self.txtLastName.text = socialSignupDict.value(forKey: "lname") as? String ?? "";
        self.txtEmail.text = socialSignupDict.value(forKey: "email") as? String ?? "";
        self.fb_Id = socialSignupDict.value(forKey: "id") as? String ?? "";
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
        if isFromLogin {
            self.navigationController?.popViewController(animated: true)
        }else {
            let navVC = self.navigationController!
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.navigationController?.popToRootViewController(animated: false)
            navVC.pushViewController(vc!, animated: false)
        }
    }
    
    @IBAction func btnShowConfirmPasswordAction(_ sender: UIButton) {
        if sender.tag == 0 {
            self.txtConfirmPassword.isSecureTextEntry = false
            self.btnShowConfirmPass.setImage(#imageLiteral(resourceName: "eye_password"), for: .normal)
            sender.tag = 1
        }else {
            self.txtConfirmPassword.isSecureTextEntry = true
            self.btnShowConfirmPass.setImage(#imageLiteral(resourceName: "show_pass"), for: .normal)
            sender.tag = 0
        }
    }
    
    @IBAction func btnSignupAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        let txtFrstName = self.txtFirstName.text?.replacingOccurrences(of: " ", with: "")
        let txtLstName = self.txtLastName.text?.replacingOccurrences(of: " ", with: "")
        
        if (txtFrstName?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "FNAME_LENGTH"), title: kAPPName)
        }else if (txtLstName?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "LNAME_LENGTH"), title: kAPPName)
        }else if (strPhone.isEmpty)  {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_LENGTH"), title: kAPPName)
        }else if !(strPhone.trimWhitespaces.isPhoneNumber) || (strPhone.count) < 8 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_VALID"), title: kAPPName)
        }else if (self.txtEmail.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_LENGTH"), title: kAPPName)
        }else if !(self.txtEmail.text?.isEmail)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_VALID"), title: kAPPName)
        }else if (self.txtPassword.text?.isEmpty)! && !self.isSocialLogin {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "PASS_ENTER"), title: kAPPName)
        }else if !HelperClass.isValidPassword(self.txtPassword.text!) && !self.isSocialLogin {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "PASS_VALID"), title: kAPPName)
        }else if (self.txtConfirmPassword.text?.isEmpty)! && !self.isSocialLogin {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "RE_PASS_ENTER"), title: kAPPName)
        }else if (self.txtPassword.text)! != (self.txtConfirmPassword.text)! && !self.isSocialLogin {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "REPASS_VALID"), title: kAPPName)
        }else {
            self.signupAPI()
//            self.performSegue(withIdentifier: "verifyOtp", sender: nil)
        }
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.txtFirstName || textField == self.txtLastName {
            if range.location >= 35 && string != "" {
                return false
            }
            if string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string == "" || string == " " || string == "-" {
                return true
            }else {
                return false
            }
        }else if textField == self.txtCountryCode {
            if range.location >= 3 {
                return false
            }
        }else if textField == self.txtPhoneNumber {
            if range.location >= 10 && string != "" {
                return false
            }else if !(string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string == "") {
                return false
            }
        }else if textField == self.txtEmail {
            if range.location >= 55 {
                return false
            }
        }else if textField == self.txtPassword || textField == self.txtConfirmPassword {
            if range.location >= 35 {
                return false
            }
        }
        return true;
    }
    
    // MARK: - WebService Method
    func signupAPI() {
        var strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        strPhone = strPhone.replacingOccurrences(of: "+", with: "")
        strPhone = strPhone.replacingOccurrences(of: "-", with: "")
        strPhone = strPhone.replacingOccurrences(of: "(", with: "")
        strPhone = strPhone.replacingOccurrences(of: ")", with: "")
        strPhone = strPhone.count > 10 ? String(strPhone.dropFirst(10 - strPhone.count)) : strPhone
        
        let param : NSDictionary = ["device_id": UserDefaults.standard.value(forKey: kAPP_DEVICE_ID) as? String ?? "0000",
            "device_type"   : kAPP_DEVICETYPE,
            "first_name"    : (self.txtFirstName.text)!,
            "last_name"     : (self.txtLastName.text)!,
            "mobile_number" : strPhone,
            "password"      : (self.txtPassword.text)!,
            "role_id"       : "2",
            "fb_id"         : self.fb_Id,
            "email"         : self.txtEmail.text ?? "",
            "country_code"  : (self.txtCountryCode.text)!,
            "password"      : self.txtPassword.text ?? "",
            "language"      : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Signup, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.performSegue(withIdentifier: "verifyOtp", sender: result)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifyOtp" {
            let vc = segue.destination as! VerifyOtpVC
            vc.isSocialLogin = self.isSocialLogin
            if sender != nil {
                vc.userDict = sender as! NSDictionary
            }
        }
    }
    

}

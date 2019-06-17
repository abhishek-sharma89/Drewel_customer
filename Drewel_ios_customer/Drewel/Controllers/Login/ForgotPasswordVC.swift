//
//  ForgotPasswordVC.swift
//  Drewel
//
//  Created by Octal on 28/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

@objc protocol SetEmailAddressDelegate
{
    func setEmailAddress(userName : String);
}

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    
    var delegate: SetEmailAddressDelegate? = nil
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
        self.title = languageHelper.LocalString(key: "forgotPassword")
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (self.txtEmail.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_LENGTH"), title: kAPPName)
        }else if !(self.txtEmail.text?.isEmail)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_VALID"), title: kAPPName)
        }else {
            self.verifyAPI()
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
        if textField == self.txtEmail {
            if range.location >= 65 {
                return false
            }
        }
        return true;
    }
    
    // MARK: - WebService Method
    func verifyAPI() {
        let param : NSDictionary = ["email"         : self.txtEmail.text ?? "",
                                    "language"      : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Forget_pass, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let vc = self.parent
                self.delegate?.setEmailAddress(userName: self.txtEmail.text!)
                self.navigationController?.popViewController(animated: false)
                HelperClass.showPopupAlertController(sender: vc != nil ? vc! : self, message: message, title: kAPPName)
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

//
//  ChangePasswordVC.swift
//  Drewel
//
//  Created by Octal on 23/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit


class ChangePasswordVC: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var lblOldPassword: UITextField!
    @IBOutlet weak var lblNewPassword: UITextField!
    @IBOutlet weak var lblRePassword: UITextField!
    
    
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
        self.title = languageHelper.LocalString(key: "changePassword")
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSubmitPasswordAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (self.lblOldPassword.text?.count)! <= 0 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "Old_PASS_ENTER"), title: kAPPName)
        }else if !HelperClass.isValidPassword(self.lblNewPassword.text!) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "NEW_PASS_VALID"), title: kAPPName)
        }else if self.lblOldPassword.text == self.lblNewPassword.text {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "similarOldNNewPass"), title: kAPPName)
        }else if (self.lblRePassword.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "RE_PASS_ENTER"), title: kAPPName)
        }else if (self.lblNewPassword.text)! != (self.lblRePassword.text)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "REPASS_VALID"), title: kAPPName)
        }else {
            self.changePasswordAPI()
        }
    }
    
    // MARK: - UITextfield Delegate Method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.lblOldPassword {
            self.lblNewPassword.becomeFirstResponder()
        }else if textField == self.lblNewPassword {
            self.lblRePassword.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if range.location >= 35 && string != "" {
            return false
        }
        return true
    }
    
    // MARK: - WebService Method
    func changePasswordAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "old_password" : self.lblOldPassword.text ?? "",
                                    "new_password"  : self.lblNewPassword.text ?? ""]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Change_Password, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.navigationController?.popToRootViewController(animated: true)
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

//
//  TransferLoyaltyPointsVC.swift
//  Drewel
//
//  Created by Octal on 16/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class TransferLoyaltyPointsVC: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPoints: UITextField!
    
    
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
        self.title = languageHelper.LocalString(key:"transferLoyaltyPoints")
    }
    
    // MARK: - UIButton Actions
    @IBAction func btnSaveAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (self.txtEmail.text?.count)! <= 0 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_LENGTH"), title: kAPPName)
        }else if !(self.txtEmail.text?.isEmail)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "EMAIL_VALID"), title: kAPPName)
        }else if (self.txtPoints.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "LOYALTY_POINTS_LENGTH"), title: kAPPName)
        }else {
            self.loyaltyPointsTransferAPI()
        }
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            textField.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == self.txtEmail {
            if range.location >= 65 && string != "" {
                return false
            }
            return true
        }else if textField == self.txtPoints {
            if range.location >= 10 && string != "" {
                return false
            }
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil || string.rangeOfCharacter(from: CharacterSet.whitespaces) != nil || string == "" || string != "."  {
                return true
            }
        }else {
            return false
        }
        return false
    }
    
    // MARK: - WebService Method
    func loyaltyPointsTransferAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "email"     : self.txtEmail.text!,
                                    "loyalty_points" : self.txtPoints.text!]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Loyalty_Point_Transfer, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.navigationController?.popViewController(animated: true)
                
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
}

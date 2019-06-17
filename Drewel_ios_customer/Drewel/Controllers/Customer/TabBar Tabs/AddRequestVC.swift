//
//  AddRequestVC.swift
//  Drewel
//
//  Created by Octal on 13/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class AddRequestVC: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var txtProductName: UITextField!
    
    var requestText = String()
    var requestId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.txtProductName.text = requestText
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationItem.leftBarButtonItems = nil
        }
        self.title = languageHelper.LocalString(key: "addRequest");
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Roboto", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func btnSubmitRequirementAction(_ sender: UIButton) {
        if (self.txtProductName.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "PRODUCT_NAME_LENGTH"), title: kAPPName)
        }else {
            if requestId == "" {
                self.requestProductAPI()
            }else {
                self.editRequestProductAPI()
            }
        }
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if textField == self.txtProductName {
            if range.location >= 35 && string != "" {
                return false
            }
        }
        if string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string.rangeOfCharacter(from: CharacterSet.whitespaces) != nil || string == "" {
            return true
        }else {
            return false
        }
    }
    
    // MARK: - WebService Method
    func requestProductAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_name"  : self.txtProductName.text!]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_Required, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                if self.navigationController?.viewControllers.count == 1 {
//                    self.navigationController?.viewControllers.removeAll()
                    let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "RequestListVC")
                    self.navigationController?.setViewControllers([vc], animated: false)
                }else {
                    self.navigationController?.popViewController(animated: true)
                    HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                }
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func editRequestProductAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_name"  : self.txtProductName.text!,
                                    "request_id"    : self.requestId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Edit_Product_Request, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.navigationController?.popViewController(animated: true)
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

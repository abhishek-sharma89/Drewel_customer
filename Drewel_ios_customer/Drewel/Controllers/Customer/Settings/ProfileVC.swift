//
//  ProfileVC.swift
//  Drewel
//
//  Created by Octal on 26/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher


class ProfileVC: BaseViewController, UITextFieldDelegate, VerifyOtpDelegate {
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var viewProfilePic: UIView!
    @IBOutlet weak var btnVerify: UIButton!
    
    
    var isVerified = false
    var isProfilePicChanged = false
    
    // MARK: - VC Life Cycel
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
        
        self.setInitialValues()
        self.txtPhoneNumber.superview?.semanticContentAttribute = .forceLeftToRight
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
        self.title = languageHelper.LocalString(key: "myProfile")
        self.setDataOnTextFields()
        DispatchQueue.main.async {
            self.viewProfilePic.cornerRadius = self.viewProfilePic.frame.size.height/2
        }
    }
    
    func setDataOnTextFields() {
        self.txtFirstName.text = self.userData.first_name
        self.txtLastName.text = self.userData.last_name
        self.txtPhoneNumber.text = self.userData.mobile_number
        self.txtEmail.text = self.userData.email
        self.imgProfile.kf.setImage(with:
            URL.init(string: self.userData.img)!,
                                   placeholder: #imageLiteral(resourceName: "appicon.png"),
                                   options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                   progressBlock: nil,
                                   completionHandler: nil)
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        if (self.txtFirstName.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "FNAME_LENGTH"), title: kAPPName)
        }else if (self.txtLastName.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "LNAME_LENGTH"), title: kAPPName)
        }else if (strPhone.isEmpty) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_LENGTH"), title: kAPPName)
        }else if !(strPhone.trimWhitespaces.isPhoneNumber) || (strPhone.count) < 8  {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_VALID"), title: kAPPName)
        }else if self.userData.mobile_number != (strPhone) && !isVerified {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_NOT_VERIFIED"), title: kAPPName)
        }else {
            self.btnVerify.isHidden = true
            self.saveUpdatedProfileAPI()
        }
    }
    
    @IBAction func btnChangeProfilePicAction(_ sender: UIButton) {
        self.selectMedia()
    }
    
    @IBAction func btnVerifyAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        if (strPhone.isEmpty) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_LENGTH"), title: kAPPName)
        }else if !(strPhone.isPhoneNumber) || (strPhone.count) < 8  {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_VALID"), title: kAPPName)
        }else {
            if self.userData.mobile_number != (strPhone) {
                self.verifyMobileAPI()
            }
        }
    }
    
    // MARK: - UITextfield Delegate4
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if textField == self.txtFirstName {
            if range.location >= 35 && string != "" {
                return false
            }
        }else if textField == self.txtLastName {
            if range.location >= 35 && string != "" {
                return false
            }
        }else if textField == self.txtPhoneNumber {
            if range.location >= 10 && string != "" {
                return false
            }else {
                self.btnVerify.isHidden = false
                self.btnVerify.isUserInteractionEnabled = true
                self.btnVerify.setTitle(languageHelper.LocalString(key: "Verify_Title"), for: .normal)
            }
        }
        if string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string == "" {
            return true
        }else {
            return false
        }
    }
    
    // MARK: - VerifyOtpDelegate
    func OtpVerification(success: Bool) {
        self.isVerified = success
        self.btnVerify.setTitle(languageHelper.LocalString(key: "verified"), for: .normal)
        self.btnVerify.isUserInteractionEnabled = false
        HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "Mobile_Number_Edit_MSG"), title: kAPPName)
    }
    
    // MARK: - WebService Method
    func saveUpdatedProfileAPI() {
        var strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        strPhone = strPhone.replacingOccurrences(of: "+", with: "")
        strPhone = strPhone.replacingOccurrences(of: "-", with: "")
        strPhone = strPhone.replacingOccurrences(of: "(", with: "")
        strPhone = strPhone.replacingOccurrences(of: ")", with: "")
        strPhone = strPhone.count > 10 ? String(strPhone.dropFirst(10 - strPhone.count)) : strPhone
        
        let img = self.isProfilePicChanged ? self.imgProfile.image : nil
        
        let param : NSDictionary = ["user_id"   :   self.userData.user_id,
                                    "language"  :   languageHelper.language,
                                    "first_name":   (self.txtFirstName.text)!,
                                    "last_name" :   (self.txtLastName.text)!,
                                    "country_code" :"+968",
                                    "mobile_number":strPhone.trimWhitespaces]
        
        HelperClass.formRequestApiWithBody(param: param,
                                           urlString: kURL_Update_Profile as NSString,
                                           mediaData: img,
                                           isHeader: true,
                                           showAlert: true,
                                           showHud: true,
                                           vc: self)
        { (result, message, status) in
            
            if status == "1" {
                self.isProfilePicChanged = false
                
                let dict = result.removeNullValueFromDict()
                
                self.userData.first_name = (self.txtFirstName.text)!
                self.userData.last_name = (self.txtLastName.text)!
                self.userData.mobile_number = (self.txtPhoneNumber.text)!
                self.userData.img = "\(dict.value(forKey: "img") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.first_name, forKey: "first_name")
                userDict.setValue(self.userData.last_name, forKey: "last_name")
                userDict.setValue(self.userData.mobile_number, forKey: "mobile_number")
                userDict.setValue(self.userData.img, forKey: "img")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                self.navigationController?.popViewController(animated: true)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func verifyMobileAPI() {
        let strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let param : NSDictionary = ["user_id"   :   self.userData.user_id,
                                    "language"  :   languageHelper.language,
                                    "country_code" :("+968"),
                                    "mobile_number": strPhone]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Mobile_Verify_Profile, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "VerifyOtpVC") as! VerifyOtpVC
                vc.userDict = ["authotp"    : "\(dict.value(forKey: "authotp") ?? "")",
                               "country_code" : "+968",
                               "user_id" : self.userData.user_id,
                               "mobile_number" : strPhone]
                vc.delegete = self
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



extension ProfileVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imgProfile.image = pickedImage
            self.isProfilePicChanged = true
        }else if  let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imgProfile.image = pickedImage
            self.isProfilePicChanged = true
        }
        picker.dismiss(animated: true, completion: nil);
        //        self.collectionImages.reloadData();
    }
    
    func selectMedia() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self;
        imagePicker.allowsEditing = true;
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = kThemeColor1;
        let action1 = UIAlertAction(title: languageHelper.LocalString(key: "selectExisting"), style: .default) { (action:UIAlertAction) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = ["public.image"];
            alertController.dismiss(animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: languageHelper.LocalString(key: "camera"), style: .default) { (action:UIAlertAction) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = ["public.image"];
            alertController.dismiss(animated: true, completion: nil)
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: languageHelper.LocalString(key:"Cancel_Title"), style: .cancel){ action -> Void in
            
        }
        
        alertController.addAction(action1)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            alertController.addAction(action2)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}





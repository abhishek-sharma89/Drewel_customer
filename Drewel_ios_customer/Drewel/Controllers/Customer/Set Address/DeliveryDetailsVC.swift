//
//  DeliveryDetailsVC.swift
//  Drewel
//
//  Created by Octal on 27/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit



@objc protocol SetAddressDetailsDelegate
{
    func setAddressDetails(addressData : DeliveryAddressDetailsData);
}



class DeliveryDetailsVC: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtAppartment: UITextField!
    @IBOutlet weak var txtWayNo: UITextField!
    @IBOutlet weak var txtFloor: UITextField!
    @IBOutlet weak var txtBuilding: UITextField!
    @IBOutlet weak var txtStreet: UITextField!
    @IBOutlet weak var txtAdditionalDirections: UITextField!
    
    @IBOutlet weak var btnRadio1: UIButton!
    @IBOutlet weak var btnRadio2: UIButton!
    @IBOutlet weak var btnRadio3: UIButton!
    
    @IBOutlet weak var const_view_textfield_height: NSLayoutConstraint!
    @IBOutlet weak var const_txt_floor_top: NSLayoutConstraint!
    
    var addressData = DeliveryAddressDetailsData()
    var quantity = Int()
    var totalPrice = Double()
    var discountedPrice = Double()
    var addressType = 1
    
    var delegate : SetAddressDetailsDelegate?
    
    
    var latitude = Double()
    var longitude = Double()
    var fullAddress = String()
    var zipcode = String()
    var name = String()
    
    
    var adrsDict = NSDictionary()
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.hidesBackButton = false
    }
    
    func setInitialValues() {
//        if (delegate != nil) {
////            navigationItem.hidesBackButton = true
            self.setAddressText(dict: adrsDict)
//        }else {
//            self.setAddressText(dict: UserDefaults.standard.object(forKey: kDefaultAddress) as? NSDictionary ?? NSDictionary())
//        }
        self.title = languageHelper.LocalString(key: "deliveryDetails")
    }
    
    func setAddressText(dict : NSDictionary) {
        self.lblAddress.text = self.fullAddress//dict.value(forKey: "name") as? String ?? ""
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnAddressTypeAction(_ sender: UIButton) {
        self.btnRadio1.layer.borderColor = (sender.tag == 1 ? kThemeColor1 : .darkGray).cgColor
        self.btnRadio2.layer.borderColor = (sender.tag == 2 ? kThemeColor1 : .darkGray).cgColor
        self.btnRadio3.layer.borderColor = (sender.tag == 3 ? kThemeColor1 : .darkGray).cgColor
        self.const_txt_floor_top.priority = sender.tag == 2 ? UILayoutPriority(rawValue: 250) : UILayoutPriority(rawValue: 750)
        self.const_view_textfield_height.priority = sender.tag == 2 ? UILayoutPriority(rawValue: 750) : UILayoutPriority(rawValue: 250)
        self.txtAppartment.placeholder = sender.tag == 1 ? languageHelper.LocalString(key: "apartmentNo") : sender.tag == 2 ? languageHelper.LocalString(key: "houseNo") : languageHelper.LocalString(key: "officeNo")
        self.addressType = sender.tag
    }
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let strPhone = txtPhoneNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        if (self.txtName.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "NAME_LENGTH"), title: kAPPName)
        }else if (strPhone.isEmpty) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_LENGTH"), title: kAPPName)
        }else if !(strPhone.trimWhitespaces.isPhoneNumber) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MOBILE_VALID"), title: kAPPName)
        }else if (self.txtAppartment.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: self.addressType == 1 ? "APARTMENT_LENGTH" : self.addressType == 2 ? "VILLA_LENGTH" : "OFFICE_LENGTH"), title: kAPPName)
        }else if (self.txtFloor.text?.isEmpty)! && self.addressType != 2 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "FLOOR_LENGTH"), title: kAPPName)
        }else if (self.txtBuilding.text?.isEmpty)! && self.addressType != 2 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "BUILDING_LENGTH"), title: kAPPName)
        }else if (self.txtStreet.text?.isEmpty)! {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "STREET_LENGTH"), title: kAPPName)
        }else {
//            var dict = NSDictionary()
//            if (delegate != nil) {
//                dict = self.adrsDict
//            }else {
//                dict = UserDefaults.standard.object(forKey: kDefaultAddress) as? NSDictionary ?? NSDictionary()
//            }
            self.addressData.address = self.fullAddress
//            self.addressData.latitude = dict.value(forKey: "latitude") as? String ?? ""
//            self.addressData.longitude = dict.value(forKey: "longitude") as? String ?? ""
//            self.addressData.zip_code = dict.value(forKey: "zip_code") as? String ?? ""
//            self.addressData.id = ""
            
            self.addressData.name = self.txtName.text!
            self.addressData.phone_number = (strPhone).trimWhitespaces
            self.addressData.appartment_no = self.txtAppartment.text!
            self.addressData.floor_no = self.txtFloor.text!
            self.addressData.building_name = self.txtBuilding.text!
            self.addressData.street_name = self.txtStreet.text!
            self.addressData.additional_details = self.txtAdditionalDirections.text!
            self.addressData.delivery_address_type = "\(self.addressType)"
            
            if self.addressData.delivery_address_type == "2" {
                self.addressData.full_address = self.addressData.appartment_no + ", " + self.addressData.street_name + ", " + "\(languageHelper.LocalString(key: "wayNo")) : \(self.txtWayNo.text!)" + ", " + self.addressData.address
            }else {
                self.addressData.full_address = self.addressData.appartment_no + ", " + self.addressData.floor_no + ", " + self.addressData.building_name + ", " + self.addressData.street_name + ", " + "\(languageHelper.LocalString(key: "wayNo")) : \(self.txtWayNo.text!)" + ", " + self.addressData.address
            }
            self.saveAddressDetailsAPI()
        }
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if textField == self.txtName {
            if range.location >= 35 && string != "" {
                return false
            }
        }else if textField == self.txtPhoneNumber {
            if range.location >= 10 && string != "" {
                return false
            }
        }else if textField == self.txtAppartment {
            if range.location >= 6 && string != "" {
                return false
            }
        }else if textField == self.txtFloor {
            if range.location >= 5 && string != "" {
                return false
            }
        }else if textField == self.txtBuilding {
            if range.location >= 50 && string != "" {
                return false
            }
        }else if textField == self.txtStreet {
            if range.location >= 50 && string != "" {
                return false
            }
        }else if textField == self.txtAdditionalDirections {
            if range.location >= 50 && string != "" {
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
    
    func saveAddressDetailsAPI() {
        
        let param : NSDictionary = ["user_id"               : self.userData.user_id,//
                                    "language"              : languageHelper.language,//
                                    "delivery_landmark"     : self.addressData.additional_details,//
                                    "delivery_address_type" : self.addressData.delivery_address_type,//
                                    "deliver_to"            : self.addressData.name,//
                                    "deliver_mobile"        : self.addressData.phone_number,//
                                    "address"               : self.addressData.full_address,//
                                    "latitude"              : "\(self.latitude)",//
                                    "name"                  : self.name,//
                                    "zip_code"              : self.zipcode,//
                                    "is_default"            :"1",//
                                    "longitude"             : "\(self.longitude)"]//
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Add_Address, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
//                if (self.delegate != nil) {
//                    self.delegate?.setAddressDetails(addressData: self.addressData)
                    
//                    var dict = NSMutableDictionary()
//                    if (self.delegate != nil) {
//                        dict = self.adrsDict as! NSMutableDictionary
//                    }else {
//                        dict = (UserDefaults.standard.object(forKey: kDefaultAddress) as? NSDictionary ?? NSDictionary()).mutableCopy() as! NSMutableDictionary
//                    }
                    
//                    if (dict["full_address"] as? String ?? "") == "" {
//                        dict.setValue(self.addressData.name, forKey: "user_name")
//                        dict.setValue(self.addressData.phone_number, forKey: "mobile_number")
//                        dict.setValue(self.addressData.full_address, forKey: "full_address")
//                        dict.setValue(self.addressData.additional_details, forKey: "landmark")
//                        dict.setValue(self.addressData.delivery_address_type, forKey: "delivery_address_type")
//                        UserDefaults.standard.set(dict, forKey: kDefaultAddress)
//                        UserDefaults.standard.synchronize()
//                    }
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[((self.navigationController?.viewControllers.count)! - 3)])!, animated: true)
//                }else {
//                    self.performSegue(withIdentifier: "segueOrderSummary", sender: nil)
//                }
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOrderSummary" {
            let vc = segue.destination as! OrderSummaryVC
            vc.addressDetailsData = self.addressData
            vc.itemQuantity = self.quantity
            vc.priceSubTotal = self.totalPrice
            vc.discountedPrice = self.discountedPrice
        }
    }
    

}

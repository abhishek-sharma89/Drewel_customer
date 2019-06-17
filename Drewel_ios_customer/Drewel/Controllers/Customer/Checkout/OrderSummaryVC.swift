//
//  OrderSummaryVC.swift
//  Drewel
//
//  Created by Octal on 01/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class OrderSummaryVC: BaseViewController, UITextFieldDelegate, SelectCouponCodeDelegate, SetDeliverySlotDelegate, SetDefaultAddressDelegate, SetAddressDetailsDelegate {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblDeliveryAddress: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblDeliveryCharges: UILabel!
    @IBOutlet weak var lblAlreadyPaid: UILabel!
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblAddToWallet: UILabel!
    @IBOutlet weak var lblAddressTitle: UILabel!
    
    @IBOutlet weak var btnAddressTitle: UIButton!
    @IBOutlet weak var btnApplyLoyaltyPoints: UIButton!
    @IBOutlet weak var btnApplyCoupon: UIButton!
    
    @IBOutlet weak var txtDeliveryType: UILabel!
    @IBOutlet weak var txtLoyaltyPoints: UITextField!
    @IBOutlet weak var txtCouponCode: UITextField!
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var tblDiscountCoupon: UITableView!
    
    @IBOutlet weak var imgRadio1: UIImageView!
    @IBOutlet weak var imgRadio2: UIImageView!
    @IBOutlet weak var imgRadio3: UIImageView!
    @IBOutlet weak var imgRadio4: UIImageView!
    
    @IBOutlet weak var const_view_already_paid_height: NSLayoutConstraint!
    
    
    
    var addressDetailsData = DeliveryAddressDetailsData()
    var picker = UIPickerView()
    lazy var arrDeliveryTypes = Array<String>()
    lazy var arrDeliverySlots = Array<String>()
    lazy var arrDiscount = Array<NSDictionary>()
    var arrDeliveryCharges = Array<Double>()
    lazy var loyaltyDiscount : Double = 0.00
    lazy var couponDiscount : Double = 0.00
    var deliverySlot : Double = 0.00
    var startTime = Date()
    var endTime = Date()
    var deliveryDate = Date()
    var selectedDeliveryOption = 0
    var selectedDeliverySlotIndex = 0
    var selectedPaymentType = 1
    
    var itemQuantity = Int()
    var priceSubTotal = Double()
    var discountedPrice = Double()
    
    var alreadyPaid = Double()
    var isEdit = "0"
    var extraAmount = 0.00
    var paymentMode = ""
    
    var loyaltyPoints = ""
    
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
        self.lblDiscount.text = "0.000".replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        self.getDeliveryChargesAPI()
        self.title = languageHelper.LocalString(key: "orderSummery")
        self.showLabelTexts()
        self.arrDeliveryTypes = ["Deliver Now", "Deliver Today", "Deliver Tommorow"]
        self.setInputTypeOfTextField()
        self.imgRadio1.isHighlighted = true
        if self.addressDetailsData.delivery_address_type.isEmpty {
            self.addressDetailsData.delivery_address_type = "1"
        }
        self.txtLoyaltyPoints.text = languageHelper.LocalString(key: "loyaltyPoint")
//        self.txtCouponCode.text = languageHelper.LocalString(key: "couponCode")
    }
    
    func setInputTypeOfTextField() {
        picker.delegate = self
        picker.dataSource = self
//        self.txtDeliveryType.inputView = picker
    }
    
    func createDeliverySlotWith(starting : Date, ending : Date) {
        self.arrDeliveryTypes.removeAll()
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        let startHour = Double(calendar.component(.hour, from: starting))
        let endHour = Double(calendar.component(.hour, from: ending))
        formatter.dateFormat = "hh:mm a"
        
        if (deliverySlot - Double(Int(deliverySlot))) > 0 {
            deliverySlot = Double(Int(deliverySlot)) + 0.5
        }
        for i in stride(from: startHour, to: endHour, by: deliverySlot) {
            var strTimeSlot = ""
            
            var strtHour = startHour
            var startMinute = 0
            if (i - Double(Int(i))) > 0 {
                strtHour = Double(Int(i))
                startMinute = 30
            }else {
                strtHour = Double(Int(i))
                startMinute = 0
            }
            
            var sDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), hour: Int(strtHour), minute: Int(startMinute) , second: 0)) ?? Date()
            
            strTimeSlot = formatter.string(from: sDate)
            strTimeSlot = strTimeSlot + " - "
            
            strtHour = i + self.deliverySlot
            if (strtHour - Double(Int(strtHour))) > 0 {
                strtHour = Double(Int(strtHour))
                startMinute = 30
            }else {
                startMinute = 0
            }
            sDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), hour: Int(strtHour), minute: Int(startMinute) , second: 0)) ?? Date()
            
            strTimeSlot = strTimeSlot + formatter.string(from: sDate)
            
//            var slot = strTimeSlot
//            let dFormatter = DateFormatter()
//            dFormatter.dateFormat = "hh:mm aa"
//            var sTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[0])
//            var eTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[1])
//            if sTime == nil || eTime == nil {
//                dFormatter.dateFormat = "HH:mm"
//                sTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[0]) ?? Date()
//                eTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[1]) ?? Date()
//            }
//            dFormatter.locale = languageHelper.getLocale()
//            dFormatter.dateFormat = "hh:mm a"
//            slot = dFormatter.string(from: sTime!) + " - " + dFormatter.string(from: eTime!)
//            strTimeSlot = slot
            
            self.arrDeliveryTypes.append(strTimeSlot)
        }
    }
    
    func showDeliverySlots() {
        if self.arrDeliverySlots.count > 0 {
            self.selectedDeliverySlotIndex = 0
//            self.txtDeliveryType.isUserInteractionEnabled = true
//            self.txtDeliveryType.becomeFirstResponder()
        }else {
            self.txtDeliveryType.text = languageHelper.LocalString(key: "chooseDeliveryType")
            HelperClass.showPopupAlertController(sender: self, message: "Please select other option as the delivery slot is not available in selected delivery option.", title: kAPPName)
        }
    }
    
    func showLabelTexts() {
        self.lblName.text = self.addressDetailsData.name
        self.lblPhoneNumber.text = self.addressDetailsData.phone_number.replaceEnglishDigitsWithArabic
        self.lblDeliveryAddress.text = self.addressDetailsData.full_address
        self.lblQuantity.text = "\(self.userData.cart_quantity)".replaceEnglishDigitsWithArabic
        self.lblSubTotal.text = String.init(format: "%.3f", self.discountedPrice).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        let addressType = "\(self.addressDetailsData.delivery_address_type)"
        self.lblAddressTitle.text = (addressType == "1" ? languageHelper.LocalString(key: "apartment") : addressType == "2" ? languageHelper.LocalString(key: "house") : languageHelper.LocalString(key: "office"))
        self.viewHeader.layoutIfNeeded()
        self.tblDiscountCoupon.tableHeaderView?.frame.size = CGSize.init(width: self.viewHeader.frame.size.width, height: self.viewHeader.frame.size.height)
        self.setGrandTotal()
        self.tblDiscountCoupon.reloadData()
    }
    
    func getTotalDiscount() {
        var totalDiscount = 0.00
        for i in 0..<self.arrDiscount.count {
            let dict = self.arrDiscount[i]
            totalDiscount = totalDiscount + (dict.value(forKey: "discount") as? Double ?? 0.00)
        }
        self.couponDiscount = totalDiscount
        totalDiscount += self.loyaltyDiscount
        self.lblDiscount.text = String.init(format: "%.3f", totalDiscount).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        self.setGrandTotal()
    }
    
    func setGrandTotal() {
        let del_charge = (self.selectedDeliveryOption > 0) ? self.arrDeliveryCharges[self.selectedDeliveryOption - 1] : 0.00
        var g_Total = self.discountedPrice  - (self.loyaltyDiscount + self.couponDiscount)
        g_Total = g_Total < 0 ? 0 : g_Total
        g_Total += del_charge
        
        const_view_already_paid_height.constant = 0
        if isEdit == "1" && alreadyPaid > 0 && self.paymentMode != "1" {
            g_Total -= alreadyPaid
            extraAmount = g_Total < 0 ? (g_Total * -1) : 0.00
            g_Total = g_Total < 0 ? 0.00 : g_Total
            
            self.lblAlreadyPaid.text = "\(alreadyPaid)".replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            self.lblAddToWallet.text = "(\(extraAmount) \(languageHelper.LocalString(key: "addedToWallet")))".replaceEnglishDigitsWithArabic
            self.lblAddToWallet.isHidden = extraAmount <= 0
            self.const_view_already_paid_height.constant = extraAmount > 0 ? 55 : 33
        }
        
        var height = CGFloat.init(430.00)
        height = height - (55 - self.const_view_already_paid_height.constant)
        self.tblDiscountCoupon.tableFooterView?.frame.size.height = height
        
        self.tblDiscountCoupon.reloadData()
        
        self.lblDeliveryCharges.text = String.init(format: "%.3f", del_charge).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        self.lblGrandTotal.text = String.init(format: "%.3f", g_Total).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == self.txtDeliveryType {
//            self.txtDeliveryType.isUserInteractionEnabled = false
            self.picker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string.rangeOfCharacter(from: CharacterSet.whitespaces) != nil || string == "" {
            return true
        }else {
            return false
        }
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnChooseDeliveryTypeAction(_ sender: Any) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "TimeSlotVC") as! TimeSlotVC
        self.arrDeliverySlots.removeAll()
        self.arrDeliverySlots.append(contentsOf: self.arrDeliveryTypes)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa"
        let strTimeSlot = self.getInitialDeliverySlot()
        if self.arrDeliveryTypes.contains(strTimeSlot) {
            let index = self.arrDeliveryTypes.index(of: strTimeSlot) ?? 0
            self.arrDeliverySlots.removeFirst(index)
            vc.arrDeliverySlots = self.arrDeliverySlots
        }else {
            vc.arrDeliverySlots = [String]()
        }
        vc.arrDeliveryTypes = self.arrDeliveryTypes
        vc.arrDeliveryCharges = self.arrDeliveryCharges
        vc.delegate = self
        self.navigationController?.show(vc, sender: nil)
        
        /*
        self.arrDeliverySlots.removeAll()
        self.arrDeliverySlots.append(contentsOf: self.arrDeliveryTypes)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa"
         
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "chooseDeliveryType"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "deliverNow"), style: UIAlertActionStyle.default) { _ in
            self.selectedDeliveryOption = 1
            self.txtDeliveryType.text = languageHelper.LocalString(key: "deliverNow")
            self.deliveryDate = Date()
            
            let strTimeSlot = self.getInitialDeliverySlot()
            if self.arrDeliveryTypes.contains(strTimeSlot) {
                let index = self.arrDeliveryTypes.index(of: strTimeSlot) ?? 0
                self.arrDeliverySlots.removeFirst(index)
                self.selectedDeliverySlotIndex = 0
                self.setGrandTotal()
                self.deliveryDate = Date()
            }else {
                self.txtDeliveryType.text = ""
                HelperClass.showPopupAlertController(sender: self, message: "Please select other option as the delivery slot is not available in selected delivery option.", title: kAPPName)
            }
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "sameDayDelivery"), style: UIAlertActionStyle.default, handler: { _ in
            self.selectedDeliveryOption = 2
            self.txtDeliveryType.text = languageHelper.LocalString(key: "sameDayDelivery")
            
            let strTimeSlot = self.getInitialDeliverySlot()
            
            if self.arrDeliveryTypes.contains(strTimeSlot) {
                let index = self.arrDeliveryTypes.index(of: strTimeSlot) ?? 0
                self.arrDeliverySlots.removeFirst(index)
                self.showDeliverySlots()
                self.setGrandTotal()
                self.deliveryDate = Date()
            }else {
                self.txtDeliveryType.text = ""
                HelperClass.showPopupAlertController(sender: self, message: "Please select other option as the delivery slot is not available in selected delivery option.", title: kAPPName)
            }
        }))
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "nextDayDelivery"), style: UIAlertActionStyle.default, handler: { _ in
            self.selectedDeliveryOption = 3
            self.txtDeliveryType.text = languageHelper.LocalString(key: "nextDayDelivery")
            self.showDeliverySlots()
            self.setGrandTotal()
            self.deliveryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }))
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: { _ in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
 */
    }
    
    func getInitialDeliverySlot() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        let calendar = Calendar.current
        var startMinute = Double(calendar.component(.minute, from: Date()))
        var sDate = Date()
        
        let nowHour = Double(calendar.component(.hour, from: Date())) + (startMinute / 60)
        var strtHour = Double(calendar.component(.hour, from: self.startTime))
        
        var hourDifference = nowHour - strtHour
        hourDifference = hourDifference / self.deliverySlot
        let decimalValue = hourDifference - Double(Int(hourDifference))
        if decimalValue >= 0.0 {
            hourDifference = Double(Int(hourDifference)) + 2
        }else {
            hourDifference = Double(Int(hourDifference)) + 1
        }
        
        strtHour = strtHour + hourDifference * self.deliverySlot
        if (strtHour - Double(Int(strtHour))) > 0 {
            strtHour = Double(Int(strtHour))
            startMinute = 30
        }else {
            startMinute = 0
        }
        //            formatter.dateFormat = "HH:mm:ss"
        sDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), hour: Int(strtHour), minute: Int(startMinute) , second: 0)) ?? Date()
        
        var strTimeSlot = formatter.string(from: sDate)
        strTimeSlot = strTimeSlot + " - "
        
        strtHour = Double(calendar.component(.hour, from: self.startTime)) + hourDifference * self.deliverySlot + self.deliverySlot
        if (strtHour - Double(Int(strtHour))) > 0 {
            strtHour = Double(Int(strtHour))
            startMinute = 30
        }else {
            startMinute = 0
        }
        sDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), hour: Int(strtHour), minute: Int(startMinute) , second: 0)) ?? Date()
        
        strTimeSlot = strTimeSlot + formatter.string(from: sDate)
        
//        var slot = strTimeSlot
//        let dFormatter = DateFormatter()
//        dFormatter.dateFormat = "hh:mm aa"
//        var sTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[0])
//        var eTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[1])
//        if sTime == nil || eTime == nil {
//            dFormatter.dateFormat = "HH:mm"
//            sTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[0]) ?? Date()
//            eTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[1]) ?? Date()
//        }
//        dFormatter.locale = languageHelper.getLocale()
//        dFormatter.dateFormat = "hh:mm a"
//        slot = dFormatter.string(from: sTime!) + " - " + dFormatter.string(from: eTime!)
//        strTimeSlot = slot
        
        return strTimeSlot
    }
    
    @IBAction func btnApplyLoyaltyPointsAction(_ sender: UIButton) {
        if sender.titleLabel?.text == languageHelper.LocalString(key: "redeem") {
            if (self.txtLoyaltyPoints.text)! == languageHelper.LocalString(key: "loyaltyPoint") {
                self.applyLoyaltyPointsAPI()
            }
        }else {
            self.txtLoyaltyPoints.isUserInteractionEnabled = true
            self.loyaltyPoints = ""
            self.txtLoyaltyPoints.text = languageHelper.LocalString(key: "loyaltyPoint")
            self.loyaltyDiscount = 0.00
            self.getTotalDiscount()
            sender.setTitle(languageHelper.LocalString(key: "redeem"), for: .normal)
        }
    }
    
    @IBAction func btnApplyCouponAction(_ sender: Any) {
        if !(self.txtCouponCode.text?.isEmpty)! {
            let isUsed = self.arrDiscount.filter{ ($0["coupon"] as! String) == self.txtCouponCode.text! }.first
            if (isUsed != nil) {
                HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Coupon_Already_Used"), title: kAPPName)
            }else {
                self.applyCouponCodeAPI(coupon: self.txtCouponCode.text!)
            }
        }
    }
    
    @IBAction func btnSelecteAddressAction(_ sender: UIButton) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "SearchAddressVC") as! SearchAddressVC
        vc.delegate = self
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func btnSelectCouponCodeAction(_ sender: UIButton) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "SearchProductsVC") as! SearchProductsVC
        vc.delegate = self
        vc.isApply = true
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func btnRemoveCouponAction(_ sender: UIButton) {
        let indexPath = tblDiscountCoupon.indexPath(for: (sender.superview?.superview)! as! UITableViewCell)
        
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Remove_Promo_MSG"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
//            self.txtCouponCode.text = ""
            self.arrDiscount.remove(at: (indexPath?.row)!)
            self.tblDiscountCoupon.reloadData()
            self.getTotalDiscount()
            
            self.txtCouponCode.isUserInteractionEnabled = true
            self.btnApplyCoupon.isUserInteractionEnabled = true
            self.btnApplyCoupon.setTitleColor(kThemeColor1, for: .normal)
            self.txtCouponCode.textColor = UIColor.black
            self.txtCouponCode.text = ""
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnPaymentTypeAction(_ sender: UIButton) {
        self.imgRadio1.isHighlighted = (sender.tag == 104)
        self.imgRadio2.isHighlighted = (sender.tag == 105)
        self.imgRadio3.isHighlighted = (sender.tag == 106)
        self.imgRadio4.isHighlighted = (sender.tag == 107)
        
        self.selectedPaymentType = (sender.tag == 104) ? 1 : (sender.tag == 105) ? 2 : (sender.tag == 106) ? 3 : 4
    }
    
    @IBAction func btnConfirmOrderAction(_ sender: Any) {
        if (self.txtDeliveryType.text)! == languageHelper.LocalString(key: "chooseDeliveryType") {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Select_Delivery_Type"), title: kAPPName)
        }else {
            self.placeOrderAPI()
        }
    }
    
    //MARK: - SetDefaultAddress Delegate
    
    func seDefaultAddress(dict: NSDictionary) {
        self.setAddressText(dict: dict)
    }
    
    func setAddressText(dict : NSDictionary) {
        
        if (dict.value(forKey: "full_address") as? String ?? "") != "" {
            
            UserDefaults.standard.set(dict, forKey: kDefaultAddress)
            UserDefaults.standard.synchronize()
            
            self.addressDetailsData.address = dict.value(forKey: "address") as? String ?? ""
            self.addressDetailsData.latitude = dict.value(forKey: "latitude") as? String ?? ""
            self.addressDetailsData.longitude = dict.value(forKey: "longitude") as? String ?? ""
            self.addressDetailsData.zip_code = dict.value(forKey: "zip_code") as? String ?? ""
            self.addressDetailsData.id = dict.value(forKey: "id") as? String ?? ""
            
            self.addressDetailsData.name = dict.value(forKey: "user_name") as? String ?? ""
            self.addressDetailsData.phone_number = dict.value(forKey: "mobile_number") as? String ?? ""
            self.addressDetailsData.full_address = dict.value(forKey: "full_address") as? String ?? ""
            self.addressDetailsData.additional_details = dict.value(forKey: "landmark") as? String ?? ""
            self.addressDetailsData.delivery_address_type = "\(dict.value(forKey: "delivery_address_type") ?? "")"
            
            self.showLabelTexts()
        }else {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "DeliveryDetailsVC") as! DeliveryDetailsVC
            vc.delegate = self
            vc.adrsDict = dict
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    // MARK: - SetAddressDetailsDelegate
    func setAddressDetails(addressData: DeliveryAddressDetailsData) {
        self.addressDetailsData = addressData
        self.showLabelTexts()
    }
    
    // MARK: - SetDeliverySlot Delegate
    func setDeliverySlot(dateIndex: Int, slotIndex: Int, arrSlots: [String]) {
        if arrSlots.count < (slotIndex + 1) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "Choose_slot_MSG"), title: kAPPName)
            return
        }
        self.arrDeliverySlots.removeAll()
        self.arrDeliverySlots.append(contentsOf: arrSlots)
        self.deliveryDate = Date()
        self.selectedDeliveryOption = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = languageHelper.getLocale()
        
//        let dateFormatter = DateFormatter()
        var slot = self.arrDeliverySlots[slotIndex]
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "hh:mm aa"
        var sTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[0])
        var eTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[1])
        if sTime == nil || eTime == nil {
            dFormatter.dateFormat = "HH:mm"
            sTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[0]) ?? Date()
            eTime = dFormatter.date(from: (slot.components(separatedBy: " - "))[1]) ?? Date()
        }
        dFormatter.locale = languageHelper.getLocale()
        dFormatter.dateFormat = "hh:mm a"
        slot = dFormatter.string(from: sTime!) + " - " + dFormatter.string(from: eTime!)
        
        print(slot)
        
        if dateIndex == 0 {
            self.selectedDeliveryOption = 1//2 //(Same Day Delivery)
//            self.txtDeliveryType.text = languageHelper.LocalString(key: "sameDayDelivery")
            self.txtDeliveryType.text = formatter.string(from: self.deliveryDate) + " - " + slot //self.arrDeliverySlots[slotIndex]
            if slotIndex == 0 {
                self.selectedDeliveryOption = 1 //3 //(Deliver Now)
//                self.txtDeliveryType.text = languageHelper.LocalString(key: "deliverNow")
            }
        }else {
            self.selectedDeliveryOption = 3 //1 // (Next Day Delivery)
            self.deliveryDate = Calendar.current.date(byAdding: .day, value: dateIndex, to: Date())!
//            self.txtDeliveryType.text = languageHelper.LocalString(key: "nextDayDelivery")
            self.txtDeliveryType.text = formatter.string(from: self.deliveryDate) + " - " + slot //self.arrDeliverySlots[slotIndex]
        }
        self.selectedDeliverySlotIndex = slotIndex
        self.setGrandTotal()
    }
    /*
     formatter.dateFormat = "hh:mm aa"
     let sDate = formatter.date(from: (slot.components(separatedBy: " - "))[0]) ?? Date()
     let eDate = formatter.date(from: (slot.components(separatedBy: " - "))[1]) ?? Date()
     formatter.locale = languageHelper.getLocale()
     formatter.dateFormat = "hh:mm aa"
     slot = formatter.string(from: sDate) + " - " + formatter.string(from: eDate)
     */
    
    // MARK: - CouponCodeDelegate Method
    func setCouponCode(code: String) {
        
        let isUsed = self.arrDiscount.filter{ ($0["coupon"] as! String) == code }.first
        if (isUsed != nil) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Coupon_Already_Used"), title: kAPPName)
        }else {
            self.applyCouponCodeAPI(coupon: code)
        }
    }
    
    // MARK: - WebService Method
    
    func getDeliveryChargesAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delivery_Charges, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
                self.arrDeliveryCharges.removeAll()
                let dict = result.removeNullValueFromDict()
                self.arrDeliveryCharges.append(Double("\(dict.value(forKey: "expedite_delivery_charges") ?? "")") ?? 0.00)
                self.arrDeliveryCharges.append(Double("\(dict.value(forKey: "same_day_delivery_charge") ?? "")") ?? 0.00)
                self.arrDeliveryCharges.append(Double("\(dict.value(forKey: "delivery_charge") ?? "")") ?? 0.00)
                
                self.alreadyPaid = (Double("\(dict.value(forKey: "last_paid") ?? "")") ?? 0.00)
                self.isEdit = "\(dict.value(forKey: "is_edited") ?? "0")"
                self.paymentMode = "\(dict.value(forKey: "payment_mode") ?? "1")"
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                self.startTime = formatter.date(from: "\(dict.value(forKey: "delivery_start_time") ?? "")") ?? Date()
                self.endTime = formatter.date(from: "\(dict.value(forKey: "delivery_end_time") ?? "")") ?? Date()
                self.deliverySlot = (Double("\(dict.value(forKey: "delivery_slot_duration") ?? "")") ?? 0.00)
                self.createDeliverySlotWith(starting: self.startTime, ending: self.endTime)
                
                self.setGrandTotal()
                self.viewHeader.layoutIfNeeded()
                self.tblDiscountCoupon.tableHeaderView?.frame.size = CGSize.init(width: self.viewHeader.frame.size.width, height: self.viewHeader.frame.size.height)
                self.tblDiscountCoupon.reloadData()
            }else {
                self.navigationController?.popViewController(animated: false)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func applyLoyaltyPointsAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id,
                               "loyalty_points" : ""]//(self.txtLoyaltyPoints.text)!]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Loyalty_Point, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.loyaltyDiscount = Double("\(result.removeNullValueFromDict().value(forKey: "loyalty_points") ?? "0.00")") ?? 0.0
                self.getTotalDiscount()
                self.txtLoyaltyPoints.text = "\(result.removeNullValueFromDict().value(forKey: "loyalty_points") ?? "0.00") \(languageHelper.LocalString(key: "points"))"
                self.loyaltyPoints =  "\(result.removeNullValueFromDict().value(forKey: "loyalty_points") ?? "0.00")"
                
                self.txtLoyaltyPoints.isUserInteractionEnabled = false
                self.btnApplyLoyaltyPoints.setTitle(languageHelper.LocalString(key: "remove"), for: .normal)
            }else {
                self.txtLoyaltyPoints.text =  languageHelper.LocalString(key: "loyaltyPoint")
                self.loyaltyPoints = ""
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func applyCouponCodeAPI(coupon : String) {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id,
                                  "coupon_code" : coupon]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Apply_Coupon, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.viewHeader.layoutIfNeeded()
                self.tblDiscountCoupon.tableHeaderView?.frame.size = CGSize.init(width: self.viewHeader.frame.size.width, height: self.viewHeader.frame.size.height)
                
                
                let dict = (result.value(forKey: "Coupon") as? NSDictionary ?? NSDictionary()).removeNullValueFromDict()
                
                let discount = Double("\(dict.value(forKey: "discount_amount") ?? "0.00")")
//                let coupon = self.txtCouponCode.text
                self.arrDiscount.append(["discount" : discount!,
                                         "coupon"   : coupon])
                
                self.tblDiscountCoupon.reloadData()
                self.getTotalDiscount()
                
                self.txtCouponCode.isUserInteractionEnabled = false
                self.btnApplyCoupon.isUserInteractionEnabled = false
                self.btnApplyCoupon.setTitleColor(UIColor.lightGray, for: .normal)
                self.txtCouponCode.textColor = UIColor.darkGray
            }else {
//                self.txtCouponCode.text = ""
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func placeOrderAPI() {
        var strStime = ""
        var strEtime = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.string(from: self.deliveryDate)
//        if self.selectedDeliveryOption > 1 {
        if self.arrDeliverySlots.count > 0
        {
            let arr = self.arrDeliverySlots[self.selectedDeliverySlotIndex].components(separatedBy: " - ")
            if arr.count > 0
            {
//                formatter.locale = Locale.init(identifier: "en_US_POSIX")
                formatter.dateFormat = "hh:mm aa"
                var sTime = formatter.date(from: arr[0])
                var eTime = formatter.date(from: arr[1])
                if sTime == nil || eTime == nil {
                    formatter.dateFormat = "HH:mm"
                    sTime = formatter.date(from: arr[0]) ?? Date()
                    eTime = formatter.date(from: arr[1]) ?? Date()
                }
                formatter.dateFormat = "HH:mm:ss"
                strStime = formatter.string(from: sTime!)
                strEtime = formatter.string(from: eTime!)
            }else {
                self.txtDeliveryType.text = languageHelper.LocalString(key: "chooseDeliveryType")
                HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Select_Delivery_Type"), title: kAPPName)
                return
            }
        }
        else
        {
            self.txtDeliveryType.text = languageHelper.LocalString(key: "chooseDeliveryType")
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Select_Delivery_Type"), title: kAPPName)
            return
        }
//        }
        
        let del_charges = (self.selectedDeliveryOption > 0) ? self.arrDeliveryCharges[self.selectedDeliveryOption - 1] : 0.00
        var arrCoupons = Array<String>()
        for dict in arrDiscount {
            if let coupon = (dict.value(forKey: "coupon") as? String) {
                arrCoupons.append(coupon)
            }
            
        }
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "amount"    : String.init(format: "%.3f", (self.priceSubTotal)), //"\(self.priceSubTotal)",
                                    "quantity"  : self.userData.cart_quantity,//"\(self.itemQuantity)",
                                    "cart_id"   : self.userData.cart_id,
                                    "payment_mode" : self.selectedPaymentType,
                                    "delivery_type" : "1",//"\(self.selectedDeliveryOption)",
                                    "delivery_address" : self.addressDetailsData.full_address,
                                    "delivery_latitude" : self.addressDetailsData.latitude,
                                    "delivery_longitude" : self.addressDetailsData.longitude,
                                    "delivery_date"     : date,
                                    "delivery_start_time" : strStime,
                                    "delivery_end_time"     : strEtime,
                                    "loyalty_points" : self.loyaltyPoints,//(self.txtLoyaltyPoints.text)!,
                                    "coupons"           : arrCoupons,
                                    "delivery_charges"  : del_charges > 0 ? "\(del_charges)" : "",
                                    "address_id"        : self.addressDetailsData.id,
                                    "delivery_landmark" : self.addressDetailsData.additional_details,
                                    "transaction_id"    : "",
                                    "deliver_to"    : self.addressDetailsData.name,
                                    "deliver_mobile"    : self.addressDetailsData.phone_number,
                                    "delivery_address_type" : "\(self.addressDetailsData.delivery_address_type)" ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Checkout, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                if self.selectedPaymentType == 2 {
                    let url = "\(result.removeNullValueFromDict().value(forKey: "url") ?? "")"
                    let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "PaymentViewVC") as! PaymentViewVC
                    vc.strUrl = url
                    vc.message = message
                    self.navigationController?.show(vc, sender: nil)
                    return
                }
                self.userData.cart_quantity = "0"
                self.userData.cart_id = ""
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                self.tabBarController?.selectedIndex = 2
                self.navigationController?.popToRootViewController(animated: false)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                
                let dict : NSMutableDictionary = (UserDefaults.standard.object(forKey: kDefaultAddress) as? NSDictionary ?? NSDictionary()).mutableCopy() as! NSMutableDictionary
                if (dict["full_address"] as? String ?? "") == "" {
                    dict.setValue(self.addressDetailsData.name, forKey: "user_name")
                    dict.setValue(self.addressDetailsData.phone_number, forKey: "mobile_number")
                    dict.setValue(self.addressDetailsData.full_address, forKey: "full_address")
                    dict.setValue(self.addressDetailsData.additional_details, forKey: "landmark")
                    dict.setValue(self.addressDetailsData.delivery_address_type, forKey: "delivery_address_type")
                    UserDefaults.standard.set(dict, forKey: kDefaultAddress)
                    UserDefaults.standard.synchronize()
                }
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

// MARK: -
//UITableView Delegate & Datasource
extension OrderSummaryVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrDiscount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        (cell.viewWithTag(2) as! UILabel).text = "\(self.arrDiscount[indexPath.row].value(forKey: "discount") as! Double) \(languageHelper.LocalString(key: "OMR"))"
        (cell.viewWithTag(1) as! UILabel).text = "\(self.arrDiscount[indexPath.row].value(forKey: "coupon") ?? "")"
        
        let btn = (cell.viewWithTag(3) as! UIButton)
//        btn.tag = indexPath.row
        btn.addTarget(self, action: #selector(btnRemoveCouponAction(_:)), for: .touchUpInside)
        
        return cell;
    }
}

extension OrderSummaryVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrDeliverySlots.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrDeliverySlots[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedDeliverySlotIndex = row
    }
}

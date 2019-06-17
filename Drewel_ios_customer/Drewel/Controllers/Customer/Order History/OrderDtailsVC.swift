//
//  OrderDtailsVC.swift
//  Drewel
//
//  Created by Octal on 08/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class OrderDtailsVC: UIViewController {
    
    @IBOutlet weak var tblOrderDetails: UITableView!
    @IBOutlet weak var btnCancelOrder: UIButton!
    @IBOutlet weak var const_btnCancelOrder_aspectRatio: NSLayoutConstraint!
    @IBOutlet weak var btnReorder: UIButton!
    
    var userData = UserData.sharedInstance;
    
    var arrProduct = [ProductsData]()
    var order = OrderListData()
    var deliveryBoy = NSDictionary()
    var isDeliveryBoy = false
    var orderId = String()
    var arrCoupons = Array<NSDictionary>()
    var isFullMap = false
    var cancelBefore = 0
    
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
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "orderDetails")
        NotificationCenter.default.addObserver(self, selector: #selector(getOrderDetailsAPI), name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
        
        self.tblOrderDetails.isHidden = self.arrProduct.count == 0
        self.const_btnCancelOrder_aspectRatio.priority = UILayoutPriority(rawValue: 250)
        self.getOrderDetailsAPI()
        
    }
    
    // MARK: - IBAction Method
    @IBAction func btnCancelOrderAction(_ sender: UIButton) {
        if sender.tag == 100 {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Order_Cancel_MSG"), preferredStyle: .alert)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
                self.cancelOrderAPI()
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else if sender.tag == 101 {
            self.openFullMap()
        }
    }
    
    @IBAction func btnReorderAction(_ sender: UIButton) {
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Order_Reorder_MSG"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
            self.replaceOrderAPI()
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openFullMap() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FullMapVC") as! FullMapVC
        vc.destinationLat = Double(self.order.delivery_latitude)!
        vc.destinationLong = Double(self.order.delivery_longitude)!
        vc.providerId = "\(self.deliveryBoy.value(forKey: "id") ?? "")"
        vc.isProvider = false
        
        self.isFullMap = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnProductDetailsAction(_ sender: UIButton) {
        let product = self.arrProduct[sender.tag]
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsTableVC
        vc.categoryId = product.category.count > 0 ? (product.category.first?.id)! : ""
        vc.subCategoryId = ""
        vc.brandId = ""
        vc.product_id = product.product_id
        vc.productName = product.product_name
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func btnCallDeliveryBoyAction(_ sender: UIButton) {
        var str = "tel://\(self.deliveryBoy.value(forKey: "mobile_number") ?? "")"
        str = str.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: str), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - WebService Method
    @objc func getOrderDetailsAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : self.orderId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Order_Details, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let orderData = (result.value(forKey: "Order") as! NSDictionary).removeNullValueFromDict()
                
                self.order.delivery_date = "\(orderData.value(forKey: "delivery_date") ?? "")"
                self.order.order_id = "\(orderData.value(forKey: "order_id") ?? "")"
                self.order.order_delivery_status = "\(orderData.value(forKey: "order_delivery_status") ?? "")"
                self.order.order_status = "\(orderData.value(forKey: "order_status") ?? "")"
                self.order.delivery_start_time = "\(orderData.value(forKey: "delivery_start_time") ?? "")"
                self.order.total_amount = "\(orderData.value(forKey: "total_amount") ?? "")"
                self.order.is_cancelled = "\(orderData.value(forKey: "is_cancelled") ?? "")"
                self.order.total_quantity = "\(orderData.value(forKey: "total_quantity") ?? "")"
                self.order.delivery_end_time = "\(orderData.value(forKey: "delivery_end_time") ?? "")"
                self.order.payment_mode = "\(orderData.value(forKey: "payment_mode") ?? "")"
                self.order.transaction_id = "\(orderData.value(forKey: "transaction_id") ?? "")"
                self.order.deliver_mobile = "\(orderData.value(forKey: "deliver_mobile") ?? "")"
                self.order.cancelled_before = "\(orderData.value(forKey: "cancelled_before") ?? "")"
                self.order.deliver_to = "\(orderData.value(forKey: "deliver_to") ?? "")"
                self.order.delivery_charges = "\(orderData.value(forKey: "delivery_charges") ?? "")"
                self.order.net_amount = "\(orderData.value(forKey: "net_amount") ?? "")"
                self.order.delivery_address = "\(orderData.value(forKey: "delivery_address") ?? "")"
                self.order.loyalty_points = "\(orderData.value(forKey: "loyalty_points") ?? "")"
                self.order.loyalty_discount = "\(orderData.value(forKey: "loyalty_discount") ?? "")"
                self.order.coupon_discount = "\(orderData.value(forKey: "coupon_discount") ?? "")"
                self.order.order_date = "\(orderData.value(forKey: "order_date") ?? "")"
                
                self.order.delivery_latitude = "\(orderData.value(forKey: "delivery_latitude") ?? "")"
                self.order.delivery_longitude = "\(orderData.value(forKey: "delivery_longitude") ?? "")"
                
                self.cancelBefore = Int("\(orderData.value(forKey: "cancelled_before") ?? "0")") ?? 0
                
                let arrProduct = (result.object(forKey: "Products") as! Array<NSDictionary>)
                self.arrProduct.removeAll()
                
                for dictProduct in arrProduct {
                    var product = ProductsData()
                    product.product_id = "\(dictProduct.value(forKey: "product_id") ?? "")"
                    product.quantity = "\(dictProduct.value(forKey: "quantity") ?? "")"
                    product.price = "\(dictProduct.value(forKey: "product_price") ?? "")" + " \(languageHelper.LocalString(key: "OMR"))"
                    product.product_name = "\(dictProduct.value(forKey: (languageHelper.isArabic() ? "ar_product_name" : "product_name")) ?? "")"
                    product.product_image = "\(dictProduct.value(forKey: "product_image") ?? "")"
                    
                    product.category.removeAll()
                    let arrCategory = dictProduct.object(forKey: "Category") as? NSArray ?? NSArray()
                    for i in 0..<arrCategory.count {
                        let catDict = arrCategory[i] as? NSDictionary ?? NSDictionary()
                        var category = ProductCategory()
                        category.id = "\(catDict.value(forKey: "id") ?? "")"
                        category.category_name = "\(catDict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) ?? "")"
                        category.img = "\(catDict.value(forKey: "img") ?? "")"
                        
                        let arrSubCat = dictProduct.object(forKey: "SubCategory") as! NSArray
                        if arrSubCat.count > 0 {
                            let subCatDict = arrSubCat.firstObject as! NSDictionary;
                            var subCatData = ProductCategory();
                            subCatData.category_name = "\(subCatDict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) ?? "")"
                            subCatData.id = "\(subCatDict.value(forKey: "id") ?? "")"
                            subCatData.img = "\(subCatDict.value(forKey: "img") ?? "")"
                            category.subcategories.append(subCatData)
                        }
                        
                        
                        product.category.append(category)
                    }
                    
                    self.arrProduct.append(product)
                }
                
                self.arrCoupons = (result.object(forKey: "Coupons") as? Array<NSDictionary>) ?? Array<NSDictionary>()
                
                self.deliveryBoy = (result.object(forKey: "DeliveryBoy") as? NSDictionary ?? NSDictionary()).removeNullValueFromDict()
                self.isDeliveryBoy = self.deliveryBoy.allKeys.count > 0
                self.changeCancelButtonText()
                
                self.tblOrderDetails.isHidden = self.arrProduct.count == 0
                self.tblOrderDetails.reloadData()
                self.btnReorder.isHidden = (self.order.order_delivery_status != "Delivered" && self.order.is_cancelled != "1")
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func cancelOrderAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : self.order.order_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Order_Cancel, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.navigationController?.popViewController(animated: true)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func replaceOrderAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : self.order.order_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Order_Replace, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                let navVC = self.navigationController!
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC")
                self.navigationController?.popToRootViewController(animated: false)
                navVC.pushViewController(vc!, animated: false)
                
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func getDeliveryBoyLocationAPI() {
        let dict = ["provider_id" : self.deliveryBoy.value(forKey: "id") ]
        
        HelperClass.requestForAllApiWithBody(param: dict as NSDictionary, serverUrl: "", showAlert: false, showHud: false, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let lat = Double.init(result.value(forKey: "latitude") as! String )!
                let long = Double.init(result.value(forKey: "longitude") as! String )!
                
                NotificationCenter.default.post(name: Notification.Name("updateFullMap"), object: nil, userInfo: ["lat" : lat, "long" : long])
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func changeCancelButtonText() {
        self.const_btnCancelOrder_aspectRatio.priority = UILayoutPriority(rawValue: 250)
        if order.is_cancelled == "1" || order.order_delivery_status == ("Delivered") {
            self.isDeliveryBoy = false
            return
        }
        if self.isDeliveryBoy {
            if order.order_delivery_status != ("Pending") {
                self.btnCancelOrder.setTitle(languageHelper.LocalString(key: "trackOrder"), for: .normal)
                self.const_btnCancelOrder_aspectRatio.priority = UILayoutPriority(rawValue: 750)
                self.btnCancelOrder.tag = 101
            }
        }else {
            self.btnCancelOrder.setTitle(languageHelper.LocalString(key: "cancelOrder"), for: .normal)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            var orderDate = formatter.date(from: self.order.order_date) ?? Date()
            formatter.timeZone = TimeZone.current
            let dt = formatter.string(from: orderDate)
            orderDate = formatter.date(from: dt) ?? Date()
            
            if (Calendar.current.date(byAdding: .hour, value: (Int(self.order.cancelled_before) ?? 12) , to: orderDate)!) >= (Date()) {
                self.const_btnCancelOrder_aspectRatio.priority = UILayoutPriority(rawValue: 750)
            }
            self.btnCancelOrder.tag = 100
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
extension OrderDtailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arrProduct.count > 0 {
            return self.arrProduct.count + 2 + self.arrCoupons.count + (self.isDeliveryBoy ? 1 : 0)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.arrProduct.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellProduct", for: indexPath) as! CartTableCell
            let product = self.arrProduct[indexPath.row]
            cell.lblProductName.text = product.product_name
            cell.lblProductQuantity.text = product.quantity.replaceEnglishDigitsWithArabic
            cell.lblProductPrice.text = product.price.replaceEnglishDigitsWithArabic
            cell.imgProduct.kf.setImage(with:
                URL.init(string: product.product_image)!,
                                        placeholder: #imageLiteral(resourceName: "appicon.png"),
                                        options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                        progressBlock: nil,
                                        completionHandler: nil)
            cell.btnProductDetails.addTarget(self, action: #selector(btnProductDetailsAction(_:)), for: .touchUpInside)
            cell.btnProductDetails.tag = indexPath.row
            
            var strCat = ""
            if product.category.count > 0 {
                strCat = product.category[0].category_name
                if product.category[0].subcategories.count > 0 {
                    strCat = strCat + " > " + product.category[0].subcategories[0].category_name
                }
            }
            cell.lblProductCategory.text = strCat
            
            return cell;
        }else if indexPath.row == self.arrProduct.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellDetails", for: indexPath) as! OrderDetailsCell
            
            cell.lblDeliveryAddress.text = self.order.delivery_address
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let oDate = formatter.date(from: self.order.delivery_date)
            formatter.dateFormat = "dd MMM, yyyy"
            formatter.locale = languageHelper.getLocale()
            cell.lblDeliveryDate.text = formatter.string(from: oDate ?? Date())
            
            formatter.dateFormat = "HH:mm:ss"
            formatter.locale = Locale.current
            let sDate = formatter.date(from: order.delivery_start_time)
            let eDate = formatter.date(from: order.delivery_end_time)
            formatter.dateFormat = "hh:mm aa"
            formatter.locale = languageHelper.getLocale()
            
            cell.lblDeliveryTime.text = formatter.string(from: sDate ?? Date()) + " " + languageHelper.LocalString(key: "to") + " " + formatter.string(from: eDate ?? Date())
            cell.lblPaymentMethod.text = languageHelper.LocalString(key: "\(self.order.payment_mode)")
            
            cell.const_coupon_view_height.constant = self.arrCoupons.count <= 0 ? 0 : 50.5
            cell.lblCouponCodeText.text = (languageHelper.LocalString(key: "couponCode")).uppercased()
            
            return cell;
        }else if indexPath.row < (self.arrProduct.count + self.arrCoupons.count + 1) && self.arrCoupons.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellCoupon", for: indexPath) as! OrderDetailsCell
            
            var index = indexPath.row - (self.arrProduct.count + 1)
            index = index < 0 ? 0 : index
            (cell.viewWithTag(2) as! UILabel).text = "\(self.arrCoupons[index].value(forKey: "amount") ?? "0.00") \(languageHelper.LocalString(key: "OMR"))"
            (cell.viewWithTag(1) as! UILabel).text = "\(self.arrCoupons[index].value(forKey: "coupone_code") ?? "")"
            
            return cell;
        }else if indexPath.row == (self.arrProduct.count + self.arrCoupons.count + 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellPayment", for: indexPath) as! OrderDetailsCell
            
            cell.lblSubTotal.text = self.order.net_amount.replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            cell.lblDeliveryFee.text = self.order.delivery_charges.replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            
            var totalDisc = (Double(self.order.coupon_discount) ?? 0.00) + (Double(self.order.loyalty_discount) ?? 0.00)
            let subtotal = Double(self.order.net_amount) ?? 0.00
            totalDisc = totalDisc > subtotal ? subtotal : totalDisc
            
            cell.lblDiscount.text = (totalDisc == 0 ? "0.000" : String.init(format: "%.3f", totalDisc)).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            cell.lblTotalAmount.text = self.order.total_amount.replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            cell.lblOrderStatus.text = languageHelper.LocalString(key: "\(self.order.order_delivery_status)")
            return cell;
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellDeliveryBoy", for: indexPath)  as! OrderDetailsCell
            cell.lblDeliveryBoyName.text = "\(self.deliveryBoy.value(forKey: "name") ?? "")"
            cell.lblDeliveryBoyNumber.text = "\(self.deliveryBoy.value(forKey: "mobile_number") ?? "")"
            cell.btnCallDeliveryBoy.addTarget(self, action: #selector(btnCallDeliveryBoyAction(_:)), for: .touchUpInside)
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.arrProduct.count {
            return 113
        }else if indexPath.row > (self.arrProduct.count + self.arrCoupons.count + 1) {
            return 132
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == self.arrProduct.count) ? 105 : (indexPath.row == self.arrProduct.count ? 521 : 132)
    }
}

class OrderDetailsCell: UITableViewCell {
    
    @IBOutlet weak var lblDeliveryAddress: UILabel!
    @IBOutlet weak var lblDeliveryDate: UILabel!
    @IBOutlet weak var lblDeliveryTime: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblDeliveryFee: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    
    // Coupon Code Cell
    @IBOutlet weak var lblCouponCodeText: UILabel!
    @IBOutlet weak var const_coupon_view_height: NSLayoutConstraint!
    
    // Delivery Boy Information Cell
    @IBOutlet weak var lblDeliveryBoyName: UILabel!
    @IBOutlet weak var lblDeliveryBoyNumber: UILabel!
    @IBOutlet weak var btnCallDeliveryBoy: UIButton!
}



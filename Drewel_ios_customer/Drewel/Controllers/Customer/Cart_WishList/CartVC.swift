//
//  CartVC.swift
//  Drewel
//
//  Created by Octal on 12/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class CartVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, SetDefaultAddressDelegate {
    
    @IBOutlet weak var viewItemCount: UIView!
    @IBOutlet weak var viewCheckout: UIView!
    @IBOutlet weak var tblProductList: UITableView!
    @IBOutlet weak var const_ViewPrice_height: NSLayoutConstraint!
    
    @IBOutlet weak var lblTotalProducts: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet weak var btnProceedToCheckout: UIButton!
    
    var arrProducts = Array<ProductsData>()
    var totalPrice : Double = 0.00
    var discountedPrice : Double = 0.00
    var isOutOfStock = false
    var outStockIndex = -1
    var strOutStockName = ""
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setInitialValues() {
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
        self.getCartProductsAPI()
        self.title = languageHelper.LocalString(key: "myCart")
        self.showHideViews(isShow: self.arrProducts.count > 0)
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnPlusAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.updateCartAPI(index: sender.tag, change: 1)
    }
    
    @IBAction func btnMinusAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let qty = Int(self.arrProducts[sender.tag].quantity)!
        if qty > 1 {
            self.updateCartAPI(index: sender.tag, change: -1)
        }else {
            self.removeProductFromCartAPI(index: sender.tag)
        }
    }
    
    @IBAction func btnDeleteCartAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.removeProductFromCartAPI(index: sender.tag)
    }
    
    @IBAction func btnProceedToCheckoutAction(_ sender: UIButton) {
        
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
        
//        if self.discountedPrice < 5.000 {
//            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_minimum_order"), title: kAPPName)
//            return
//        }else
            if isOutOfStock {
            let index = IndexPath.init(row: self.outStockIndex, section: 0)
            self.tblProductList.scrollToRow(at: index, at: UITableViewScrollPosition.middle, animated: false)
            if let cell = self.tblProductList.cellForRow(at: index) {
                let cView = UIView.init(frame: cell.bounds)
                cView.backgroundColor = kThemeColor2
                cell.contentView.addSubview(cView)
                UIView.animate(withDuration: 1.0, animations: {
                    cView.alpha = 0
                }) { (finished) in
                    if finished {
                        cView.removeFromSuperview()
                    }
                }
            }
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "Remove_Outofstock"), title: kAPPName)
            return
        }
        let addressData = DeliveryAddressDetailsData()
        let dict = UserDefaults.standard.object(forKey: kDefaultAddress) as? NSDictionary ?? NSDictionary()
        
        if (dict.value(forKey: "full_address") as? String ?? "") != "" {
            addressData.address = dict.value(forKey: "address") as? String ?? ""
            addressData.latitude = dict.value(forKey: "latitude") as? String ?? ""
            addressData.longitude = dict.value(forKey: "longitude") as? String ?? ""
            addressData.zip_code = dict.value(forKey: "zip_code") as? String ?? ""
            addressData.id = dict.value(forKey: "id") as? String ?? ""
            
            addressData.name = dict.value(forKey: "user_name") as? String ?? ""
            addressData.phone_number = dict.value(forKey: "mobile_number") as? String ?? ""
            addressData.full_address = dict.value(forKey: "full_address") as? String ?? ""
            addressData.additional_details = dict.value(forKey: "landmark") as? String ?? ""
            addressData.delivery_address_type = "\(dict.value(forKey: "delivery_address_type") ?? "")"
            
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderSummaryVC") as! OrderSummaryVC
            vc.addressDetailsData = addressData
            vc.itemQuantity = self.arrProducts.count
            vc.priceSubTotal = self.totalPrice
            vc.discountedPrice = self.discountedPrice
            self.navigationController?.show(vc, sender: self)
        }else {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Please select your delivery address to continue."), preferredStyle: .alert)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
                let vc1 = kStoryboard_Customer.instantiateViewController(withIdentifier: "SearchAddressVC") as! SearchAddressVC
                vc1.delegate = self
                self.navigationController?.show(vc1, sender: nil)
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: { _ in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
//            self.performSegue(withIdentifier: "segueCheckout", sender: nil)
        }
    }
    
    @IBAction func btnContinueShopping(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func btnProductDetailsAction(_ sender: UIButton) {
        let product = self.arrProducts[sender.tag]
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsTableVC
        vc.categoryId = product.category.count > 0 ? (product.category.first?.id)! : ""
        vc.subCategoryId = ""
        vc.brandId = ""
        vc.product_id = product.product_id
        vc.productName = product.product_name
        self.navigationController?.show(vc, sender: nil)
    }
    
    // MARK: - WebService Method
    func getCartProductsAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Get_Cart, showAlert: false, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                
                self.strOutStockName = ""
                self.outStockIndex = -1
                self.isOutOfStock = false
                self.arrProducts.removeAll()
                let arrProduct = dict.object(forKey: "Cart") as! NSArray
                
                var totalQuantity = 0
                for j in 0..<arrProduct.count {
                    let brandDict = arrProduct[j] as! NSDictionary
                    var productData = ProductsData()
                    
                    productData.quantity = "\(brandDict.value(forKey: "quantity") ?? "0")"
                    productData.product_name = "\(brandDict.value(forKey: (languageHelper.isArabic() ? "ar_product_name" : "product_name")) ?? "")"
                    productData.product_id = "\(brandDict.value(forKey: "product_id") ?? "")"
                    productData.product_image = "\(brandDict.value(forKey: "product_image") ?? "")"
                    productData.price = "\(brandDict.value(forKey: "product_price") ?? "0.0")"
                    productData.out_of_stock = "\(brandDict.value(forKey: "out_of_stock") ?? "0")"
                    productData.offer_price = "\(brandDict.value(forKey: "offer_price") ?? "0")"
                    productData.offer_expires_on = "\(brandDict.value(forKey: "offer_expires_on") ?? "0")"
                    
                    let arrCategory = brandDict.object(forKey: "Category") as? NSArray ?? NSArray()
                    for i in 0..<arrCategory.count {
                        let catDict = arrCategory[i] as? NSDictionary ?? NSDictionary()
                        var category = ProductCategory()
                        category.id = "\(catDict.value(forKey: "id") ?? "")"
                        category.category_name = "\(catDict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) ?? "")"
                        category.img = "\(catDict.value(forKey: "img") ?? "")"
                        
                        let arrSubCat = brandDict.object(forKey: "SubCategory") as! NSArray
                        if arrSubCat.count > 0 {
                            let subCatDict = arrSubCat.firstObject as! NSDictionary;
                            var subCatData = ProductCategory();
                            subCatData.category_name = "\(subCatDict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) ?? "")"
                            subCatData.id = "\(subCatDict.value(forKey: "id") ?? "")"
                            subCatData.img = "\(subCatDict.value(forKey: "img") ?? "")"
                            category.subcategories.append(subCatData)
                        }
                        productData.category.append(category)
                    }
                    
                    // Out of Stock Check
                    if productData.out_of_stock == "1" {
                        self.strOutStockName = productData.product_name
                        self.outStockIndex = self.arrProducts.count
                        self.isOutOfStock = true
                    }
                    self.arrProducts.append(productData)
                    
                    // Calculating Price and Quantity
                    guard let price = Double("\(productData.price)") else {
                        continue
                    }
                    let dPrice = Double("\(productData.offer_price.isEmpty ? productData.price : productData.offer_price)") ?? 0.00
                    
                    self.totalPrice = self.totalPrice + (price * Double(productData.quantity)!)
                    self.discountedPrice = self.discountedPrice + (dPrice * Double(productData.quantity)!)
                    totalQuantity +=  Int(productData.quantity)!
                }
                
                self.showHideViews(isShow: self.arrProducts.count > 0)
                
                self.tblProductList.reloadData()
                self.lblTotalPrice.text = (String.init(format: "%.3f", self.discountedPrice)).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
                self.lblTotalProducts.text = ("\(self.arrProducts.count) " +  languageHelper.LocalString(key: "items")).replaceEnglishDigitsWithArabic
                
                self.userData.cart_quantity = "\(totalQuantity)"
                self.userData.cart_id = "\(result.value(forKey: "cart_id") ?? self.userData.cart_id)"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
            }else if status == "0" {
                self.userData.cart_quantity = "0"
                self.userData.cart_id = ""
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                self.viewCheckout.isHidden = self.arrProducts.count <= 0
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func updateCartAPI(index : Int, change : Int) {
        let product = self.arrProducts[index]
        var qty =  (Int(product.quantity)! + change)
        qty = qty <= 0 ? 0 : qty
        let price = Double(qty) * (Double(product.price) ?? 0.00)
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id,
                                    "product_id": product.product_id,
                                    "quantity"  : qty,
                                    "price"     : String.init(format: "%.3f", price)]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Update_Cart, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                if qty <= 0 {
                    self.arrProducts.remove(at: index)
                }else {
                    self.arrProducts[index].quantity = "\(qty)"
                }
                self.tblProductList.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                self.showCartTotal()
                
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                self.isOutOfStock = self.checkIfOutOfStock()
            }else {
                self.tblProductList.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func removeProductFromCartAPI(index : Int) {
        let product = self.arrProducts[index]
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id,
                                    "product_id": product.product_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Cart_Product, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrProducts.remove(at: index)
                self.tblProductList.reloadData()
                
                self.showCartTotal()
                self.showHideViews(isShow: self.arrProducts.count > 0)
                
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                self.isOutOfStock = self.checkIfOutOfStock()
            }else {
                self.tblProductList.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func checkIfOutOfStock() -> Bool {
        self.strOutStockName = ""
        self.outStockIndex = -1
        for i in 0..<self.arrProducts.count {
            let product = self.arrProducts[i]
            if product.out_of_stock == "1" {
                self.strOutStockName = product.product_name
                self.outStockIndex = i
                return true
            }
        }
        return false
    }
    
    //MARK: - SetDefaultAddress Delegate
    
    func seDefaultAddress(dict: NSDictionary) {
        UserDefaults.standard.set(dict, forKey: kDefaultAddress)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Other Methods
    
    func showHideViews(isShow : Bool) {
        self.viewItemCount.isHidden = !isShow
        self.tblProductList.isHidden = !isShow
        self.btnProceedToCheckout.isUserInteractionEnabled = isShow
        self.const_ViewPrice_height.constant = isShow ? 22 : 0
        self.viewCheckout.isHidden = !isShow
    }
    
    func showCartTotal() {
        self.totalPrice = 0.00
        self.discountedPrice = 0.00
        for product in self.arrProducts {
            guard let price = Double("\(product.price)") else {
                continue
            }
            let dPrice = Double("\(product.offer_price.isEmpty ? product.price : product.offer_price)") ?? 0.00
        
            self.discountedPrice = self.discountedPrice + (dPrice * Double(product.quantity)!)
            self.totalPrice = self.totalPrice + (price * Double(product.quantity)!)
        }
        self.lblTotalPrice.text = (String.init(format: "%.3f", self.discountedPrice)).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        self.lblTotalProducts.text = ("\(self.arrProducts.count) " +  languageHelper.LocalString(key: "items")).replaceEnglishDigitsWithArabic
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if isOutOfStock {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "Remove_Outofstock"), title: kAPPName)
            return false
        }
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCheckout" {
            let vc = segue.destination as! DeliveryDetailsVC
            vc.totalPrice = self.totalPrice
            vc.quantity = self.arrProducts.count
            vc.discountedPrice = self.discountedPrice
        }
    }
 
}

// MARK: -
//UITableView Delegate & Datasource
extension CartVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CartTableCell
        let product = self.arrProducts[indexPath.row]
        cell.lblProductName.text = product.product_name
        cell.lblProductPrice.text = ((product.offer_price.isEmpty ? product.price : product.offer_price) + " \(languageHelper.LocalString(key: "OMR"))").replaceEnglishDigitsWithArabic
        cell.lblActualPrice.text = (product.price + " \(languageHelper.LocalString(key: "OMR"))").replaceEnglishDigitsWithArabic
        cell.lblActualPrice.isHidden = product.offer_price.isEmpty
        cell.viewCross.isHidden = product.offer_price.isEmpty
        cell.lblProductQuantity.text = product.quantity.replaceEnglishDigitsWithArabic
        
        cell.imgProduct.kf.setImage(with:
            URL.init(string: product.product_image)!,
                                    placeholder: #imageLiteral(resourceName: "appicon.png"),
                                    options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                    progressBlock: nil,
                                    completionHandler: nil)
        
        cell.btnDelete.tag = indexPath.row
        cell.btnPlus.tag = indexPath.row
        cell.btnMinus.tag = indexPath.row
        cell.btnProductDetails.tag = indexPath.row
        
        cell.btnMinus.backgroundColor = /*product.quantity == "1" ? UIColor.lightGray : */kThemeColor1
        
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteCartAction(_:)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(btnPlusAction(_:)), for: .touchUpInside)
        cell.btnMinus.addTarget(self, action: #selector(btnMinusAction(_:)), for: .touchUpInside)
        cell.btnProductDetails.addTarget(self, action: #selector(btnProductDetailsAction(_:)), for: .touchUpInside)
        
        cell.lblOutOfStock.isHidden = product.out_of_stock == "0"
        cell.contentView.backgroundColor = (product.out_of_stock == "0") ? .white : .groupTableViewBackground
        var strCat = ""
        if product.category.count > 0 {
            strCat = product.category[0].category_name
            if product.category[0].subcategories.count > 0 {
                strCat = strCat + " > " + product.category[0].subcategories[0].category_name
            }
        }
        cell.lblProductCategory.text = strCat
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 143
    }
}



class CartTableCell : UITableViewCell {
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductQuantity: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblOutOfStock: UILabel!
    @IBOutlet weak var lblProductCategory: UILabel!
    @IBOutlet weak var lblActualPrice: UILabel!
    
    @IBOutlet weak var viewCross: UIView!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnProductDetails: UIButton!
}

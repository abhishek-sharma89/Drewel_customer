//
//  OfferListVC.swift
//  Drewel
//
//  Created by Octal on 01/10/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class OfferListVC: BaseViewController {
    @IBOutlet weak var collectionProductList: UICollectionView!
    @IBOutlet weak var btnDiscount: UIButton!
    @IBOutlet weak var btnCoupon: UIButton!
    @IBOutlet weak var viewUnderLine: UIView!
    
    @IBOutlet weak var btnAppLogo: UIBarButtonItem!
    @IBOutlet weak var tblOffers: UITableView!
    
    
    var arrProducts = Array<ProductsData>()
    
    var arrCoupons = Array<CouponData>()
    var isApply : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = languageHelper.LocalString(key: "discount")
        self.getProductListAPI()
        DispatchQueue.main.async {
            self.setupLayout()
        }
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setupLayout() {
        //setup collection view layout
        let cellWidth = (self.collectionProductList.frame.size.width - 45) / 2;
        var cellheight : CGFloat = 220/167 * cellWidth;
        if self.collectionProductList.frame.size.width < 340 {
            cellheight += 25;
        }
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = self.collectionProductList.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        self.collectionProductList.reloadData()
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnViewTypeAction(_ sender: UIButton) {
        if sender.tag == 1 {
            self.tblOffers.isHidden = true
            self.collectionProductList.isHidden = false
            self.getProductListAPI()
            self.btnDiscount.backgroundColor = .white
//            self.btnCoupon.backgroundColor = .groupTableViewBackground
        }else {
            self.tblOffers.isHidden = false
            self.collectionProductList.isHidden = true
            self.getCouponListAPI()
//            self.btnDiscount.backgroundColor = .groupTableViewBackground
            self.btnCoupon.backgroundColor = .white
        }
        UIView.animate(withDuration: 0.3) {
            self.viewUnderLine.frame.origin.x = sender.frame.origin.x
        }
    }
    
    @IBAction func btnAddToWishListAction(_ sender: UIButton) {
        self.addProductToWishList(productId: self.arrProducts[sender.tag].product_id, index: sender.tag)
    }
    
    @IBAction func btnAddToCartAction(_ sender: UIButton) {
        self.addProductToCart(productId: self.arrProducts[sender.tag].product_id, price: self.arrProducts[sender.tag].avg_price, index: sender.tag)
    }
    
    @IBAction func btnNotifyMeAction(_ sender: UIButton) {
        self.notifyMeAPI(productId: self.arrProducts[sender.tag].product_id)
    }
    
    // MARK: - WebService Method
    func getProductListAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Discounted_Product, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                self.arrProducts.removeAll()
                let arrProduct = dict.object(forKey: "Product") as? NSArray ?? NSArray()
                
                for j in 0..<arrProduct.count {
                    let brandDict = arrProduct[j] as! NSDictionary
                    var productData = ProductsData()
                    
                    productData.quantity = "\(brandDict.value(forKey: "quantity") ?? "")"
                    productData.min_quantity = "\(brandDict.value(forKey: "min_quantity") ?? "")"
                    productData.product_name = "\(brandDict.value(forKey: (languageHelper.isArabic() ? "ar_product_name" : "product_name")) ?? "")"
                    productData.is_wishlist = "\(brandDict.value(forKey: "is_wishlist") ?? "")"
                    productData.product_description = "\(brandDict.value(forKey: (languageHelper.isArabic() ? "ar_product_description" : "product_description")) ?? "")"
                    productData.avg_price = "\(brandDict.value(forKey: "avg_price") ?? "")"
                    productData.weight = "\(brandDict.value(forKey: "weight") ?? "")"
                    productData.price = "\(brandDict.value(forKey: "price") ?? "")"
                    productData.product_id = "\(brandDict.value(forKey: "product_id") ?? "")"
                    productData.weight_in = "\(brandDict.value(forKey: "weight_in") ?? "")"
                    productData.is_offer = "\(brandDict.value(forKey: "is_offer") ?? "")"
                    productData.offer_price = "\(brandDict.value(forKey: "offer_price") ?? "")"
                    productData.product_image = "\(brandDict.value(forKey: "product_image") ?? "")"
                    productData.avg_rating = "\(brandDict.value(forKey: "avg_rating") ?? "")"
                    productData.offer_expires_on = "\(brandDict.value(forKey: "offer_expires_on") ?? "")"
                    productData.out_of_stock = "\(brandDict.value(forKey: "out_of_stock") ?? "0")"
                    
                    self.arrProducts.append(productData)
                }
                
                self.collectionProductList.reloadData()
                DispatchQueue.main.async {
                    self.collectionProductList.setContentOffset(CGPoint.zero, animated: false)
                }
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func addProductToWishList(productId : String, index : Int) {
        let flag = self.arrProducts[index].is_wishlist == "0" ? "1" : "2"
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId,
                                    "flag"      : flag ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_AddRemove_Wish_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrProducts[index].is_wishlist = flag == "1" ? "1" : "0"
                self.collectionProductList.reloadItems(at: [IndexPath.init(row: index, section: 0)])
                let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: message), preferredStyle: .alert)
                alert.view.tintColor = kThemeColor1;
                // relate actions to controllers
                alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "thankYou"), style: UIAlertActionStyle.default) { _ in
                })
                
                self.present(alert, animated: true, completion: nil)
                //                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func addProductToCart(productId : String, price : String, index : Int) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId,
                                    "quantity"  : "1",
                                    "price"     : price,
                                    "cart_id"   : self.userData.cart_id,
                                    "wishlist_id" : ""]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Add_To_Cart, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                self.updateCartBadge()
                //                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func notifyMeAPI(productId : String) {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Add_To_Notify_Me, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func getCouponListAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Coupon_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let arrData = result.value(forKey: "Coupons") as! NSArray
                self.arrCoupons.removeAll()
                for i in 0..<arrData.count {
                    let dict = (arrData[i] as! NSDictionary).removeNullValueFromDict()
                    var coupon = CouponData()
                    coupon.id = "\(dict.value(forKey: "id") ?? "")"
                    coupon.coupon_code = "\(dict.value(forKey: "coupon_code") ?? "")"
                    coupon.discount = "\(dict.value(forKey: "discount") ?? "")"
                    coupon.discount_type = "\(dict.value(forKey: "discount_type") ?? "")"
                    coupon.category_id = "\(dict.value(forKey: "category_id") ?? "")"
                    coupon.category_name = languageHelper.isArabic() ? "\(dict.value(forKey: "ar_category_name") ?? "")" : "\(dict.value(forKey: "category_name") ?? "")"
                    coupon.max_use = "\(dict.value(forKey: "max_use") ?? "")"
                    coupon.coupon_description = "\(dict.value(forKey: (languageHelper.isArabic() ? "ar_coupon_description" : "coupon_description")) ?? "")"
                    coupon.expires_on = "\(dict.value(forKey: "expires_on") ?? "")"
                    coupon.img = "\(dict.value(forKey: "img") ?? "")"
                    coupon.is_used = "\(dict.value(forKey: "is_used") ?? "")"
                    
                    self.arrCoupons.append(coupon)
                }
                self.tblOffers.reloadData()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueProductDetails"{
            let vc = segue.destination as! ProductDetailsTableVC
            vc.categoryId = ""
            vc.subCategoryId = ""
            vc.brandId = ""
            vc.product_id = self.arrProducts[sender as! Int].product_id
            vc.productName = self.arrProducts[sender as! Int].product_name
        }
    }
    

}



// MARK: -
// UICollectionView Delegate & Datasource
extension OfferListVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductsListCell
        
        let product = self.arrProducts[indexPath.row]
        
        cell.imgProduct.kf.setImage(with:
            URL.init(string: product.product_image)!,
                                    placeholder: #imageLiteral(resourceName: "appicon.png"),
                                    options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                    progressBlock: nil,
                                    completionHandler: nil)
        
        cell.lblProductWeight.text = product.weight.replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "\(product.weight_in)")
        cell.lblProductName.text = product.product_name
        cell.lblProductPrice.text = (product.offer_price.isEmpty ? product.avg_price : product.offer_price).replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "OMR")
        
        cell.btnAddToWishList.tintColor = product.is_wishlist == "0" ? UIColor.lightGray : kThemeColor1
        cell.btnAddToWishList.addTarget(self, action: #selector(self.btnAddToWishListAction(_:)), for: .touchUpInside)
        cell.btnAddToCart.addTarget(self, action: #selector(self.btnAddToCartAction(_:)), for: .touchUpInside)
        cell.btnNotifyMe.addTarget(self, action: #selector(self.btnNotifyMeAction(_:)), for: .touchUpInside)
        
        cell.btnAddToWishList.tag = indexPath.row
        cell.btnAddToCart.tag = indexPath.row
        cell.btnNotifyMe.tag = indexPath.row
        
        cell.btnNotifyMe.isHidden = product.out_of_stock == "0"
        cell.lblOutOfStock.isHidden = product.out_of_stock == "0"
        cell.btnAddToCart.isHidden = product.out_of_stock == "1"
        
        
        cell.lblActualPrice.text = "\(round((Double(product.avg_price)! * 100))/100 )".replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "OMR")
        cell.lblActualPrice.isHidden = product.offer_price.isEmpty
        cell.viewCross.isHidden = product.offer_price.isEmpty
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.layer.cornerRadius = 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueProductDetails", sender: indexPath.row)
    }
    
}

extension OfferListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OffersTableViewCell
        
        let coupon = self.arrCoupons[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: coupon.expires_on) ?? Date()
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.locale = languageHelper.getLocale()
        cell.imgCoupon.kf.setImage(with:
            URL.init(string: coupon.img)!,
                                   placeholder: #imageLiteral(resourceName: "appicon.png"),
                                   options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                   progressBlock: nil,
                                   completionHandler: nil)
        cell.lblCouponCode.text = coupon.coupon_code
        cell.lblDiscount.text = "\(Int(Double(coupon.discount) ?? 0.00))" + (coupon.discount_type == "Fixed" ? " \(languageHelper.LocalString(key:"OMR"))" : "%")
        cell.lblExpiry.text = "\(languageHelper.LocalString(key: "expiresOn")) \(formatter.string(from: date))"
        cell.lblDescription.text = coupon.coupon_description
        cell.lblRedeemed.text = coupon.is_used == "0" ? (self.isApply ? languageHelper.LocalString(key: "apply") : "") : languageHelper.LocalString(key: "coupon_redeemed")
        cell.btnApplyCoupon.isUserInteractionEnabled = coupon.is_used == "0" ? true : false
        cell.btnApplyCoupon.tag = indexPath.row
        cell.btnApplyCoupon.isHidden = !self.isApply
//        cell.btnApplyCoupon.addTarget(self, action: #selector(btnApplyCouponCodeAction(_:)), for: .touchUpInside)
        cell.lblCategory.text = coupon.category_name
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath) as! OffersTableViewCell
        //
        //        UIPasteboard.general.string = self.arrCoupons[indexPath.row].coupon_code
        //
        //
        //        let popTip = SwiftPopTipView(title: nil, message: languageHelper.LocalString(key: "CouponCopied"))
        //        popTip.popColor = kThemeColor1
        //        popTip.titleColor = UIColor.white
        //        popTip.textColor = UIColor.white
        //
        //        popTip.presentAnimatedPointingAtView(cell.lblCouponCode as UIView , inView: view, autodismissAtTime: 2)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
}

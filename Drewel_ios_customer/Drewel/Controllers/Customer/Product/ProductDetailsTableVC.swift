//
//  ProductDetailsTableVC.swift
//  Drewel
//
//  Created by Octal on 28/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher
import SKPhotoBrowser

class ProductDetailsTableVC: BaseViewController {
    @IBOutlet weak var const_viewSimilar_height: NSLayoutConstraint!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnAddToWishList: UIButton!
    @IBOutlet weak var viewFooter: UIView!
    
    @IBOutlet weak var tblView: UITableView!
    
    var product_id = String()
    var brandId = String()
    var categoryId = String()
    var subCategoryId = String()
    var productName = String()
    var product = ProductsData()
    var similarProducts = Array<ProductsData>()
    
    var hView : ProductAddCartView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupLayout( collection : UICollectionView) {
        //setup collection view layout
        let cellWidth = collection.frame.size.width
        let cellheight : CGFloat = collection.frame.size.height
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        collection.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.similarProducts.removeAll()
        self.product.product_id = ""
        self.tblView.reloadData()
//        self.tblView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 0, height: 0), animated: false)
        self.getProductDetailsAPI()
    }
    
    func setInitialValues() {
        self.title = self.productName.count > 19 ? (String(self.productName.prefix(17)) + "..") : self.productName
    }
    
    
    // MARK: - UIButton Actions
    
    @IBAction func btnAddToWishListAction(_ sender: UIButton) {
        
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
        
        if self.product.is_wishlist == "0" {
            self.addProductToWishList(productId: self.product.product_id, flag: "1")
        }else {
            self.addProductToWishList(productId: self.product.product_id, flag: "2")
        }
    }
    
    @IBAction func btnAddToCartAction(_ sender: UIButton) {
        
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
        
        if self.hView?.btnAddToCart.tag == 1001 {
            self.notifyMeAPI()
        }else {
            self.addProductToCart(productId: self.product.product_id, price: self.product.avg_price)
        }
    }
    
    @IBAction func btnMinusAction(_ sender: UIButton) {
        
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
        
        if self.product.cart_qyantity == "1" {
            self.removeProductFromCartAPI()
        }else {
            self.updateCartAPI(change: -1)
        }
    }
    
//    @IBAction func btnShareAction(_ sender: UIButton) {
//        let cell = self.tblView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ProductDetailsTableCell
//        if (cell != nil) {
//            self.performSegue(withIdentifier: "segueShare", sender: (cell?.collectionProductImages.visibleCells.first?.viewWithTag(1) as! UIImageView).image!)
//        }
//    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        let cell = self.tblView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ProductDetailsTableCell
        let img = (cell?.collectionProductImages.visibleCells.first?.viewWithTag(1) as! UIImageView).image!
        //        let imgURL = self.product.ProductImage.count > 0 ? self.product.ProductImage[0] : ""
        let shareText = "\(kShareURL)\(self.product.product_id)"
        
        // set up activity view controller
        let textToShare = [ shareText, img ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnReviewAction(_ sender: UIButton) {
        
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
        
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductReviewVC") as! ProductReviewVC
        vc.product = self.product
        self.navigationController?.show(vc, sender: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShare" {
            let vc = segue.destination as! ShareProductVC
            vc.image = sender as! UIImage
            vc.imgUrl = self.product.ProductImage.count > 0 ? self.product.ProductImage[0] : ""
            vc.shareText = "\(languageHelper.LocalString(key: "checkThisOut")) \(self.product.product_name) at \(self.product.avg_price) \(languageHelper.LocalString(key: "OMR"))"
            vc.productName = self.product.product_name
        }
    }
    
    // MARK: - WebService Method
    func getProductDetailsAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": self.product_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_Details, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                
                let productDict = dict.object(forKey: "Product") as! NSDictionary
                var productData = ProductsData()
                
                productData.quantity = "\(productDict.value(forKey: "quantity") ?? "")"
                //productData.min_quantity = "\(productDict.value(forKey: "min_quantity") ?? "")"
                productData.product_name = "\(productDict.value(forKey: (languageHelper.isArabic() ? "ar_product_name" : "product_name")) ?? "")"
                productData.is_wishlist = "\(productDict.value(forKey: "is_wishlist") ?? "")"
                productData.product_description = "\(productDict.value(forKey: (languageHelper.isArabic() ? "ar_product_description" : "product_description")) ?? "")"
                productData.avg_price = "\(productDict.value(forKey: "avg_price") ?? "")"
                productData.weight = "\(productDict.value(forKey: "weight") ?? "")"
                productData.price = "\(productDict.value(forKey: "price") ?? "")"
                productData.product_id = "\(productDict.value(forKey: "product_id") ?? "")"
                productData.weight_in = "\(productDict.value(forKey: "weight_in") ?? "")"
                //productData.is_offer = "\(productDict.value(forKey: "is_offer") ?? "")"
                productData.offer_price = "\(productDict.value(forKey: "offer_price") ?? "")"
                //productData.product_image = "\(productDict.value(forKey: "product_image") ?? "")"
                productData.avg_rating = "\(productDict.value(forKey: "avg_rating") ?? "0")"
                productData.offer_expires_on = "\(productDict.value(forKey: "offer_expires_on") ?? "")"
                productData.out_of_stock = "\(productDict.value(forKey: "out_of_stock") ?? "0")"
                productData.brand_name = "\(productDict.value(forKey: (languageHelper.isArabic() ? "ar_brand_name" : "brand_name")) ?? "")"
                productData.brand_logo = "\(productDict.value(forKey: "brand_logo") ?? "")"
                productData.review_submited = "\(productDict.value(forKey: "review_submited") ?? "0")"
                productData.ProductImage = productDict.object(forKey: "ProductImage") as? Array<String> ?? Array<String>()
                
                productData.cart_qyantity = "\(productDict.value(forKey: "cart_qyantity") ?? "0")"
                productData.is_already_added_to_cart = "\(productDict.value(forKey: "is_already_added_to_cart") ?? "0")"
                
                self.brandId = "\(productDict.value(forKey: "brand_id") ?? "")"
                
                let arrSimilarProduct = dict.object(forKey: "RelatedProducts") as! NSArray
                for j in 0..<arrSimilarProduct.count {
                    let brandDict = arrSimilarProduct[j] as! NSDictionary;
                    var productsData = ProductsData();
                    
                    productsData.product_name = "\(brandDict.value(forKey: (languageHelper.isArabic() ? "ar_product_name" : "product_name")) ?? "")"
                    productsData.avg_price = "\(brandDict.value(forKey: "avg_price") ?? "")"
                    productsData.price = "\(brandDict.value(forKey: "price") ?? "")"
                    productsData.product_id = "\(brandDict.value(forKey: "product_id") ?? "")"
                    productsData.offer_price = "\(brandDict.value(forKey: "offer_price") ?? "")"
                    productsData.product_image = "\(brandDict.value(forKey: "product_image") ?? "")"
                    
                    self.similarProducts.append(productsData)
                }
                var arrCat = productDict.object(forKey: "Category") as! NSArray
                if arrCat.count > 0 {
                    let catDict = arrCat.firstObject as! NSDictionary;
                    var catData = ProductCategory();
                    catData.category_name = "\(catDict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) ?? "")"
                    catData.id = "\(catDict.value(forKey: "id") ?? "")"
                    catData.img = "\(catDict.value(forKey: "img") ?? "")"
                    
                    arrCat = productDict.object(forKey: "SubCategory") as! NSArray
                    if arrCat.count > 0 {
                        let subCatDict = arrCat.firstObject as! NSDictionary;
                        var subCatData = ProductCategory()
                        subCatData.category_name = "\(subCatDict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) ?? "")"
                        subCatData.id = "\(subCatDict.value(forKey: "id") ?? "")"
                        subCatData.img = "\(subCatDict.value(forKey: "img") ?? "")"
                        catData.subcategories.append(subCatData)
                    }
                    productData.category.append(catData)
                }
                
                self.product = productData
                
//                self.const_viewSimilar_height.constant = self.similarProducts.count > 0 ? 273 : 0
                
                self.tblView.reloadData()
                
                
//                self.setLabelText()
                
//                self.viewMain.isHidden = false
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func addProductToWishList(productId : String, flag : String) {

        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId,
                                    "flag"      : flag ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_AddRemove_Wish_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.product.is_wishlist = flag == "1" ? "1" : "0"
                
                    self.hView?.btnAddToWishlist.setTitle(self.product.is_wishlist == "0" ? languageHelper.LocalString(key: "addToFavList") : languageHelper.LocalString(key: "removeFromFavList"), for: .normal)
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
    
    func addProductToCart(productId : String, price : String) {
        
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
                
                self.hView?.btnAddToCart.isHidden = true
                self.product.cart_qyantity = "\(Int(self.product.cart_qyantity)! + 1)"
                self.hView?.lblCartCount.text = "\(Int(self.product.cart_qyantity)!)".replaceEnglishDigitsWithArabic
                
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func updateCartAPI(change : Int) {
        
        var qty =  (Int(product.cart_qyantity)! + change)
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
                self.product.cart_qyantity = "\(qty)"
                self.hView?.lblCartCount.text = "\(Int(self.product.cart_qyantity)!)".replaceEnglishDigitsWithArabic
                if qty <= 0 {
                    self.hView?.btnAddToCart.isHidden = false
                }else {
                    self.hView?.btnAddToCart.isHidden = true
                }
                
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                self.updateCartBadge()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func removeProductFromCartAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "cart_id"   : self.userData.cart_id,
                                    "product_id": product.product_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Cart_Product, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.product.cart_qyantity = "0"
                self.product.is_already_added_to_cart = "0"
                self.hView?.lblCartCount.text = "0".replaceEnglishDigitsWithArabic
                self.hView?.btnAddToCart.isHidden = false
                
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                self.updateCartBadge()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func notifyMeAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": self.product.product_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Add_To_Notify_Me, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }

}

// MARK: -
//UITableView Delegate & Datasource
extension ProductDetailsTableVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.similarProducts.count > 0 ? 2 : self.product.product_id == "" ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductDetailsTableCell
            cell.collectionProductImages.reloadData()
            cell.collectionProductImages.tag = indexPath.section
            
            cell.lblPrice.text = (self.product.offer_price.isEmpty ? product.avg_price : product.offer_price).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            cell.lblActualPrice.text = product.avg_price.replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
            cell.lblActualPrice.isHidden = self.product.offer_price.isEmpty
            cell.const_view_cross_width.priority = self.product.offer_price.isEmpty ? UILayoutPriority(rawValue: 750) : UILayoutPriority(rawValue: 250)
            cell.const_view_cross_trailing.priority = self.product.offer_price.isEmpty ? UILayoutPriority(rawValue: 250) : UILayoutPriority(rawValue: 750)
            
            cell.viewPager.numberOfPages = self.product.ProductImage.count
            cell.viewPager.currentPage = 1
            cell.viewPager.isHidden = self.product.ProductImage.count <= 1
            
            cell.lblProductName.text = product.product_name
            
            cell.lblWeight.text = product.weight.replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "\(product.weight_in)")
            cell.lblBrand.text = product.brand_name
            cell.lblDescription.text = product.product_description
            
            let rating = (product.avg_rating.isEmpty ? "0.0" : String.init(format: "%.1f", (Double(product.avg_rating) ?? 0.00)))
            cell.lblRating.text = rating.replaceEnglishDigitsWithArabic
            cell.ratingView.settings.fillMode = .precise
            cell.ratingView.rating = Double(rating) ?? 0.00
            
            cell.lblOutOfStock.isHidden = self.product.out_of_stock != "1"
            
            
            DispatchQueue.main.async {
                self.hView?.btnAddToWishlist.setTitle(self.product.is_wishlist == "0" ? languageHelper.LocalString(key: "addToFavList") : languageHelper.LocalString(key: "removeFromFavList"), for: .normal)
                self.setupLayout(collection: cell.collectionProductImages)
            }
            
            cell.btnShare.addTarget(self, action: #selector(btnShareAction(_:)), for: .touchUpInside)
            
            var strCat = ""
            if product.category.count > 0 {
                strCat = product.category[0].category_name
                if product.category[0].subcategories.count > 0 {
                    strCat = strCat + " > " + product.category[0].subcategories[0].category_name
                }
            }
            cell.lblSubCategory.text = strCat
            
            if !product.offer_price.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let oDate = formatter.date(from: product.offer_expires_on)
                formatter.dateFormat = "dd MMM yyyy"
                cell.lblOfferValidity.text = "\(languageHelper.LocalString(key: "offerValidBy")) " + formatter.string(from: oDate ?? Date())
                cell.const_offer_expiry_bottom.constant = 5
            }else {
                cell.lblOfferValidity.text = ""
                cell.const_offer_expiry_bottom.constant = 0
            }
            cell.btnReview.addTarget(self, action: #selector(btnReviewAction(_:)), for: .touchUpInside)
            
            return cell;
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PCell", for: indexPath) as! ProductDetailsTableCell
            cell.collectionSimilarProducts.reloadData()
            cell.collectionSimilarProducts.tag = indexPath.section
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.frame.size.height = self.view.bounds.size.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            hView = Bundle.main.loadNibNamed("ProductAddCartView", owner: self, options: nil)![0] as? ProductAddCartView
            hView?.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50)
            
            hView?.btnAddToCart.addTarget(self, action: #selector(btnAddToCartAction(_:)), for: .touchUpInside)
            hView?.btnPlus.addTarget(self, action: #selector(btnAddToCartAction(_:)), for: .touchUpInside)
            hView?.btnMinus.addTarget(self, action: #selector(btnMinusAction(_:)), for: .touchUpInside)
            hView?.btnAddToWishlist.addTarget(self, action: #selector(btnAddToWishListAction(_:)), for: .touchUpInside)
            self.hView?.btnAddToCart.isHidden = self.product.is_already_added_to_cart == "1"
            self.hView?.lblCartCount.text = self.product.cart_qyantity.replaceEnglishDigitsWithArabic
            
            self.hView?.btnAddToWishlist.setTitle(self.product.is_wishlist == "0" ? languageHelper.LocalString(key: "addToFavList") : languageHelper.LocalString(key: "removeFromFavList"), for: .normal)
            
            if self.product.out_of_stock == "1" {
                self.hView?.btnAddToCart.setTitle(languageHelper.LocalString(key: "notifyMe"), for: .normal)
                self.hView?.btnAddToCart.tag = 1001
            }
            
            return hView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section > 0 ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return (self.view.bounds.size.height - 50) <= 584 ? UITableViewAutomaticDimension : (self.view.bounds.size.height - 48)
//        }
        return UITableViewAutomaticDimension
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
}


// MARK: -
// UICollectionView Delegate & Datasource
extension ProductDetailsTableVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return self.similarProducts.count
        }else {
            return self.product.ProductImage.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSimilarProducts", for: indexPath) as! ProductsListCell
            let sProduct = self.similarProducts[indexPath.row]
            cell.imgProduct.kf.setImage(with:
                URL.init(string: sProduct.product_image)!,
                                        placeholder: #imageLiteral(resourceName: "appicon.png"),
                                        options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                        progressBlock: nil,
                                        completionHandler: nil)
            
            cell.lblProductName.text = sProduct.product_name
            cell.lblProductPrice.text = sProduct.avg_price.replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "OMR")
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellProductImages", for: indexPath)
            (cell.viewWithTag(1) as! UIImageView).kf.setImage(with:
                URL.init(string: self.product.ProductImage[indexPath.row])!,
                                                              placeholder: #imageLiteral(resourceName: "appicon.png"),
                                                              options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                                              progressBlock: nil,
                                                              completionHandler: nil)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            let cell1 = self.tblView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ProductDetailsTableCell
            if (cell1 != nil) {
                cell1?.viewPager.currentPage = indexPath.row
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            let sProduct = self.similarProducts[indexPath.row]
            let navVc = self.navigationController
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsTableVC
            vc.product_id = sProduct.product_id
            vc.productName = sProduct.product_name
            
            self.navigationController?.popViewController(animated: false)
            navVc?.pushViewController(vc, animated: false)
        }else {
            // 1. create URL Array
            var images = [SKPhoto]()
            for i in 0..<self.product.ProductImage.count {
                let photo = SKPhoto.photoWithImageURL(self.product.ProductImage[i])
                photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
                images.append(photo)
            }
            // 2. create PhotoBrowser Instance, and present.
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(indexPath.row)
            
            self.present(browser, animated: true, completion: {})
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cell = self.tblView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ProductDetailsTableCell
        if (cell != nil) {
            if scrollView == cell?.collectionProductImages {
                cell?.viewPager.currentPage = (cell?.collectionProductImages.indexPathsForVisibleItems[0].row)!
            }
        }
    }

}


// MARK: -
class ProductDetailsTableCell: UITableViewCell {
    @IBOutlet weak var collectionSimilarProducts: UICollectionView!
    @IBOutlet weak var collectionProductImages: UICollectionView!
    
    @IBOutlet weak var const_view_cross_trailing: NSLayoutConstraint!
    @IBOutlet weak var const_view_cross_width: NSLayoutConstraint!
    @IBOutlet weak var const_offer_expiry_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var lblOfferValidity: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblSubCategory: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblOutOfStock: UILabel!
    @IBOutlet weak var lblActualPrice: UILabel!
    
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var viewPager: UIPageControl!
    @IBOutlet weak var btnReview: UIButton!
    
}

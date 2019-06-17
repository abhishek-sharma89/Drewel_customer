//
//  ProductDetailsVC.swift
//  Drewel
//
//  Created by Octal on 10/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher
import SKPhotoBrowser


class ProductDetailsVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionSimilarProducts: UICollectionView!
    @IBOutlet weak var collectionProductImages: UICollectionView!
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblSubCategory: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblOutOfStock: UILabel!
    
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnAddToWishList: UIButton!
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var viewPager: UIPageControl!
    @IBOutlet weak var const_viewSimilar_height: NSLayoutConstraint!
    
    var product_id = String()
    var brandId = String()
    var categoryId = String()
    var subCategoryId = String()
    var productName = String()
    var product = ProductsData()
    
    
    var similarProducts = Array<ProductsData>();
    
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
    
    fileprivate func setupLayout() {
        //setup collection view layout
        let cellWidth = self.collectionProductImages.frame.size.width;
        let cellheight : CGFloat = self.collectionProductImages.frame.size.height;
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = self.collectionProductImages.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        self.collectionProductImages.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setInitialValues() {
        self.viewMain.isHidden = true
        self.title = self.productName.count > 22 ? (String(self.productName.prefix(20)) + "..") : self.productName
        self.getProductDetailsAPI()
        DispatchQueue.main.async {
            self.setupLayout()
        }
    }
    
    func setLabelText() {
        self.lblProductName.text = product.product_name
        self.lblPrice.text = "\((round(Double(product.avg_price)! * 100))/100)" + " " + languageHelper.LocalString(key: "OMR")
        self.lblWeight.text = product.weight + " " + languageHelper.LocalString(key: "\(product.weight_in)")
        self.lblBrand.text = product.brand_name
        self.lblDescription.text = product.product_description
        self.lblRating.text = product.avg_rating.isEmpty ? "0.0" : product.avg_rating
        
        self.ratingView.rating = product.avg_rating.isEmpty ? 0.00 : Double(product.avg_rating)!
        self.btnAddToWishList.setTitle(self.product.is_wishlist == "0" ? languageHelper.LocalString(key: "addToWishList") : languageHelper.LocalString(key: "removeFromWishList"), for: .normal)
        
        if self.product.out_of_stock == "1" {
            self.lblOutOfStock.isHidden = false
            self.btnAddToCart.setTitle(languageHelper.LocalString(key: "notifyMe"), for: .normal)
            self.btnAddToCart.tag = 1001
        }
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
        
        if self.btnAddToCart.tag == 1001 {
            self.notifyMeAPI()
        }else {
            self.addProductToCart(productId: self.product.product_id, price: self.product.avg_price)
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
                productData.product_name = "\(productDict.value(forKey: "product_name") ?? "")"
                productData.is_wishlist = "\(productDict.value(forKey: "is_wishlist") ?? "")"
                productData.product_description = "\(productDict.value(forKey: "product_description") ?? "")"
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
                productData.brand_name = "\(productDict.value(forKey: "brand_name") ?? "")"
                productData.brand_logo = "\(productDict.value(forKey: "brand_logo") ?? "")"
                productData.ProductImage = productDict.object(forKey: "ProductImage") as? Array<String> ?? Array<String>()
                self.brandId = "\(productDict.value(forKey: "brand_id") ?? "")"
                
                let arrSimilarProduct = dict.object(forKey: "RelatedProducts") as! NSArray
                for j in 0..<arrSimilarProduct.count {
                    let brandDict = arrSimilarProduct[j] as! NSDictionary
                    var productData = ProductsData()
                    
                    productData.product_name = "\(brandDict.value(forKey: "product_name") ?? "")"
                    productData.avg_price = "\(brandDict.value(forKey: "avg_price") ?? "")"
                    productData.price = "\(brandDict.value(forKey: "price") ?? "")"
                    productData.product_id = "\(brandDict.value(forKey: "product_id") ?? "")"
                    productData.offer_price = "\(brandDict.value(forKey: "offer_price") ?? "")"
                    productData.product_image = "\(brandDict.value(forKey: "product_image") ?? "")"
                    
                    self.similarProducts.append(productData)
                }
                
                self.product = productData
                
                self.collectionProductImages.reloadData()
                self.collectionSimilarProducts.reloadData()
                self.const_viewSimilar_height.constant = self.similarProducts.count > 0 ? 273 : 0
                
                self.viewPager.numberOfPages = self.product.ProductImage.count
                self.viewPager.currentPage = 1
                self.viewPager.isHidden = self.product.ProductImage.count <= 1
                self.setLabelText()
                
                self.viewMain.isHidden = false
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
                self.btnAddToWishList.setTitle(self.product.is_wishlist == "0" ? languageHelper.LocalString(key: "addToWishList") : languageHelper.LocalString(key: "removeFromWishList"), for: .normal)
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
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
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
    
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShare" {
            let vc = segue.destination as! ShareProductVC
            vc.image = (self.collectionProductImages.visibleCells.first?.viewWithTag(1) as! UIImageView).image!
            vc.imgUrl = self.product.ProductImage.count > 0 ? self.product.ProductImage[0] : ""
            vc.shareText = "\(languageHelper.LocalString(key: "checkThisOut")) \(self.product.product_name) at \(self.product.avg_price) \(languageHelper.LocalString(key: "OMR"))"
            vc.productName = self.product.product_name
        }
    }
    
}

// MARK: -
// UICollectionView Delegate & Datasource
extension ProductDetailsVC {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionSimilarProducts {
            return self.similarProducts.count
        }else {
            return self.product.ProductImage.count
        }   
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionSimilarProducts {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSimilarProducts", for: indexPath) as! ProductsListCell
            let sProduct = self.similarProducts[indexPath.row]
            cell.imgProduct.kf.setImage(with:
                URL.init(string: sProduct.product_image)!,
                                        placeholder: #imageLiteral(resourceName: "appicon.png"),
                                        options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                        progressBlock: nil,
                                        completionHandler: nil)
            
            cell.lblProductName.text = sProduct.product_name
            cell.lblProductPrice.text = "\(round((Double(sProduct.price)! * 100))/100 )" + " " + languageHelper.LocalString(key: "OMR")
            
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
        if collectionView == self.collectionProductImages {
            self.viewPager.currentPage = indexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionSimilarProducts {
            let sProduct = self.similarProducts[indexPath.row]
            let navVc = self.navigationController
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
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
        
        if scrollView == self.collectionProductImages {
            self.viewPager.currentPage = self.collectionProductImages.indexPathsForVisibleItems[0].row
        }
    }
    
}

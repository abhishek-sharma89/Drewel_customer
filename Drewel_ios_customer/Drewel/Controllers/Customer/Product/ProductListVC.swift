//
//  ProductListVC.swift
//  Drewel
//
//  Created by Octal on 10/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class ProductListVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionProductList: UICollectionView!
    
    var categoryId = String()
    var subCategoryId = String()
    var brandIds = Array<String>()
    var brandName = String()
    
    var totalItems = ProductsInCategories()
    
    
    var isSeaching = Bool()
    var searchKey = String()
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func setInitialValues() {
        
        if !isSeaching {
            let strTitle = self.brandName.isEmpty ? "Search" : self.brandName
            self.title = strTitle.count > 22 ? (String(strTitle.prefix(20)) + "..") : strTitle
            self.getProductListAPI()
        }else {
            self.title = self.searchKey.count > 22 ? (String(self.searchKey.prefix(20)) + "..") : self.searchKey//self.searchKey
            self.getProductListBySearch()
        }
        DispatchQueue.main.async {
            self.setupLayout()
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
        
        self.addProductToWishList(productId: self.totalItems.Brands[0].Products[sender.tag].product_id, index: sender.tag)
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
        self.addProductToCart(productId: self.totalItems.Brands[0].Products[sender.tag].product_id, price: self.totalItems.Brands[0].Products[sender.tag].avg_price, index: sender.tag)
    }
    
    @IBAction func btnNotifyMeAction(_ sender: UIButton) {
        
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
        
        self.notifyMeAPI(productId: self.totalItems.Brands[0].Products[sender.tag].product_id)
    }
    
    // MARK: - WebService Method
    func getProductListBySearch() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "key"       : self.searchKey]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_List_By_Search, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                self.totalItems.Brands_list.removeAll()
                self.totalItems.Brands.removeAll()
                
                self.totalItems.min_price = "\(dict.value(forKey: "min_price") ?? "")"
                self.totalItems.max_price = "\(dict.value(forKey: "max_price") ?? "")"
                
                for _ in 0..<1 {
                    var brandNproducts = BrandDetails()
                    
                    
                    let arrProduct = dict.object(forKey: "Product") as! NSArray
                    
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
                        
                        brandNproducts.Products.append(productData)
                    }
                    self.totalItems.Brands.append(brandNproducts)
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
    
    func getProductListAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "category_id": categoryId,
                                    "sub_category_id" : subCategoryId,
                                    "brands_id" : brandIds]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_List_By_Category, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                self.totalItems.Brands_list.removeAll()
                self.totalItems.Brands.removeAll()
                
                self.totalItems.min_price = "\(dict.value(forKey: "min_price") ?? "")"
                self.totalItems.max_price = "\(dict.value(forKey: "max_price") ?? "")"
                
                let brandsList = dict.object(forKey: "Brands_list") as! NSArray
                
                for i in 0..<brandsList.count {
                    let brandDict = brandsList[i] as! NSDictionary
                    var brands = BrandDetails()
                    
                    brands.brand_id = "\(brandDict.value(forKey: "brand_id") ?? "")"
                    brands.brand_name = "\(brandDict.value(forKey: (languageHelper.isArabic() ? "ar_brand_name" : "brand_name")) ?? "")"
                    brands.total_products = "\(brandDict.value(forKey: "total_products") ?? "")"
                    self.totalItems.Brands_list.append(brands)
                }
                
                
                let arrBrandsProducts = dict.object(forKey: "Brands") as! NSArray
                for i in 0..<arrBrandsProducts.count {
                    var brandNproducts = BrandDetails()
                    let brandProduct = arrBrandsProducts[i] as! NSDictionary
                    
                    brandNproducts.brand_id = "\(brandProduct.value(forKey: "brand_id") ?? "")"
                    brandNproducts.brand_name = "\(brandProduct.value(forKey: (languageHelper.isArabic() ? "ar_brand_name" : "brand_name")) ?? "")"
                    brandNproducts.brand_logo = "\(brandProduct.value(forKey: "brand_logo") ?? "")"
                    
                    let arrProduct = brandProduct.object(forKey: "Products") as! NSArray
                    
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
                        
                        brandNproducts.Products.append(productData);
                    }
                    
                    self.totalItems.Brands.append(brandNproducts)
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
        let flag = self.totalItems.Brands[0].Products[index].is_wishlist == "0" ? "1" : "2"
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId,
                                    "flag"      : flag ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_AddRemove_Wish_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.totalItems.Brands[0].Products[index].is_wishlist = flag == "1" ? "1" : "0"
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
    
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueProductDetails"{
            let vc = segue.destination as! ProductDetailsTableVC
            vc.categoryId = self.categoryId
            vc.subCategoryId = self.subCategoryId
            vc.brandId = self.totalItems.Brands[0].brand_id
            vc.product_id = self.totalItems.Brands[0].Products[sender as! Int].product_id
            vc.productName = self.totalItems.Brands[0].Products[sender as! Int].product_name
        }
    }
 
}

// MARK: -
// UICollectionView Delegate & Datasource
extension ProductListVC {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.totalItems.Brands.count <= 0 {
            return 0
        }
        return self.totalItems.Brands[0].Products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductsListCell
        if self.totalItems.Brands.count <= 0 {
            return cell;
        }
        
        let product = self.totalItems.Brands[0].Products[indexPath.row]
        
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
        
        
        cell.lblActualPrice.text = "\(round(((Double(product.avg_price) ?? 0.0)! * 100))/100 )".replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "OMR")
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

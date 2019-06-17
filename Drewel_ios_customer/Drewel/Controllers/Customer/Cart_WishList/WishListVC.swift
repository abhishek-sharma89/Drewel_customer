//
//  WishListVC.swift
//  Drewel
//
//  Created by Octal on 11/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class WishListVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionProductList: UICollectionView!
    
    
    var arrProducts = Array<ProductsData>()
    
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
        self.getProductListAPI()
    }
    
    fileprivate func setupLayout() {
        //setup collection view layout
        let cellWidth = (self.collectionProductList.frame.size.width - 45) / 2;
        var cellheight : CGFloat = 250/165 * cellWidth;
        if self.collectionProductList.frame.size.width < 340 {
            cellheight += 30
        }
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = self.collectionProductList.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        self.collectionProductList.reloadData()
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "myFavouriteList")
        DispatchQueue.main.async {
            self.setupLayout()
        }
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnMoveToCartAction(_ sender: UIButton) {
        self.addProductToCart(productId: self.arrProducts[sender.tag].product_id, price: self.arrProducts[sender.tag].avg_price, index: sender.tag)
    }
    
    @IBAction func btnRemoveFromWishListAction(_ sender: UIButton) {
        self.removeProductFromWishList(productId: self.arrProducts[sender.tag].product_id, index: sender.tag)
    }
    
    // MARK: - WebService Method
    func getProductListAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Get_Wish_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                
                self.arrProducts.removeAll()
                let arrProduct = dict.object(forKey: "Products") as! NSArray
                    
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
                    productData.out_of_stock = "\(brandDict.value(forKey: "out_of_stock") ?? "")"
                    productData.wishlist_id = "\(brandDict.value(forKey: "wishlist_id") ?? "")"
                    
                    self.arrProducts.append(productData);
                }
                self.collectionProductList.isHidden = !(self.arrProducts.count > 0)
                self.collectionProductList.reloadData()
                DispatchQueue.main.async {
                    self.collectionProductList.setContentOffset(CGPoint.zero, animated: false)
                }
            }else {
                self.arrProducts.removeAll()
                self.collectionProductList.reloadData()
                self.collectionProductList.isHidden = true
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
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
                                    "wishlist_id" : ""]//self.arrProducts[index].wishlist_id]
        
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
                
//                self.arrProducts.remove(at: index)
//                self.collectionProductList.reloadData()
                self.collectionProductList.isHidden = !(self.arrProducts.count > 0)
//                self.removeProductToWishList(productId: productId, index: index)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func removeProductFromWishList(productId : String, index : Int) {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId,
                                    "flag"      : "2" ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_AddRemove_Wish_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrProducts.remove(at: index)
                self.collectionProductList.reloadData()
                self.collectionProductList.isHidden = !(self.arrProducts.count > 0)
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
            vc.product_id = self.arrProducts[sender as! Int].product_id
            vc.productName = self.arrProducts[sender as! Int].product_name
        }
     }
 
}

// MARK: -
// UICollectionView Delegate & Datasource
extension WishListVC {
    
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
        
        
        cell.btnRemove.addTarget(self, action: #selector(btnRemoveFromWishListAction(_:)), for: .touchUpInside)
        
        cell.btnAddToCart.tag = indexPath.row
        cell.btnRemove.tag = indexPath.row
        
        cell.lblOutOfStock.isHidden = product.out_of_stock == "0"
        if product.out_of_stock == "0" {
            cell.btnAddToCart.addTarget(self, action: #selector(btnMoveToCartAction(_:)), for: .touchUpInside)
            cell.btnAddToCart.setTitle(languageHelper.LocalString(key: "addToCart"), for: .normal)
            cell.btnAddToCart.backgroundColor = kThemeColor1
            cell.btnAddToCart.setTitleColor(.white, for: .normal)
        }else {
            cell.btnAddToCart.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnAddToCart.setTitle(languageHelper.LocalString(key: "outOfStock"), for: .normal)
            cell.btnAddToCart.backgroundColor = .white
            cell.btnAddToCart.setTitleColor(.red, for: .normal)
        }
        
        
        cell.lblActualPrice.text = product.avg_price.replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "OMR")
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


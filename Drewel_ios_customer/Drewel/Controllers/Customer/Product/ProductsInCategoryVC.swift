//
//  ProductsInCategoryVC.swift
//  Drewel
//
//  Created by Octal on 10/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

var viewHeight = CGRect.zero

class ProductsInCategoryVC: BaseViewController, FilterDelegate, SortDelegate {
    

    @IBOutlet weak var collectionPager: UICollectionView!
    @IBOutlet weak var tblProductInCategories: UITableView!
    @IBOutlet weak var viewSize: UIView!
    
    @IBOutlet weak var const_viewPages_height: NSLayoutConstraint!
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var pageActivityInd: UIActivityIndicatorView!
    
    var selectedCategory = ProductCategory()
    var selectedSubCategory = ""
    var selectedSubCategoryIndex = 0
    var totalItems = ProductsInCategories()
    var unfilteredItems = ProductsInCategories()
    
    var isFiltered : Bool = false
    var filterData = FilterData()
    var sortingIndex = ""
    
    var pageNumber = 1
    var pagingEnabled = true
    var isTabChanged = false
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        viewHeight = self.viewSize.frame
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
        self.title = self.selectedCategory.category_name
        
        self.title = self.selectedCategory.category_name.count > 22 ? (String(self.selectedCategory.category_name.prefix(20)) + "..") : self.selectedCategory.category_name
        
        
        if self.selectedCategory.subcategories.count > 0 {
            self.selectedSubCategory = selectedCategory.subcategories[0].id
        }
        self.getProductListNewAPI(withIndex: 0, subCategory: self.selectedSubCategory)
        if selectedCategory.id == "" || self.selectedCategory.subcategories.count <= 0 {
            self.const_viewPages_height.constant = 0
        }
        
        DispatchQueue.main.async {
            self.collectionPager.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueSearch", sender: nil)
    }
    
    @IBAction func btnFilterAction(_ sender: UIButton) {
        if self.totalItems.Brands.count == 0 && self.unfilteredItems.Brands.count == 0 {
            return
        }
        self.performSegue(withIdentifier: "segueFilter", sender: nil)
    }
    
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
        
        let collection = (sender.superview?.superview?.superview?.superview as! UICollectionView)
        self.addProductToWishList(productId: self.totalItems.Brands[collection.tag].Products[sender.tag].product_id, collection: collection, index: sender.tag)
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
        
        let collection = (sender.superview?.superview?.superview?.superview as! UICollectionView)
        self.addProductToCart(productId: self.totalItems.Brands[collection.tag].Products[sender.tag].product_id, price: self.totalItems.Brands[collection.tag].Products[sender.tag].avg_price, collection: collection, index: sender.tag)
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
        
        let collection = (sender.superview?.superview?.superview?.superview as! UICollectionView)
        
        self.addToNotifyMeAPI(productId: self.totalItems.Brands[collection.tag].Products[sender.tag].product_id)
    }
    
    // MARK: - Filter Delegate
    func applyFilterWithData(fData: FilterData, isFilter: Bool) {
        print(fData);
        self.isFiltered = isFilter
        self.filterData = fData
        self.pageNumber = 1
        self.pagingEnabled = true
        self.isTabChanged = true
        self.getProductListNewAPI(withIndex: self.selectedSubCategoryIndex, subCategory: self.selectedSubCategory)
    }
    
    // MARK: - Sort Delegate
    
    func applySortWithData(index: Int) {
        self.sortingIndex = "\(index)"
        self.pageNumber = 1
        self.pagingEnabled = true
        self.isTabChanged = true
        self.getProductListNewAPI(withIndex: self.selectedSubCategoryIndex, subCategory: self.selectedSubCategory)
    }
    
    // MARK: - WebService Method
    func getProductListAPI(withIndex index: Int, subCategory: String) {
        let param : NSMutableDictionary = ["user_id"   : self.userData.user_id,
                                           "language"  : languageHelper.language,
                                           "category_id": selectedCategory.id,
                                           "sub_category_id" : subCategory,
                                           "sort_by" : self.sortingIndex,
                                           /*"page"       : "1"*/]
        
        if self.isFiltered {
            param.setValue(filterData.max_Price, forKey: "max_price")
            param.setValue(filterData.min_Price, forKey: "min_price")
            param.setValue(filterData.star_Rating, forKey: "ratings")
            param.setValue(filterData.brand_iDs, forKey: "brands_id")
        }
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_List_By_Category, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let dict = result.removeNullValueFromDict()
                DispatchQueue.main.async {
                    self.tblProductInCategories.setContentOffset(CGPoint.zero, animated: false)
                }
                self.selectedSubCategoryIndex = index
                if self.selectedCategory.subcategories.count > 0 {
                    self.selectedSubCategory = self.selectedCategory.subcategories[index].id
                }
                
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
                self.collectionPager.reloadData()
                self.tblProductInCategories.reloadData()
                
                if !self.isFiltered { // So that filter have all the options always
                    self.unfilteredItems = self.totalItems
                }
            }else {
                if self.isFiltered { // So that filter data refresh even if no product found
                    self.totalItems.Brands.removeAll()
                    self.tblProductInCategories.reloadData()
                }
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func getProductListNewAPI(withIndex index: Int, subCategory: String) {
        let param : NSMutableDictionary = ["user_id"   : self.userData.user_id,
                                           "language"  : languageHelper.language,
                                           "category_id": selectedCategory.id,
                                           "sub_category_id" : subCategory,
                                           "sort_by" : self.sortingIndex,
                                           "page"       : "\(self.pageNumber)"]
        
        if self.isFiltered {
            param.setValue(filterData.max_Price, forKey: "max_price")
            param.setValue(filterData.min_Price, forKey: "min_price")
            param.setValue(filterData.star_Rating, forKey: "ratings")
            param.setValue(filterData.brand_iDs, forKey: "brands_id")
        }
        if self.pageNumber > 1 {
            self.pageActivityInd.isHidden = false
            self.pageActivityInd.startAnimating()
        }
        if self.isTabChanged {
            param.setValue("1", forKey: "page")
        }
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_List_By_Category_New, showAlert: true, showHud: pageNumber == 1, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.pageNumber += 1
                self.pageActivityInd.isHidden = true
                self.pageActivityInd.stopAnimating()
                
                let dict = result.removeNullValueFromDict()
                
                if self.isTabChanged {
                    self.totalItems.Brands_list.removeAll()
                    self.totalItems.Brands.removeAll()
                    self.pageNumber = 2
                }
                
                DispatchQueue.main.async {
                    if self.pageNumber == 1 || self.isTabChanged {
                        self.tblProductInCategories.setContentOffset(CGPoint.zero, animated: false)
                    }
                    self.isTabChanged = false
                }
                
                self.selectedSubCategoryIndex = index
                if self.selectedCategory.subcategories.count > 0 {
                    self.selectedSubCategory = self.selectedCategory.subcategories[index].id
                }
                
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
                        
                        brandNproducts.Products.append(productData)
                    }
                    
                    if let br_index = self.totalItems.Brands.firstIndex(where: { (brand) -> Bool in
                        return brand.brand_id == brandNproducts.brand_id
                    }) {
                        self.totalItems.Brands[br_index].Products.append(contentsOf: brandNproducts.Products)
                    }else {
                        self.totalItems.Brands.append(brandNproducts)
                    }
                }
//                DispatchQueue.main.async {
                    self.collectionPager.reloadData()
                    self.tblProductInCategories.reloadData()
//                }
                
                if !self.isFiltered { // So that filter have all the options always
                    self.unfilteredItems = self.totalItems
                }
                self.pagingEnabled = true
            }else {
                if self.isFiltered && self.isTabChanged { // So that filter data refresh even if no product found
                    self.totalItems.Brands.removeAll()
                    self.tblProductInCategories.reloadData()
                }
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                self.pagingEnabled = false
                self.pageActivityInd.isHidden = true
                self.pageActivityInd.stopAnimating()
            }
        }
    }
    
    func addProductToWishList(productId : String, collection : UICollectionView, index : Int) {
        let flag = self.totalItems.Brands[collection.tag].Products[index].is_wishlist == "0" ? "1" : "2"
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": productId,
                                    "flag"      : flag ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_AddRemove_Wish_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.totalItems.Brands[collection.tag].Products[index].is_wishlist = flag == "1" ? "1" : "0"
                collection.reloadItems(at: [IndexPath.init(row: index, section: 0)])
                
                
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
    
    func addProductToCart(productId : String, price : String, collection : UICollectionView, index : Int) {
        
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
    
    func addToNotifyMeAPI(productId : String) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFilter" {
            let vc = segue.destination as! FilterProductVC
            vc.delegate = self
            vc.brands = self.unfilteredItems.Brands
            vc.minPrice = Double(self.unfilteredItems.min_price) ?? 0.00
            vc.maxPrice = Double(self.unfilteredItems.max_price) ?? 0.00
            vc.filterData = self.filterData
        }else if segue.identifier == "segueProductList" {
            let vc = segue.destination as! ProductListVC
            vc.categoryId = self.selectedCategory.id
            vc.subCategoryId =  self.selectedCategory.subcategories.count > 0 ? self.selectedCategory.subcategories[selectedSubCategoryIndex].id : ""
            vc.brandIds = [self.totalItems.Brands[sender as! Int].brand_id]
            vc.brandName = self.totalItems.Brands[sender as! Int].brand_name
        }else if segue.identifier == "segueProductDetails"{
            let vc = segue.destination as! ProductDetailsTableVC
            vc.categoryId = self.selectedCategory.id
            vc.subCategoryId = self.selectedCategory.subcategories.count > 0 ? self.selectedCategory.subcategories[selectedSubCategoryIndex].id : ""
            vc.brandId = self.totalItems.Brands[(sender as! NSArray)[0] as! Int].brand_id
            vc.product_id = self.totalItems.Brands[(sender as! NSArray)[0] as! Int].Products[(sender as! NSArray)[1] as! Int].product_id
            vc.productName = self.totalItems.Brands[(sender as! NSArray)[0] as! Int].Products[(sender as! NSArray)[1] as! Int].product_name
        }else if segue.identifier == "segueSort" {
            let vc = segue.destination as! SortProductVC
            vc.selectedIndex = Int(self.sortingIndex) ?? -1
            vc.delegate = self
        }
    }
}

// MARK: -
//UITableView Delegate & Datasource
extension ProductsInCategoryVC : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total Index \(self.totalItems.Brands.count * 2)")
        return self.totalItems.Brands.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellBrand", for: indexPath) as! ProductNcategories
            cell.lblBrandName.text = self.totalItems.Brands[Int(indexPath.row / 2)].brand_name
            cell.lblTotalProducts.text = "\(self.totalItems.Brands[Int(indexPath.row / 2)].Products.count)".replaceEnglishDigitsWithArabic
            return cell;
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellProducts", for: indexPath) as! ProductNcategories
            
//            // By pawan
//            if languageHelper.isArabic()
//            {
//                cell.collectionProducts.semanticContentAttribute = .forceRightToLeft
//            }
//            else
//            {
//                cell.collectionProducts.semanticContentAttribute = .forceLeftToRight
//            }
//            ///
            
            cell.collectionProducts.delegate = self
            cell.collectionProducts.dataSource = self
            
            cell.collectionProducts.tag = Int(indexPath.row / 2)
            cell.collectionProducts.reloadData()
            
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.semanticContentAttribute = .forceLeftToRight
        if indexPath.row % 2 != 0 {
            DispatchQueue.main.async {
                let cell1 = cell as! ProductNcategories
                
//                cell1.setupLayout(totalHeight: Int(self.viewSize.frame.size.height))
//                if languageHelper.isArabic()
//                {
                cell1.collectionProducts.semanticContentAttribute = .forceLeftToRight
//                    cell1.collectionProducts.setContentOffset(CGPoint.zero, animated: false) //By Pawan
//                }
//                else
//                {
//                    cell1.collectionProducts.setContentOffset(CGPoint.zero, animated: false) //By Pawan
//                }
                // By pawan
//                DispatchQueue.main.async {
                    let indexP = IndexPath(item: 0, section: 0)
//
//                    if languageHelper.isArabic()
//                    {
//                        cell1.collectionProducts.semanticContentAttribute = .forceRightToLeft
//                        cell1.collectionProducts.scrollToItem(at: indexPath, at: .left, animated: false)
//
//                    }
//                    else
//                    {
//                        cell1.collectionProducts.semanticContentAttribute = .forceLeftToRight
                        cell1.collectionProducts.scrollToItem(at: indexP, at: .right, animated: false)
//                    }
//                }
                
            }
        }
        if indexPath.row == ((self.totalItems.Brands.count * 2) - 2) && self.pagingEnabled {
            DispatchQueue.main.async {
                self.getProductListNewAPI(withIndex: self.selectedSubCategoryIndex, subCategory: self.selectedSubCategory)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row % 2) == 0 {
            self.performSegue(withIdentifier: "segueProductList", sender: Int(indexPath.row / 2))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 45;
        }else {
            return ((self.viewSize.frame.size.height - 100) / 2) + 5
        }
    }
}

// MARK: -
// UICollectionView Delegate & Datasource
extension ProductsInCategoryVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionPager {
            return self.selectedCategory.subcategories.count
        }
        return self.totalItems.Brands[collectionView.tag].Products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.collectionPager { // Pager Collection View
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellPages", for: indexPath)
            (cell.contentView.viewWithTag(1) as! UILabel).text = self.selectedCategory.subcategories[indexPath.row].category_name
            if indexPath.row == self.selectedSubCategoryIndex {
                (cell.viewWithTag(2))?.backgroundColor = kThemeColor1
            }else {
                (cell.viewWithTag(2))?.backgroundColor = .white
            }
            return cell
        }else { // Product Collection View
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductsListCell
            
            let product = self.totalItems.Brands[collectionView.tag].Products[indexPath.row]
            cell.imgProduct.kf.setImage(with:
                URL.init(string: product.product_image)!,
                                placeholder: #imageLiteral(resourceName: "AppLogo.png"),
                                options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                progressBlock: nil,
                                completionHandler: nil)
            
            cell.lblProductWeight.text = product.weight.replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "\(product.weight_in)")
            cell.lblProductName.text = product.product_name
            cell.lblProductPrice.text = ((product.offer_price.isEmpty ? product.avg_price : product.offer_price) + " " + languageHelper.LocalString(key: "OMR")).replaceEnglishDigitsWithArabic
            
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
            
            cell.lblActualPrice.text = "\(round(((Double(product.avg_price) ?? 0.0) * 100))/100 )".replaceEnglishDigitsWithArabic + " " + languageHelper.LocalString(key: "OMR")
            cell.lblActualPrice.isHidden = product.offer_price.isEmpty
            cell.viewCross.isHidden = product.offer_price.isEmpty
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionPager {
            self.isFiltered = false
            self.filterData = FilterData()
            self.pageNumber = 1
            self.pagingEnabled = true
            self.isTabChanged = true
            self.getProductListNewAPI(withIndex: indexPath.row, subCategory: selectedCategory.subcategories[indexPath.row].id)
        }else {
            self.performSegue(withIdentifier: "segueProductDetails", sender: [collectionView.tag, indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView != self.collectionPager {
            let cellWidth = (self.view.frame.size.width - 45) / 2;
            var cellheight : CGFloat = (CGFloat((self.viewSize.frame.size.height - 100) / 2))
            
            cellheight = cellheight - 5
            
            return CGSize(width: cellWidth , height:cellheight)
        }
        let str = self.selectedCategory.subcategories[indexPath.row].category_name
        
        let lbl = UILabel.init(frame: CGRect.zero)
        lbl.text = str
        lbl.sizeToFit()
        
        return CGSize(width: (lbl.frame.size.width + 15), height: 40)
    }
}

// MARK: -

class ProductsListCell : UICollectionViewCell {
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductWeight: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblOutOfStock: UILabel!
    @IBOutlet weak var lblActualPrice: UILabel!
    
    @IBOutlet weak var viewCross: UIView!
    
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnAddToWishList: UIButton!
    @IBOutlet weak var btnNotifyMe: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
}

class ProductNcategories: UITableViewCell {
    @IBOutlet weak var collectionProducts: UICollectionView!
    
    @IBOutlet weak var lblBrandName: UILabel!
    @IBOutlet weak var lblTotalProducts: UILabel!
    @IBOutlet weak var collection_height: NSLayoutConstraint!
    
    fileprivate func setupLayout() {
        //setup collection view layout
        
        DispatchQueue.main.async {
            let cellWidth = (viewHeight.size.width - 45) / 2;
            var cellheight : CGFloat = (CGFloat((viewHeight.size.height - 90) / 2))
            self.collection_height.constant = cellheight;
            cellheight = cellheight - 5
            
            let cellSize = CGSize(width: cellWidth , height:cellheight)
            
            let layout = self.collectionProducts.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = .horizontal
            layout.itemSize = cellSize
            self.collectionProducts.reloadData()
            
            }
        }
        
        
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        scrollToBeginning()
//    }
//
    override func prepareForReuse() {
        //scrollToBeginning()
    }
//
    func scrollToBeginning() {
        guard collectionProducts.numberOfItems(inSection: 0) > 0 else { return }
        let indexPath = IndexPath(item: 0, section: 0)
        if languageHelper.isArabic()
        {
            collectionProducts.scrollToItem(at: indexPath, at: .left, animated: false)

        }
        else
        {
            collectionProducts.scrollToItem(at: indexPath, at: .right, animated: false)
        }
    }
    
    }

// By Pawan
extension UICollectionViewFlowLayout {
    
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        
        if languageHelper.isArabic()
        {
            return true
        }
        else
        {
           return false
        }
        
    }
}
    


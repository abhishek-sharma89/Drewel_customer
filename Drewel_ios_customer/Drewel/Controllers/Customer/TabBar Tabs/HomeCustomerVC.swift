//
//  HomeCustomerVC.swift
//  Drewel
//
//  Created by Octal on 04/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher
import CoreLocation
import FBSDKCoreKit
import Firebase

class HomeCustomerVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, SetDefaultAddressDelegate {
    
    @IBOutlet weak var collectionBanner: UICollectionView!
    @IBOutlet weak var tblProductCategory: UITableView!
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var pageControllBanner: UIPageControl!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewSearchProduct: UIView!
    
    var arrCategories = Array<ProductCategory>()
    var arrAnimCount = Array<Int>()
    var arrBanner = Array<NSDictionary>()
    var allProductImg = ""
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkForDeliveryAddress()
        self.setInitialValues()
        self.tblProductCategory.isHidden = true
        
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request?.start(completionHandler: { (connection, result, error) in
            guard let userInfo = result as? [String: Any] else { return } //handle the error
            
            //The url is nested 3 layers deep into the result so it's pretty messy
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                //Download image from imageURL
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setAddressText(dict: UserDefaults.standard.object(forKey: kDefaultAddress) as? NSDictionary ?? NSDictionary())
        self.getCategoryListAPI()
    }
    
    func setInitialValues() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Roboto", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        self.getUnreadNotificationsAPI()
//        let addrs = UserDefaults.standard.value(forKey: kDefaultAddress) as? String ?? languageHelper.LocalString(key: "selectAddress")
//        self.btnAddress.setTitle(addrs, for: .normal)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        DispatchQueue.main.async {
            self.setupLayout()
        }
    }
    
    func checkForDeliveryAddress() {
        let address = UserDefaults.standard.object(forKey: kDefaultAddress)
        
        if address == nil {
            if self.userData.address_name != "" {
                let dict = NSMutableDictionary()
                dict.setValue(self.userData.address, forKey: "address")
                dict.setValue(self.userData.address_latitude, forKey: "latitude")
                dict.setValue(self.userData.address_longitude, forKey: "longitude")
                dict.setValue(self.userData.address_id, forKey: "id")
                dict.setValue(self.userData.zip_code, forKey: "zip_code")
                dict.setValue(self.userData.user_name, forKey: "user_name")
                dict.setValue(self.userData.user_mobile, forKey: "mobile_number")
                dict.setValue(self.userData.full_address, forKey: "full_address")
                dict.setValue(self.userData.landmark, forKey: "landmark")
                dict.setValue(self.userData.address_name, forKey: "name")
                dict.setValue(self.userData.delivery_address_type, forKey: "delivery_address_type")
                
                UserDefaults.standard.set(dict, forKey: kDefaultAddress)
                UserDefaults.standard.synchronize()
                
                self.setAddressText(dict: dict)
            }else {
//                self.performSegue(withIdentifier: "segueSelectAddress", sender: self)
                
//                let vc1 = kStoryboard_Customer.instantiateViewController(withIdentifier: "SearchAddressVC") as! SearchAddressVC
//                vc1.delegate = self
//                let vc2 = kStoryboard_Customer.instantiateViewController(withIdentifier: "SetLocationVC") as! SetLocationVC
//                vc2.delegate = vc1
//                var vcs : [UIViewController] = (self.navigationController?.viewControllers)!
//                vcs.append(contentsOf: [vc1, vc2])
//                self.navigationController?.setViewControllers(vcs, animated: true)
            }
        }
    }
    
    // MARK: - UIButton Actions
    @IBAction func btnMenuAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueSearch", sender: nil)
    }
    
    //MARK: - SetDefaultAddress Delegate
    
    func seDefaultAddress(dict: NSDictionary) {
        UserDefaults.standard.set(dict, forKey: kDefaultAddress)
        UserDefaults.standard.synchronize()
        self.setAddressText(dict: dict)
    }
    
    func setAddressText(dict : NSDictionary) {
        self.btnAddress.setTitle(dict.value(forKey: "name") as? String ?? languageHelper.LocalString(key: "selectAddress"), for: .normal)
        let frame = self.btnAddress.frame
        self.btnAddress.sizeToFit()
        if self.btnAddress.frame.size.width > frame.size.width {
            self.btnAddress.frame = frame
        }
    }
    
    // MARK: - WebService Method
    func getUnreadNotificationsAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Unread_Notifications, showAlert: false, showHud: false, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                UIApplication.shared.applicationIconBadgeNumber = Int("\(result.removeNullValueFromDict().value(forKey: "unread") ?? "0")") ?? 0
                
                self.observeChatUnreadCount(admin_id: "\(result.removeNullValueFromDict().value(forKey: "admin_id") ?? "1")")
                self.observeAdminUnreadCount(admin_id: "\(result.removeNullValueFromDict().value(forKey: "admin_id") ?? "1")")
            }
        }
    }
    
    func getCategoryListAPI() {
        let param : NSDictionary = ["user_id"     : self.userData.user_id,
                                    "language"    : languageHelper.language ]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Category_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let arrCategory = result.object(forKey: "category") as? NSArray ?? NSArray()
                self.arrCategories.removeAll()
                
                var allCategory = ProductCategory()
                allCategory.id = ""
                allCategory.img = ""
                allCategory.category_name = languageHelper.LocalString(key: "allProduct")
                allCategory.strSubCategories = languageHelper.LocalString(key: "allProductFromStore")
                self.arrCategories.append(allCategory)
                
                for i in 0..<arrCategory.count {
                    let dict = arrCategory[i] as! NSDictionary
                    var category = ProductCategory()
                    category.id = dict.value(forKey: "id") as! String
                    category.img = dict.value(forKey: "img") as! String
                    category.category_name = dict.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) as! String
                    if (dict.object(forKey: "subcategories") != nil) {
                        if (dict.object(forKey: "subcategories") as? NSArray ?? NSArray()).count > 0 {
                            let arrSubCat = dict.object(forKey: "subcategories") as! NSArray
                            for j in 0..<arrSubCat.count {
                                let dictSubCategory = arrSubCat[j] as! NSDictionary
                                var subCategory = ProductCategory()
                                subCategory.id = dictSubCategory.value(forKey: "id") as! String;
                                subCategory.img = dictSubCategory.value(forKey: "img") as! String
                                subCategory.category_name = dictSubCategory.value(forKey: (languageHelper.isArabic() ? "ar_category_name" : "category_name")) as! String
                                
                                if j <= 1 {
                                    category.strSubCategories = category.strSubCategories + (!category.strSubCategories.isEmpty ? ", " : "") + subCategory.category_name
                                }else if j == 2{
                                    category.strSubCategories = category.strSubCategories + " etc."
                                }
                                
                                category.subcategories.append(subCategory);
                            }
                        }
                    }
                    self.arrCategories.append(category)
                }
                
                self.arrBanner.removeAll()
                self.arrBanner = result.object(forKey: "home") as? [NSDictionary] ?? [NSDictionary]()
                self.allProductImg = "\(result.object(forKey: "all_category_img") ?? "")"
                if self.arrBanner.count > 0 {
                    self.tblProductCategory.tableHeaderView?.frame = self.viewHeader.bounds
                }else {
                    self.tblProductCategory.tableHeaderView?.frame = CGRect.zero
                }
                self.tblProductCategory.isHidden = false
                self.tblProductCategory.reloadData()
                self.collectionBanner.reloadData()
                self.pageControllBanner.numberOfPages = self.arrBanner.count
                self.pageControllBanner.currentPage = 0
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productsInCategories" {
            let vc = segue.destination as! ProductsInCategoryVC
            vc.selectedCategory = sender as! ProductCategory
        }else if segue.identifier == "segueSelectAddress" {
            let vc = segue.destination as! SearchAddressVC
            vc.delegate = self
        }
    }
    
    func getChannelName(admin_id : String) -> String {
        let channel = "\(admin_id)\(self.userData.user_id)"
        return channel
    }
    
    func observeChatUnreadCount(admin_id : String) {
        let messageQuery = Database.database().reference().child("chatmodel").child(self.getChannelName(admin_id: admin_id)).child("channel_info").child("user_count")
        _ = messageQuery.observe(.value, with: { (snapshot) -> Void in
            if snapshot.exists() {
              /*  if*/ let messageData = "\(snapshot.value ?? "0")" //{
                    print("user_unread : \(messageData)")
                    user_unread = Int("\(messageData)") ?? 0
                    self.tabBarController?.tabBar.items![4].badgeValue = user_unread == 0 ? nil : "\(user_unread)"
                    self.tabBarController?.tabBar.items![4].badgeColor = kThemeColor1
                    NotificationCenter.default.post(name: Notification.Name(kNOTIFICATION_NEW_CHAT_MSG), object: nil)
               // }
            }
        })
    }
    
    func observeAdminUnreadCount(admin_id : String) {
        let messageQuery = Database.database().reference().child("chatmodel").child(self.getChannelName(admin_id: admin_id)).child("channel_info").child("admin_count")
        _ = messageQuery.observe(.value, with: { (snapshot) -> Void in
            if snapshot.exists() {
               /* if*/ let messageData = "\(snapshot.value ?? "0")"// {
                    admin_unread = Int("\(messageData)") ?? 0
               // }
            }
        })
    }
}

// MARK: -
// UITableView Delegate & Datasource
extension HomeCustomerVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductsListingCell
        cell.lblTitle.text = arrCategories[indexPath.row].category_name
        cell.lblSubTitle.text = arrCategories[indexPath.row].strSubCategories
        if !arrCategories[indexPath.row].img.isEmpty {
            cell.imgProduct.kf.setImage(with: URL.init(string: arrCategories[indexPath.row].img), placeholder: #imageLiteral(resourceName: "cart_big_theme"), options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage), progressBlock: nil, completionHandler: nil)
        }else {
            if let url = URL.init(string: self.allProductImg) {
                cell.imgProduct.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "cart_big_theme"), options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage), progressBlock: nil, completionHandler: nil)
            }else {
                cell.imgProduct.image = #imageLiteral(resourceName: "cart_big_theme")
            }
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "productsInCategories", sender: self.arrCategories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width <= 320 ? 84 : 96
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = Bundle.main.loadNibNamed("SearchHeaderView", owner: self, options: nil)![0] as! SearchHeaderView
        hView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 57)
        return hView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 57
    }
}

extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}

// MARK: -
// UICollectionView Delegate & Datasource
extension HomeCustomerVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrBanner.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let dict = self.arrBanner[indexPath.row].removeNullValueFromDict()
        let strURL =  "\(dict.value(forKey: "img") ?? "")"
        if !strURL.isEmpty {
            (cell.viewWithTag(11) as! UIImageView).kf.setImage(with: URL.init(string: strURL)!,
                                                               placeholder: #imageLiteral(resourceName: "appicon.png"),
                                                               options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                                               progressBlock: nil,
                                                               completionHandler: nil)
        }
        let strBanner = "\(dict.value(forKey: "offer_text") ?? "")"
        (cell.viewWithTag(2) as! UILabel).text = strBanner
//        (cell.viewWithTag(2) as! UILabel).superview?.isHidden = strBanner.isEmpty
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControllBanner.currentPage = indexPath.row
    }
    
    fileprivate func setupLayout() {
        //setup collection view layout
        self.viewHeader.layoutIfNeeded()
//        self.tblProductCategory.tableHeaderView?.frame = CGRect.zero
        let cellWidth = (self.collectionBanner.frame.size.width)
        let cellheight : CGFloat = (self.collectionBanner.frame.size.height)
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = self.collectionBanner.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        self.collectionBanner.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionBanner {
            self.pageControllBanner.currentPage = self.collectionBanner.indexPathsForVisibleItems[0].row
        }
    }
}

// MARK: -
class ProductsListingCell: UITableViewCell {
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
}


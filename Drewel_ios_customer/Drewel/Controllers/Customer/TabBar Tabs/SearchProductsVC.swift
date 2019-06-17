//
//  SearchProductsVC.swift
//  Drewel
//
//  Created by Octal on 13/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol SelectCouponCodeDelegate
{
    func setCouponCode(code : String)
}

class SearchProductsVC: BaseViewController {
    
    @IBOutlet weak var btnAppLogo: UIBarButtonItem!
    @IBOutlet weak var tblOffers: UITableView!
    
    var delegate: SelectCouponCodeDelegate? = nil
    var arrCoupons = Array<CouponData>()
    var isApply : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        if isApply {
            self.navigationItem.leftBarButtonItems = nil
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCouponListAPI()
    }
    
    func setInitialValues() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Roboto", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        self.title = languageHelper.LocalString(key: "offers")
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnApplyCouponCodeAction(_ sender: UIButton) {
        self.delegate?.setCouponCode(code: self.arrCoupons[sender.tag].coupon_code)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - WebService Method
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
    
    /*
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension SearchProductsVC : UITableViewDelegate, UITableViewDataSource {
    
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
        cell.btnApplyCoupon.addTarget(self, action: #selector(btnApplyCouponCodeAction(_:)), for: .touchUpInside)
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

class OffersTableViewCell : UITableViewCell {
    
    @IBOutlet weak var imgCoupon: UIImageView!
    @IBOutlet weak var lblExpiry: UILabel!
    @IBOutlet weak var lblCouponCode: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblRedeemed: UILabel!
    @IBOutlet weak var btnApplyCoupon: UIButton!
    @IBOutlet weak var lblCategory: UILabel!
    
}


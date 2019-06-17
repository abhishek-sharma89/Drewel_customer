//
//  LoyaltyPointsListVC.swift
//  Drewel
//
//  Created by Octal on 15/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class LoyaltyPointsListVC: BaseViewController {
    
    @IBOutlet weak var lblAvailablePoints: UILabel!
    @IBOutlet weak var tblLoyaltyPoints: UITableView!
    
    @IBOutlet weak var btnTransferLoyaltyPoints: UIButton!
    
    
    var arrLoyaltyPoints = [LoyaltyPointsData]()
    
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
        self.loyaltyPointsListAPI()
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "loyaltyPoints")
        self.btnTransferLoyaltyPoints.isHidden = true
    }
    
    // MARK: - WebService Method
    func loyaltyPointsListAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Loyalty_Points_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let arrPoints = result.object(forKey: "LoyaltyPoints") as? NSArray ?? NSArray()
                self.arrLoyaltyPoints.removeAll()
                for i in 0..<arrPoints.count {
                    let dict = (arrPoints[i] as! NSDictionary).removeNullValueFromDict()
                    var points = LoyaltyPointsData()
                    points.order_id = dict.value(forKey: "order_id") as? String ?? ""
                    points.img = dict.value(forKey: "img") as? String ?? ""
                    points.created_at = dict.value(forKey: "created_at") as? String ?? ""
                    points.loyalty_points = dict.value(forKey: "loyalty_points") as? String ?? ""
                    points.type = dict.value(forKey: "type") as? String ?? ""
                    points.user_id = dict.value(forKey: "user_id") as? String ?? ""
                    points.user_name = dict.value(forKey: "user_name") as? String ?? ""
                    points.id = dict.value(forKey: "id") as? String ?? ""
                    
                    self.arrLoyaltyPoints.append(points)
                }
                
                let points = result.value(forKey: "current_loyalty_points") as? String ?? "0"
//                self.lblAvailablePoints.text = "\(Int(points) ?? 0)"
                
                self.lblAvailablePoints.text = (String.init(format: "%.3f ", arguments: [Double(points) ?? 0.00]).replaceEnglishDigitsWithArabic + languageHelper.LocalString(key: "points")) //languageHelper.LocalString(key: "OMR"))
                
                
                self.tblLoyaltyPoints.reloadData()
                self.btnTransferLoyaltyPoints.isHidden = false
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func deleteListAPI(index : Int, id : String) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "notification_id" : id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Loyalty, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrLoyaltyPoints.remove(at: index)
                self.tblLoyaltyPoints.reloadData()
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

// MARK: -
//UITableView Delegate & Datasource
extension LoyaltyPointsListVC : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.arrLoyaltyPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LoyaltyPointsTableCell
        
        let points = arrLoyaltyPoints[indexPath.row]
        
        let type = (points.type == "Credit" ? "earned" : (points.user_name.isEmpty ? "redeemed" : "Transfered"))
        cell.lblTransactionType.text = languageHelper.LocalString(key: type) //languageHelper.LocalString(key: "loyaltyPoints") + " " + languageHelper.LocalString(key: type)
//        if points.type == "earned"{
//            cell.lblTransactionType.text = ""
//        }
        cell.lblFromOrder.text = languageHelper.LocalString(key: (points.type == "Credit" ? "fromOrder" : "paidForOrder")) + (points.user_name.isEmpty ? (points.order_id) : points.user_name)
        
        cell.lblDate.text = helper.convertDateFromUTCToCurrent(strDate:  points.created_at, inFormat: "yyyy-MM-dd HH:mm:ss", outFormat:   "dd MMM, yyyy, hh:mm aa")
        if !points.img.isEmpty {
            cell.imgUser.kf.setImage(with:
                URL.init(string: points.img)!,
                                     placeholder: #imageLiteral(resourceName: "appicon.png"),
                                     options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                     progressBlock: nil,
                                     completionHandler: nil)
        }else {
            cell.imgUser.image = #imageLiteral(resourceName: "appicon.png")
        }
        
        cell.lblPointsCount.text = (String.init(format: "%.3f ", arguments: [Double(points.loyalty_points) ?? 0.00]).replaceEnglishDigitsWithArabic )//+ languageHelper.LocalString(key: "OMR"))
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell1 = cell as! LoyaltyPointsTableCell
        DispatchQueue.main.async {
            cell1.imgUser.layer.cornerRadius = cell1.imgUser.frame.size.height/2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Loyalty_DELETE_MSG"), preferredStyle: .alert)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
                self.deleteListAPI(index: indexPath.row, id: self.arrLoyaltyPoints[indexPath.row].id)
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

class LoyaltyPointsTableCell: UITableViewCell {
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblTransactionType: UILabel!
    @IBOutlet weak var lblFromOrder: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPointsCount: UILabel!
}

extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}

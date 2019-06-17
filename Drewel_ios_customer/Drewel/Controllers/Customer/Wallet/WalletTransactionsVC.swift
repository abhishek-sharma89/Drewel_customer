//
//  WalletTransactionsVC.swift
//  Drewel
//
//  Created by Octal on 25/06/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class WalletTransactionsVC: BaseViewController {
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var tblTransactions: UITableView!
    
    var arrWalletTransactions = [LoyaltyPointsData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = languageHelper.LocalString(key: "transactions")
        self.loyaltyPointsListAPI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - WebService Method
    func loyaltyPointsListAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: "wallet_list", showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let arrPoints = result.object(forKey: "Transactions") as? NSArray ?? NSArray()
                self.arrWalletTransactions.removeAll()
                for i in 0..<arrPoints.count {
                    let dict = (arrPoints[i] as! NSDictionary).removeNullValueFromDict()
                    var points = LoyaltyPointsData()
                    
                    points.user_id = dict.value(forKey: "id") as? String ?? ""
                    points.created_at = dict.value(forKey: "date") as? String ?? ""
                    points.loyalty_points = dict.value(forKey: "amount") as? String ?? ""
                    points.type = dict.value(forKey: "type") as? String ?? ""
                    points.order_id = dict.value(forKey: "order_id") as? String ?? ""
                    
                    self.arrWalletTransactions.append(points)
                }
                
                let points = result.value(forKey: "wallet_balance") as? String ?? "0"
                //                self.lblAvailablePoints.text = "\(Int(points) ?? 0)"
                
                self.lblBalance.text = String.init(format: "%.3f", arguments: [Double(points) ?? 0.00]).replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
                
                
                self.tblTransactions.reloadData()
//                self.btnTransferLoyaltyPoints.isHidden = false
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func deleteListAPI(index : Int, id : String) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "notification_id" : id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Wallet, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrWalletTransactions.remove(at: index)
                self.tblTransactions.reloadData()
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
extension WalletTransactionsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrWalletTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LoyaltyPointsTableCell
        
        let transaction = self.arrWalletTransactions[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tDate = formatter.date(from: transaction.created_at) ?? Date()
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.locale = languageHelper.getLocale()
        cell.lblDate.text = formatter.string(from: tDate)
        
        let toFrom = transaction.type == "Cr" ? "\(languageHelper.LocalString(key: "from"))" : "\(languageHelper.LocalString(key: "to"))"
        cell.lblFromOrder.text = "\(toFrom) \(languageHelper.LocalString(key: "order")) : #\(transaction.order_id)".replaceEnglishDigitsWithArabic
        
        let amount = transaction.loyalty_points
        let strAmount = (transaction.type == "Cr" ? "+ " : "- ") + "\(String.init(format: "%.3f", arguments: [Double(amount) ?? 0.000]))"
        cell.lblPointsCount.text = "\(strAmount) \(languageHelper.LocalString(key: "OMR"))"
        cell.lblTransactionType.text = "#\(transaction.user_id)".replaceEnglishDigitsWithArabic
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Wallet_DELETE_MSG"), preferredStyle: .alert)
            alert.view.tintColor = kThemeColor1;
            // relate actions to controllers
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
                self.deleteListAPI(index: indexPath.row, id: self.arrWalletTransactions[indexPath.row].order_id)
            })
            
            alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

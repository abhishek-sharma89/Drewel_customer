//
//  RequestListVC.swift
//  Drewel
//
//  Created by Octal on 13/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class RequestListVC: UIViewController {
    @IBOutlet weak var tblProductRequest: UITableView!
    
    var arrTitle = Array<NSDictionary>()
    
    var timer : Timer?
    var arrIsEdit = Array<String>()
    var arrReqTime = Array<NSMutableDictionary>()
    
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
        self.requestProductListAPI()
    }
    
    //product_request_list
    func setInitialValues() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Roboto", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        self.title = languageHelper.LocalString(key: "addRequest")
    }
    
    // MARK: - UIButton Action
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: languageHelper.LocalString(key: "Delete_Product_Request_MSG"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
            self.deleteRequestAPI(reqId: "\(self.arrTitle[sender.tag].value(forKey: "request_id") ?? "")")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "AddRequestVC") as! AddRequestVC
        vc.requestText = "\(arrTitle[sender.tag].value(forKey: "product_name") ?? "")"
        vc.requestId = "\(arrTitle[sender.tag].value(forKey: "request_id") ?? "")"
        self.navigationController?.show(vc, sender: nil)
    }
    
    // MARK: - WebService Method
    func requestProductListAPI() {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_Request_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrTitle.removeAll()
                self.arrIsEdit.removeAll()
                self.arrReqTime.removeAll()
                
                self.arrTitle = result.value(forKey: "requests") as! [NSDictionary]
                
                for i in 0..<self.arrTitle.count {
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone.init(abbreviation: "UTC")
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let currentTime = formatter.date(from: "\(self.arrTitle[i].value(forKey: "server_time") ?? "")") ?? Date()
                    let orderTime = formatter.date(from: "\(self.arrTitle[i].value(forKey: "requested_on") ?? "")") ?? Date()
                    let totalRemain = 750 - Double.init(currentTime.timeIntervalSince(orderTime))
                    
                    let reply = self.arrTitle[i].value(forKey: "reply") as? String ?? ""
                    
                    if totalRemain > 0 && reply.count == 0 {
                        let timeDict = ["time_remain"   : totalRemain,
                                        "index"         : i] as NSMutableDictionary
                        self.arrReqTime.append(timeDict)
                        self.arrIsEdit.append("1")
                    }else {
                        self.arrIsEdit.append("0")
                    }
                }
                
                self.tblProductRequest.reloadData()
            }else {
                let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "AddRequestVC")
                vc.hidesBottomBarWhenPushed = false
                self.navigationController?.setViewControllers([vc], animated: false)
//                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func deleteRequestAPI(reqId : String) {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "request_id": reqId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Product_Request, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.requestProductListAPI()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    @objc func setTimerData() {
        var arrRemove = Array<Int>()
        for i in 0..<self.arrReqTime.count {
            let dict = self.arrReqTime[i]
            (self.arrReqTime[i])["time_remain"] = (dict["time_remain"] as! Double) - 1.00
            
            if (dict["time_remain"] as! Double) <= 0 {
                self.arrIsEdit[(dict["index"] as! Int)] = "0"
                self.tblProductRequest.reloadRows(at: [IndexPath.init(row: (dict["index"] as! Int), section: 0)], with: .automatic)
                arrRemove.append(i)
            }
        }
        
        for i in arrRemove {
            self.arrReqTime.remove(at: arrRemove[i])
        }
        
        if self.arrReqTime.count == 0 {
            self.timer?.invalidate()
            self.timer = nil
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
extension RequestListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationListCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(abbreviation: "UTC")
        let date = formatter.date(from: arrTitle[indexPath.row].value(forKey: "requested_on") as! String) ?? Date()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd MMM, yy"
        formatter.locale = languageHelper.getLocale()
        
        let strReply = arrTitle[indexPath.row].value(forKey: "reply") as! String;
        cell.lblMessage.text = arrTitle[indexPath.row].value(forKey: "product_name") as? String;
        cell.lblReply.text = strReply.isEmpty ? "" : "\(languageHelper.LocalString(key: "reply")) : \(strReply)"
        cell.lblDate.text = formatter.string(from: date)
        
        formatter.dateFormat = "hh:mm aa"
        cell.lblTime.text = formatter.string(from: date)
        
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: #selector(btnEditAction(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteAction(_:)), for: .touchUpInside)
        
        cell.btnEdit.isHidden = self.arrIsEdit[indexPath.row] == "0"
        cell.btnDelete.isHidden = self.arrIsEdit[indexPath.row] == "0"
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

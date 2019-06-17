//
//  OrderListTableVC.swift
//  Drewel
//
//  Created by Octal on 04/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class OrderListTableVC: UITableViewController {

    @IBOutlet weak var lblNoOrder: UILabel!
    
    var listType = Int()
    var arrOrders = Array<OrderListData>()
    var userData = UserData.sharedInstance;
    
    var timer : Timer?
    
    var arrOrderTime = Array<NSMutableDictionary>()
    
//    var refreshControl = UIRefreshControl()
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        tableView.tableHeaderView?.frame.size.height = self.listType == 0 ? 8 : 50
        self.tableView.isHidden = true
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: languageHelper.LocalString(key: "pullToRefresh"))
        refreshControl?.addTarget(self, action: #selector(self.getOrderListAPI), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func setInitialValues() {
        self.getOrderListAPI()
        self.view.tag = self.listType
        
        NotificationCenter.default.addObserver(self, selector: #selector(getOrderListAPI), name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    @IBAction func btnReorderAction(_ sender: UIButton) {
        
        let msg = self.listType == 0 ? languageHelper.LocalString(key: "Order_Edit_MSG") : languageHelper.LocalString(key: "Order_Reorder_MSG")
        
        let alert = UIAlertController(title: kAPPName, message: msg, preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
            if self.listType == 0 {
                self.replaceOrderAPI(orderId: self.arrOrders[sender.tag].order_id, apiUrl: kURL_Order_Edit)
            }else {
                self.replaceOrderAPI(orderId: self.arrOrders[sender.tag].order_id, apiUrl: kURL_Order_Replace)
            }
            
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: (sender.tag == -100 ? "ALL_ORDER_DELETE_MSG" : (self.listType == 1 ? "Previous_ORDER_DELETE_MSG" : "Order_Cancel_MSG"))), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
            if self.listType == 1 {
                self.deleteOrderAPI(orderId: (sender.tag == -100 ? "" : self.arrOrders[sender.tag].order_id), apiUrl: kURL_Clear_Order)
            }else {
                self.deleteOrderAPI(orderId: self.arrOrders[sender.tag].order_id, apiUrl: kURL_Order_Cancel)
            }
        })

        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.arrOrders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OrderListTableViewCell
        let order = self.arrOrders[indexPath.row]
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        let oDate = formatter.date(from: order.delivery_date)
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.locale = languageHelper.getLocale()
        cell.lblDeliveryDate.text = formatter.string(from: oDate ?? Date())
        formatter.locale = Locale.current
        formatter.dateFormat = "HH:mm:ss"
        let sDate = formatter.date(from: order.delivery_start_time)
        let eDate = formatter.date(from: order.delivery_end_time)
        formatter.locale = languageHelper.getLocale()
        formatter.dateFormat = "hh:mm aa"
        
        cell.lblOrderId.text = languageHelper.LocalString(key: "orderId") + " #" + order.order_id
        
        cell.lblDeliveryTime.text = formatter.string(from: sDate ?? Date()) + " " + languageHelper.LocalString(key: "to")  + " " + formatter.string(from: eDate ?? Date())
        cell.lblQuantity.text = order.total_quantity.replaceEnglishDigitsWithArabic
        cell.lblAmount.text = order.total_amount.replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        cell.lblPaymentStatus.text = languageHelper.LocalString(key: "\(order.payment_mode)")
        cell.lblOrderStatus.text = languageHelper.LocalString(key: "\(order.order_delivery_status)")
        cell.lblTransactionId.text = order.transaction_id.count > 0 ? order.transaction_id : languageHelper.LocalString(key: "Na")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 248.00
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueOrderDetails", sender: indexPath.row)
    }
    
    // MARK: - WebService Method
    
    @objc func getOrderListAPI() {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "flag"      : self.listType == 0 ? "1" : "2"]
//        flag : 1= pending orders, 2= delivered/cancelled orders
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Order_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.timer?.invalidate()
                self.timer = nil
                
                let arrData = result.value(forKey: "Order") as? NSArray ?? NSArray()
                self.arrOrderTime.removeAll()
                self.arrOrders.removeAll()
                
                for i in 0..<arrData.count {
                    let dict = ((arrData.object(at: i) as? NSDictionary) ?? NSDictionary()).removeNullValueFromDict()
                    var orderData = OrderListData()
                    orderData.delivery_date = dict.value(forKey: "delivery_date") as? String ?? ""
                    orderData.order_id = dict.value(forKey: "order_id") as? String ?? ""
                    orderData.order_delivery_status = dict.value(forKey: "order_delivery_status") as? String ?? ""
                    orderData.order_status = dict.value(forKey: "order_status") as? String ?? ""
                    orderData.delivery_start_time = dict.value(forKey: "delivery_start_time") as? String ?? ""
                    orderData.total_amount = dict.value(forKey: "total_amount") as? String ?? ""
                    orderData.is_cancelled = dict.value(forKey: "is_cancelled") as? String ?? ""
                    orderData.total_quantity = dict.value(forKey: "total_quantity") as? String ?? ""
                    orderData.delivery_end_time = dict.value(forKey: "delivery_end_time") as? String ?? ""
                    orderData.payment_mode = dict.value(forKey: "payment_mode") as? String ?? ""
                    orderData.transaction_id = dict.value(forKey: "transaction_id") as? String ?? ""
                    
                    orderData.is_delivery_boy = "\(dict.value(forKey: "is_delivery_boy") ?? "0")"
                    
                    orderData.order_date = dict.value(forKey: "order_date") as? String ?? ""
                    orderData.is_edited = dict.value(forKey: "is_edited") as? String ?? "0"
                    orderData.server_time = dict.value(forKey: "server_time") as? String ?? ""
                    orderData.isEdit = "0"
                    orderData.cancelled_before = dict.value(forKey: "cancelled_before") as? String ?? ""
                    if self.listType == 0 && orderData.order_date != "" && orderData.order_delivery_status == "Pending"  {
                        let formatter = DateFormatter()
                        formatter.timeZone = TimeZone.init(abbreviation: "UTC")
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let currentTime = formatter.date(from: orderData.server_time) ?? Date()
                        let orderTime = formatter.date(from: orderData.order_date) ?? Date()
                        let totalRemain = 600 - Double.init(currentTime.timeIntervalSince(orderTime))
                        if totalRemain > 0 && !(orderData.payment_mode == "Online" || orderData.payment_mode == "Wallet") {
                            let timeDict = ["time_remain"   : totalRemain,
                                            "index"         : self.arrOrders.count] as NSMutableDictionary
                            self.arrOrderTime.append(timeDict)
                            orderData.isEdit = "1"
                        }
                    }
                    
                    self.arrOrders.append(orderData)
                }
                self.tableView.isHidden = self.arrOrders.count <= 0
                self.tableView.reloadData()
                if self.arrOrders.count <= 0 {
                    self.lblNoOrder.text = message
                    self.tableView.tableFooterView?.frame.size.height = self.view.bounds.size.height - 80
                }else {
                    if self.arrOrderTime.count > 0 {
                        let aSelector : Selector = #selector(self.setTimerData)
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: aSelector, userInfo: nil, repeats: true)
                        self.timer?.fire()
                    }
                    self.tableView.tableFooterView?.frame.size.height = 0
                }
                self.refreshControl?.endRefreshing()
            }else {
                if self.arrOrders.count <= 0 {
                    self.lblNoOrder.text = message
                    self.tableView.tableFooterView?.frame.size.height = self.view.bounds.size.height - 80
                }
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func setTimerData() {
        var arrRemove = Array<Int>()
        for i in 0..<self.arrOrderTime.count {
            let dict = self.arrOrderTime[i]
            (self.arrOrderTime[i])["time_remain"] = (dict["time_remain"] as! Double) - 1.00
            
            if (dict["time_remain"] as? Double ?? 0.00) <= 0 {
                self.arrOrders[(dict["index"] as! Int)].isEdit = "0"
                self.tableView.reloadRows(at: [IndexPath.init(row: (dict["index"] as! Int), section: 0)], with: .automatic)
                arrRemove.append(i)
            }
        }
        
        for i in arrRemove {
            self.arrOrderTime.remove(at: i)
        }
        
        if self.arrOrderTime.count == 0 {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func replaceOrderAPI(orderId : String, apiUrl : String) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : orderId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: apiUrl, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.timer?.invalidate()
                self.timer = nil
                
                let dict = result.removeNullValueFromDict()
                let cart = dict.value(forKey: "Cart") as! NSDictionary
                self.userData.cart_quantity = "\(cart.value(forKey: "quantity") ?? "0")"
                self.userData.cart_id = "\(cart.value(forKey: "cart_id") ?? "")"
                
                let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
                userDict.setValue(self.userData.cart_id, forKey: "cart_id")
                userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
                helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
                
                let navVC = self.navigationController!
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC")
                self.navigationController?.popToRootViewController(animated: false)
                navVC.pushViewController(vc!, animated: false)
                
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func deleteOrderAPI(orderId : String, apiUrl : String) {
        
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "order_id"  : orderId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: apiUrl, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.getOrderListAPI()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.timer?.invalidate()
        self.timer = nil
        if segue.identifier == "segueOrderDetails" {
            let vc = segue.destination as! OrderDtailsVC
            vc.orderId = self.arrOrders[sender as! Int].order_id
        }
    }
 
}

class OrderListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblDeliveryDate: UILabel!
    @IBOutlet weak var lblDeliveryTime: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    @IBOutlet weak var lblTransactionId: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var btnReorder: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var const_btn_delete_height: NSLayoutConstraint!
    @IBOutlet weak var const_btn_edit_width: NSLayoutConstraint!
    @IBOutlet weak var const_btn_reorder_width: NSLayoutConstraint!
}

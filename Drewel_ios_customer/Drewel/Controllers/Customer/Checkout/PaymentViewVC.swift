//
//  PaymentViewVC.swift
//  Drewel
//
//  Created by Octal on 28/11/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit


class PaymentViewVC: UIViewController {
    
    @IBOutlet weak var paymentView: UIWebView!
    var strUrl = String()
    var userData = UserData.sharedInstance
    var message = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL.init(string: self.strUrl) {
            self.paymentView.loadRequest(URLRequest.init(url: url))
        }
        self.title = languageHelper.LocalString(key: "payment")
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.hidesBackButton = false
    }
    
}

extension PaymentViewVC : UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
//        print("\n\n\n\n\n\n\n\n\n\nWebView URL : \(webView.request?.url?.absoluteString ?? "")")
        helper.ShowHud()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        helper.HideHud()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print("\n\n\n\n\n\nWebView URL : \(request.url?.absoluteString ?? "")\n\n\n\n\n\n")
        if let status = request.url!["status"] {
            if status == "success" {
                print("Payment Success")
                self.showPaymentResponse(with: self.message, and: 2)
                return false
            }else if status == "failed" {
                print("Payment Failed")
                self.showPaymentResponse(with: languageHelper.LocalString(key: "Payment_Failed_MSG"), and: 0)
                return false
            }
        }
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Payment Failed")
        self.showPaymentResponse(with: error.localizedDescription, and: 0)
        helper.HideHud()
    }
    
    func showPaymentResponse(with msg : String, and redirectIndex : Int) {
        
        if redirectIndex == 0 {
            helper.HideHud()
            self.navigationController?.popViewController(animated: true)
            HelperClass.showPopupAlertController(sender: self, message: msg, title: kAPPName)
            return
        }
        helper.HideHud()
        self.userData.cart_quantity = "0"
        self.userData.cart_id = ""
        let userDict = (helper.fetchDataFromDefaults(with: kAPPUSERDATA)).mutableCopy() as! NSMutableDictionary
        userDict.setValue(self.userData.cart_quantity, forKey: "cart_quantity")
        userDict.setValue(self.userData.cart_id, forKey: "cart_id")
        helper.saveDataToDefaults(dataObject: userDict, key: kAPPUSERDATA)
        
        self.tabBarController?.selectedIndex = redirectIndex
        self.navigationController?.popToRootViewController(animated: false)
        HelperClass.showPopupAlertController(sender: self, message: msg, title: kAPPName)
    }
}


extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}

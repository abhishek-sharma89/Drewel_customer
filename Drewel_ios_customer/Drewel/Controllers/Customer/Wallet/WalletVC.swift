//
//  WalletVC.swift
//  Drewel
//
//  Created by Octal on 16/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class WalletVC: UIViewController {
    
    var arrTitle = [languageHelper.LocalString(key:"transactions"),
                    languageHelper.LocalString(key:"loyaltyPoints")]
    
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
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key:"transactions")
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
extension WalletVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        (cell.contentView.viewWithTag(2) as! UILabel).text = arrTitle[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(kStoryboard_Customer.instantiateViewController(withIdentifier: "WalletTransactionsVC"), animated: true)
        }else if indexPath.row == 1 {
            self.navigationController?.pushViewController(kStoryboard_Customer.instantiateViewController(withIdentifier: "LoyaltyPointsListVC"), animated: true)
        }
    }
}

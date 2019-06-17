//
//  AboutUsVC.swift
//  Drewel
//
//  Created by Octal on 26/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import SafariServices

class AboutUsVC: UIViewController {
    
    
    var arrTitle = [languageHelper.LocalString(key: "howItWork"),
                    languageHelper.LocalString(key: "termOfUse"),
                    languageHelper.LocalString(key: "privacyPolicy"),
                    languageHelper.LocalString(key: "faq"),
                    languageHelper.LocalString(key: "appVersion")];
    
    let arrPreFix = ["how-it-works",
                     "terms-of-use",
                     "privacy-policy",
                     "faq",
                     "about-us"];
    
    var version = ""
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        if let versin = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
             self.version = versin
        }
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
        self.title = languageHelper.LocalString(key:"aboutApp")
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
extension AboutUsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        (cell.contentView.viewWithTag(2) as! UILabel).text = arrTitle[indexPath.row]
        
        
        (cell.contentView.viewWithTag(1) as! UILabel).text = self.version
        (cell.contentView.viewWithTag(1) as! UILabel).isHidden = indexPath.row != 4 ? true : false
        (cell.contentView.viewWithTag(3))?.isHidden = indexPath.row == 4 ? true : false
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 4 {
            let svc = SFSafariViewController(url: URL.init(string: "http://drewel.om/\(arrPreFix[indexPath.row])")!)
            self.present(svc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//
//  MyTabVC.swift
//  Drewel
//
//  Created by Octal on 04/06/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class MyTabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.items![0].title = languageHelper.LocalString(key: "home")
        self.tabBar.items![1].title = languageHelper.LocalString(key: "discount")
        self.tabBar.items![2].title = languageHelper.LocalString(key: "myOrder")
        self.tabBar.items![3].title = languageHelper.LocalString(key: "addRequest")
        self.tabBar.items![4].title = languageHelper.LocalString(key: "more")        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

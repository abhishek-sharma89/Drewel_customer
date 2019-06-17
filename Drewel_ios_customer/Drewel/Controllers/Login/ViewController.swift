//
//  ViewController.swift
//  Drewel
//
//  Created by Octal on 27/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var lblTest: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        languageHelper.changeLanguageTo(lang: "ar")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnChangeLanguage(_ sender: Any) {
        languageHelper.changeLanguageTo(lang: languageHelper.isArabic() ? "en" : "ar")
        UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController");
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
}


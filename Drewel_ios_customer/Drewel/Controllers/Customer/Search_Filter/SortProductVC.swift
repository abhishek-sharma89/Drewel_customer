//
//  SortProductVC.swift
//  Drewel
//
//  Created by Octal on 06/09/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

protocol SortDelegate {
    func applySortWithData(index : Int)
}

class SortProductVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate : SortDelegate!
    
    var arrTitle = [languageHelper.LocalString(key:"priceLH"),
                    languageHelper.LocalString(key:"priceHL"),
                    languageHelper.LocalString(key:"newAdded"),
                    languageHelper.LocalString(key:"mostPopular"),
                    languageHelper.LocalString(key:"discounted")];
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = self.selectedIndex - 1
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIView.animate(withDuration: 0.5) {
//            self.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
//        }
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        (cell.contentView.viewWithTag(2) as! UILabel).text = self.arrTitle[indexPath.row]
        (cell.contentView.viewWithTag(1) as! UIImageView).image = (self.selectedIndex == indexPath.row) ? #imageLiteral(resourceName: "radio_selected") : #imageLiteral(resourceName: "radio_unselected")
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        tableView.reloadData()
        DispatchQueue.main.async {
            if (self.delegate != nil) {
                self.delegate.applySortWithData(index: (indexPath.row + 1))
            }
            self.dismiss(animated: true, completion: nil)
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

//
//  SearchHeaderView.swift
//  Drewel
//
//  Created by Octal on 14/06/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class SearchHeaderView: UIView {
    @IBOutlet weak var btnSearch: UIButton!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "SearchCategoryVC")
        self.parentContainerViewController()?.navigationController?.show(vc, sender: nil)
    }
}

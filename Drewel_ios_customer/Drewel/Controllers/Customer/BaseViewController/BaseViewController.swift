//
//  BaseViewController.swift
//  Drewel
//
//  Created by Octal on 09/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import DCAnimationKit

class BaseViewController: UIViewController {
    
    var userData = UserData.sharedInstance;
    var btnBarCart: UIBarButtonItem!
    var btnBarWishList: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.navigationItem.rightBarButtonItems != nil) {
            if ((self.navigationItem.rightBarButtonItems?.count)! > 0) {
                btnBarCart = self.navigationItem.rightBarButtonItems![0]
                let btn = (btnBarCart.customView as! UIButton)
                btn.addTarget(self, action: #selector(btnShowCartAction(_:)), for: .touchUpInside)
            }
            if ((self.navigationItem.rightBarButtonItems?.count)! > 1) {
                btnBarWishList = self.navigationItem.rightBarButtonItems![1]
                let btn = (btnBarWishList.customView as! UIButton)
                btn.addTarget(self, action: #selector(btnShowWishListAction(_:)), for: .touchUpInside)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showCartBadge()
    }
    
    func updateCartBadge() {
        self.animateCart()
        self.showCartBadge()
    }
    
    func animateCart() {
        if (self.btnBarCart != nil) {
            self.btnBarCart.customView?.shake(nil)
        }
    }
    
    func showCartBadge() {
        if btnBarCart != nil {
            btnBarCart.removeBadge()
            guard let cart_q = Int(self.userData.cart_quantity) else {
                return
            }
            if cart_q > 0 {
                self.btnBarCart.addBadge(number: cart_q, withOffset: CGPoint.init(x: -5, y: -2), andColor: UIColor.white, andFilled: true)
                
            }
        }
    }
    
    // MARK: - UIButton Actions
    @IBAction func btnShowCartAction(_ sender: UIButton) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func btnShowWishListAction(_ sender: UIButton) {
        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "WishListVC") as! WishListVC
        self.navigationController?.show(vc, sender: nil)
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

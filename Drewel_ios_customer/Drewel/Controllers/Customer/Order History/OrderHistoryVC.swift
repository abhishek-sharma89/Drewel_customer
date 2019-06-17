//
//  OrderHistoryVC.swift
//  Drewel
//
//  Created by Octal on 04/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class OrderHistoryVC: BaseViewController {
    
    @IBOutlet weak var viewPageC: UIView!
    @IBOutlet weak var viewIndicator: UIView!
    
    var pageViewController : UIPageViewController!
    var arrVCs = Array<UIViewController>()
    
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
        NotificationCenter.default.post(name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
    }
    
    func setInitialValues() {
        
        if userData.user_id == "1"
        {
            UserDefaults.standard.set(false, forKey: kAPP_SOCIAL_LOG)
            UserDefaults.standard.set(false, forKey: kAPP_IS_LOGEDIN)
            UserDefaults.standard.removeObject(forKey: kDefaultAddress)
            UserDefaults.standard.synchronize()
            let vc = kStoryboard_Main.instantiateViewController(withIdentifier: "ViewController")
            UIApplication.shared.keyWindow?.rootViewController = vc
            
            return
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Roboto", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        self.title = languageHelper.LocalString(key: "myOrder")
        DispatchQueue.main.async {
            self.setupPageController()
        }
    }
    
    private func setupPageController() {
        let vc1 = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        vc1.listType = 0
        let vc2 = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        vc2.listType = 1
        arrVCs = [vc1, vc2]
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        pageViewController.setViewControllers([arrVCs[0]], direction: languageHelper.isArabic() ? .reverse : .forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        self.pageViewController.view.frame = self.viewPageC.frame
        //  pageViewController.didMove(toParentViewController: self)
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        // Add the page view controller's gesture recognizers to the view controller's view so that the gestures are started more easily.
        view.gestureRecognizers = pageViewController.gestureRecognizers
    }
    
    @IBAction func btnSwipeOrderListAction(_ sender: UIButton) {
//        let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderListTableVC") as! OrderListTableVC
        if let vcs = self.pageViewController.viewControllers {
            if vcs.count > 0 {
                if sender.tag == 100 && vcs[0].view.tag == 1 {
//                    vc.listType = 0
                    
                    if languageHelper.isArabic() {
                        self.pageViewController.setViewControllers([arrVCs[0]], direction: .forward, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = self.viewPageC.frame.size.width/2;
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }else {
                        self.pageViewController.setViewControllers([arrVCs[0]], direction: .reverse, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = 0
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }
                }else if sender.tag == 101 && vcs[0].view.tag == 0 {
//                    vc.listType = 1
                    if languageHelper.isArabic() {
                        self.pageViewController.setViewControllers([arrVCs[1]], direction: .reverse, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = 0
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }else {
                        self.pageViewController.setViewControllers([arrVCs[1]], direction: .forward, animated: true, completion: nil)
                        var basketTopFrame = self.viewIndicator.frame;
                        basketTopFrame.origin.x = self.viewPageC.frame.size.width/2;
                        
                        UIView.animate(withDuration: 0.3) {
                            self.viewIndicator.frame = basketTopFrame
                        }
                    }
                    
                }
            }
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

extension OrderHistoryVC : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.view.tag == 0 {
            return arrVCs[1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.view.tag == 1 {
            return arrVCs[0]
        }
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            if previousViewControllers.last?.view.tag == 0 {
                if languageHelper.isArabic() {
                    var basketTopFrame = viewIndicator.frame;
                    basketTopFrame.origin.x = 0
                    
                    UIView.animate(withDuration: 0.3) {
                        self.viewIndicator.frame = basketTopFrame
                    }
                }else {
                    var basketTopFrame = viewIndicator.frame;
                    basketTopFrame.origin.x = self.viewPageC.frame.size.width/2;
                    
                    UIView.animate(withDuration: 0.3) {
                        self.viewIndicator.frame = basketTopFrame
                    }
                }
            }else {
                if languageHelper.isArabic() {
                    var basketTopFrame = viewIndicator.frame;
                    basketTopFrame.origin.x = self.viewPageC.frame.size.width/2;
                    
                    UIView.animate(withDuration: 0.3) {
                        self.viewIndicator.frame = basketTopFrame
                    }
                }else {
                    var basketTopFrame = viewIndicator.frame;
                    basketTopFrame.origin.x = 0
                    
                    UIView.animate(withDuration: 0.3) {
                        self.viewIndicator.frame = basketTopFrame
                    }
                }
            }
        }
    }
}

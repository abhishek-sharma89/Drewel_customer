//
//  AppDelegate.swift
//  Drewel
//
//  Created by Octal on 27/03/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import CoreData
import GooglePlaces
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit
import UserNotifications
import Fabric
import Firebase
import Crashlytics
import TwitterKit

let languageHelper = LanguageDetails.init()
var admin_unread = Int()
var user_unread = Int()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        //register for PN
        registerForRemoteNotification()
        
        // Facebook login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GMSServices.provideAPIKey("AIzaSyCDTYlhRt3awGAmsLvhGpBPdoz3_RkwwWg")
        GMSPlacesClient.provideAPIKey("AIzaSyCDTYlhRt3awGAmsLvhGpBPdoz3_RkwwWg")
        
        Fabric.with([Crashlytics.self])
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "wdzCXJcKfGvFIzlQrmk9hKq4J", consumerSecret: "OPMqf8jpuLpA2AY3DZktwErDH4dS3NzfjCpf2lktiG1JCECzm5")
        
        let isLoggedIn = UserDefaults.standard.value(forKey: kAPP_IS_LOGEDIN) as? Bool ?? false
        
        if isLoggedIn {
            let userData = UserData.sharedInstance;
            let dict = helper.fetchDataFromDefaults(with: kAPPUSERDATA)
            userData.user_id            = "\(dict.value(forKey: "user_id") ?? "")"
            userData.first_name         = "\(dict.value(forKey: "first_name") ?? "")"
            userData.last_name          = "\(dict.value(forKey: "last_name") ?? "")"
            userData.mobile_number      = "\(dict.value(forKey: "mobile_number") ?? "")"
            userData.role_id            = "\(dict.value(forKey: "role_id") ?? "")"
            userData.email              = "\(dict.value(forKey: "email") ?? "")"
            userData.latitude           = "\(dict.value(forKey: "latitude") ?? "")"
            userData.longitude          = "\(dict.value(forKey: "longitude") ?? "")"
            userData.img                = "\(dict.value(forKey: "img") ?? "")"
            userData.modified           = "\(dict.value(forKey: "modified") ?? "")"
            userData.is_notification    = "\(dict.value(forKey: "is_notification") ?? "")"
            userData.remember_token     = "\(dict.value(forKey: "remember_token") ?? "")"
            userData.is_mobileverify    = "\(dict.value(forKey: "is_mobileverify") ?? "")"
            userData.fb_id              = "\(dict.value(forKey: "fb_id") ?? "")"
            userData.country_code       = "\(dict.value(forKey: "country_code") ?? "")"
            userData.cart_id            = "\(dict.value(forKey: "cart_id") ?? "")"
            userData.cart_quantity      = "\(dict.value(forKey: "cart_quantity") ?? "0")"
            
            userData.address_name       = "\(dict.value(forKey: "address_name") ?? "")"
            userData.address_longitude  = "\(dict.value(forKey: "address_longitude") ?? "")"
            userData.address_latitude   = "\(dict.value(forKey: "address_latitude") ?? "")"
            userData.address            = "\(dict.value(forKey: "address") ?? "")"
            
            self.setRootViewController();
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = languageHelper.LocalString(key: "Done_Title")
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-380, 0), for:UIBarMetrics.default)
        UINavigationBar.appearance().backIndicatorImage = #imageLiteral(resourceName: "back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate .sharedInstance() .application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return FBSDKApplicationDelegate .sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    //MARK: - Register User Notifications
    
    func registerForRemoteNotification() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                else{
                    print("Notifications permission not given")
                }
            })
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Remote Notification Methods // <= iOS 9.x
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let chars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var token = ""
        
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [chars[i]])
        }
        print("\n\n\n\nAPN Device Token : \(token)")
        //        self.myNSLog("Device Token = %@", token)
        
        UserDefaults.standard.setValue(token, forKey: kAPP_DEVICE_ID)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        NSLog("didFailToRegisterForRemoteNotificationsWithError Error = %@", error.localizedDescription)
        
       // UserDefaults.standard.setValue("ksbjiojgr3q904tjdfg834jnelr834laj809239fjs", forKey: kAPP_DEVICE_ID)
        
        UserDefaults.standard.setValue("0000", forKey: kAPP_DEVICE_ID)
        
    }
    
    // MARK: - UNUserNotificationCenter Delegate // >= iOS 10
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        center.removeAllDeliveredNotifications()
        
        let userInfo = notification.request.content.userInfo
        
        print("User Info = ",userInfo)
        
        guard let type = userInfo["notification_type"] as? String, let item_id = userInfo["item_id"] as? String else {
            completionHandler([.alert, .badge, .sound])
            return
        }
        
        let tabVC = self.window?.rootViewController as? MyTabVC ?? UITabBarController()
        var selectedTab = 0
        if tabVC.isKind(of: MyTabVC.classForCoder()) {
            selectedTab = tabVC.selectedIndex
        }else {
            completionHandler([.alert, .badge, .sound])
            return
        }
        let navVC = tabVC.viewControllers![selectedTab] as! UINavigationController
        if type == "deliveryStatusChange" || type == "deliveryBoyAssigned" /*|| type == "orderCancelled" */{
            if selectedTab == 3 {
                NotificationCenter.default.post(name: Notification.Name(kNOTIFICATION_RELOAD_ORDER_LIST), object: nil)
            }
        }else if type == "orderPlaced" {
            completionHandler([.badge, .sound])
            return
        }else if  type == "chat" {
            let vc = navVC.topViewController ?? UIViewController()
            if vc.isKind(of: ChatVC.classForCoder()) {
                completionHandler([])
                return
            }
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        let userInfo = response.notification.request.content.userInfo
        print(userInfo);
        
        guard let type = userInfo["notification_type"] as? String, let item_id = userInfo["item_id"] as? String else {
            completionHandler()
            return
        }
        
        let tabVC = self.window?.rootViewController as? MyTabVC ?? UITabBarController()
        var selectedTab = 0
        if tabVC.isKind(of: MyTabVC.classForCoder()) {
            selectedTab = tabVC.selectedIndex
        }else {
            completionHandler()
            return
        }
        
        let navVC = tabVC.viewControllers![selectedTab] as! UINavigationController
        
        if type == "deliveryStatusChange" || type == "deliveryBoyAssigned" || type == "orderPlaced" || type == "orderCancelled" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "OrderDtailsVC") as! OrderDtailsVC
            vc.orderId = item_id
            navVC.show(vc, sender: nil)
        }else if type == "productAvailable" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsTableVC
            vc.product_id = item_id
            navVC.show(vc, sender: nil)
        }else if type == "pendingCart" {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            navVC.show(vc, sender: nil)
        }else {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "NotificationsListVC") as! NotificationsListVC
            navVC.show(vc, sender: nil)
        }
        completionHandler()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Drewel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func setRootViewController() {
        let userData = UserData.sharedInstance;
        if userData.role_id == "2"
        {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "tabControllerCustomer")
            self.window?.rootViewController = vc;
        }
        else {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "tabControllerCustomer")
            self.window?.rootViewController = vc;
        }
    }
    
}


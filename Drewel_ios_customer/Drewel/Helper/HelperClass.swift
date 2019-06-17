//
//  HelperClass.swift
//  Staff Managment
//
//  Created by IOS PC-2 on 16/06/17.
//  Copyright © 2017 Rakesh Gupta. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SVProgressHUD
//import Alamofire

var navigationBarImages : NavigationImages? = NavigationImages()

let helper = HelperClass()

struct NavigationImages {
    var backgroundImage : UIImage?
    var shadowImage : UIImage?
}

struct MediaType {
    static let audio = "audio/m4a"
    static let video = "video/mp4"
    static let image = "image/jpeg"
}

class CustomTextField : UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textAlignment = languageHelper.isArabic() ? .right : .left
    }
}

class CustomTextView : UITextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textAlignment = languageHelper.isArabic() ? .right : .left
    }
}

class HelperClass : NSObject {
    
    typealias ASCompletionBlock = (_ result: NSDictionary, _ error: Error?, _ success: Bool) -> Void
    typealias ABCompletionBlock = (_ result: NSDictionary, _ message: String, _ success: String) -> Void
    
    
    var locationManager : CLLocationManager?
    
    
    
    class func isValidEmail(testStr:String) -> Bool {
        
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func showPopupAlertController(sender : Any?, message : String, title : String) -> Void {
        
        let alert = UIAlertController(title: title as String,
                                      message: message as String,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = kThemeColor1;
        // create attributed string
//        let myString = "Swift Attributed String"
//        let myAttribute = [NSAttributedStringKey.foregroundColor: UIColor.blue ]
//        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
//
//        alert.setValue(NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor : kThemeColor1]), forKey: "attributedTitle")
//        myLabel.attributedText = myAttrString
        
//        alert.present(sender as! UIViewController, animated: true, completion: nil)
//        let subview = alert.view.subviews.first! as UIView
//        let alertContentView = subview.subviews.first! as UIView
//        alertContentView.backgroundColor = kThemeColor1
//        alertContentView.backgroundColor = UIColor.blackColor()
//        alert.view.tintColor = kThemeColor1
        let OKAction = UIAlertAction(title: languageHelper.LocalString(key:"OK_Title"),
                                     style: .default, handler: nil)
        
        alert.addAction(OKAction)
        
        if (UIApplication.shared.keyWindow?.rootViewController! .isKind(of: UINavigationController.self))!{
          //  let nav = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
           // nav.viewControllers[nav.viewControllers.count-1].present(alert, animated: true, completion: nil)
            (sender as! UIViewController).present(alert, animated: true, completion: nil)                                                                                                                                                              
          //  UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        }else {
           UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true,completion: nil)
        }
       
        //UIApplication.shared.keyWindow?.rootViewController!.presentedViewController?.present(alert, animated: true, completion: nil)
        
    }
    
//    func myNSLog(_ givenFormat: String, _ args: CVarArg..., _ function:String = #function) {
//        let format = "\(function): \(givenFormat)"
//        withVaList(args) { NSLogv(format, $0) }
//    }
    
    class func UTCToLocal(date:String) -> String {
        let dateFormator = DateFormatter()
        dateFormator.locale = languageHelper.getLocale()
        dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"  //"2017-07-11 09:45:39"
        dateFormator.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormator.date(from: date)
        if (dt == nil){
            return ""
        }else{
            dateFormator.timeZone = TimeZone.current
            //dateFormator.dateFormat = "h:mm a"
            return dateFormator.string(from: dt!)
        }
    }
    
    class func isAlphabaticName(_ name: String) -> Bool{
        let regex: String = "^[a-zA-Z]+$"
        let userNameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return userNameTest.evaluate(with: name)
    }
    
    class func createCustomTitle(text: String, vc:UIViewController)
    {
        let lblTitle : UILabel = UILabel()
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.text = text
//        lblTitle.textColor = kAPP_DEFAULT_PINK_COLOR
//        lblTitle.font = UIFont(name: kAPPFontBold, size: 18)
        lblTitle.sizeToFit()
        vc.navigationItem.titleView = lblTitle
    }
    
//    func createBorderOnNavigation( vc:UIViewController)
//    {
//        let shadowView = UIView(frame: CGRect( x: 0, y: 0, width: SCREEN_WIDTH, height:64.0 ))
//        shadowView.backgroundColor = UIColor.white
//        shadowView.layer.masksToBounds = false
//        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
//        shadowView.layer.shadowOpacity = 0.8
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        shadowView.layer.shadowRadius = 2
//        vc.view.addSubview(shadowView)
//    }
    
    func ShowHud()
    {
//        SVProgressHUD.setBackgroundColor(UIColor.clear)
//        SVProgressHUD.setRingThickness(5.0)
//        SVProgressHUD.setForegroundColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
//        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
    }
    
    func HideHud()
    {
        SVProgressHUD.dismiss()
    }
    
    class func showLoginPopup(sender : Any) {
        let refreshAlert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key:"LOGIN_MSG"), preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.view.tintColor = kThemeColor1
        refreshAlert.setValue(NSAttributedString(string: kAPPName, attributes: [NSAttributedStringKey.foregroundColor : kThemeColor1]), forKey: "attributedTitle")
        refreshAlert.addAction(UIAlertAction(title: languageHelper.LocalString(key:"Login_Title"), style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: false, completion: nil)
            
            let navVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavLogin") as! UINavigationController
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
            navVc.setViewControllers([vc], animated: false)
            
            UIApplication.shared.keyWindow?.rootViewController = navVc
        }))
        
        refreshAlert.addAction(UIAlertAction(title: languageHelper.LocalString(key:"Cancel_Title"), style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: false, completion: nil)
        }))
        
        
        (sender as! UIViewController).present(refreshAlert, animated: true, completion: nil)
    }
    
    class func getBadgeCountAPI() {
        
    }
    
    let nFormatter: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.numberStyle = .decimal
        _formatter.minimumFractionDigits = 3
        _formatter.maximumFractionDigits = 3
        _formatter.generatesDecimalNumbers = false
        return _formatter
    }()
    
    func convertDateFromUTCToCurrent(strDate : String, inFormat : String, outFormat : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = inFormat
        formatter.timeZone = TimeZone.init(abbreviation: "UTC")
        let date = formatter.date(from: strDate) ?? Date()
        formatter.dateFormat = outFormat
        formatter.timeZone = TimeZone.current
        formatter.locale = languageHelper.getLocale()
        return formatter.string(from: date)
    }
    
    // MARK: Validation Methods
    
    class func isValidFirstName(_ FirstName : String) -> Bool {
        let regex: String = "^[a-z0-9_-]{2,15}$"
        let userNameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return userNameTest.evaluate(with: FirstName)
    }
    
    class func isValidLastName(_ LastName : String) -> Bool {
        let regex: String = "^[a-z0-9_-]{2,15}$"
        let userNameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return userNameTest.evaluate(with: LastName)
    }
    
    class func isValidMobileNumber(_ number : String) -> Bool {
        
        let stripped = number.trimmingCharacters(in: .whitespacesAndNewlines)
        if (stripped.count ) < 5 || (stripped.count ) > 17 {
            return false
        }
        let Regex: String = "^([0-9]*)$"
        //NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,10}$";
        let mobileTest = NSPredicate(format: "SELF MATCHES %@", Regex)
        return mobileTest.evaluate(with: stripped)
    }
    
    class func isValidPassword(_ password : String) -> Bool {
        let regex: String = "^(?=.*[0-9])(?=.*[A-Za-z]).{6,20}$"
        let userNameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return userNameTest.evaluate(with: password)
    }
    
    func isAlphaNumericName(_ name: String) -> Bool{
        let stripped = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if (stripped.count ) < 5 || (stripped.count ) > 30 {
            return false
        }
        let Regex: String = "^(?=.*[a-z])(?=.*[0-9])[A-Za-z0-9-!$@#%^&*()_+|~=`{}:;'<>?,.]{6,}$"
        //NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,10}$";
        let mobileTest = NSPredicate(format: "SELF MATCHES %@", Regex)
        return mobileTest.evaluate(with: stripped)
        
    }
    
    class func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    
    class func isValidEmailId(_ email: String) -> Bool {
        //	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        //    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        //
        //	return [emailTest evaluateWithObject:email];
//        let stricterFilter: Bool = false
        // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//        let stricterFilterString: String = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let laxString: String = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailRegex: String =  laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func saveDataToDefaults(dataObject: NSDictionary, key : String) {
        let currentDefaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: dataObject)
        currentDefaults.set(data, forKey: kAPPUSERDATA)
        currentDefaults.synchronize()
    }
    func fetchDataFromDefaults(with key : String)->NSDictionary {
        let currentDefaults = UserDefaults.standard
        
        let data = (currentDefaults.value(forKey: kAPPUSERDATA) as? Data)
        return NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! NSDictionary
    }
    
        
    //MARK: - WebService Methods
    
    class func requestForAllApiWithBody( param : NSDictionary,serverUrl urlString : String, showAlert isAlert : Bool, showHud isHud : Bool, andHeader isHeader : Bool ,vc : UIViewController, completionHandler : @escaping ABCompletionBlock) -> Void {
        
        var ishud = isHud
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        
        
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        
        print("Request URL: \(kBaseURL)\(urlString)")
        print("Data: \(myString!)")
        
        var request = URLRequest(url: URL(string: (kBaseURL + urlString))!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 45)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        if ishud {
            SVProgressHUD.setBackgroundColor(UIColor.white)
            SVProgressHUD.setRingThickness(5.0)
            SVProgressHUD.setForegroundColor(kThemeColor1)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show()
        }
        
        if isHeader {
            
//            request.setValue(UserDefaults.standard.value(forKey: "") as? String, forHTTPHeaderField: "splalgoval")
        }
        
        if urlString != kURL_Signup {
            let lang = languageHelper.language == "en" ? "eng" : "ara";
            request.setValue(lang, forHTTPHeaderField: "language")
        }
        
        request.timeoutInterval = 45
        var postDataTask = URLSessionDataTask()
        postDataTask.priority = URLSessionDataTask.highPriority
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            //            var json : (Any);
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                    let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    print("Result: \(myString ?? "")")
                    
                    let dict : NSDictionary = (json as! NSDictionary).value(forKey: "response") as! NSDictionary;
                    let status = "\((dict ).value(forKey: "status") ?? "false")"
                    let message = (dict ).value(forKey: "message") as? String ?? "Request failed."
                    SVProgressHUD.dismiss()
                    ishud = false
                    if status == "1" {
                        let data = (dict ).value(forKey: "data") as? NSDictionary  ?? [:]
                        completionHandler(data, message, status)
                    } else {
                        completionHandler([:], message, status)
                    }
                }catch {
                    print(error.localizedDescription)
                    if isAlert {
//                        HelperClass.showErrorMessage(msg: languageHelper.LocalString(key: "jsonError"), on: vc)
                        HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "jsonError"), title: kAPPName)
                    }
                }
            }else if error != nil {
                print((error?.localizedDescription)!)
                
                if isAlert {
                    completionHandler([:], languageHelper.LocalString(key: "failError"), "0")
//                      HelperClass.showPopupAlertController(sender: vc, message: (error?.localizedDescription)!, title: kAPPName)
                }
            }else {
                if isAlert {
                    completionHandler([:],  languageHelper.LocalString(key: "unknownError") , "0")
//                    HelperClass.showPopupAlertController(sender: vc, message: "Request failed with unknown error.", title: kAPPName)
                }
            }
            if ishud {
                SVProgressHUD.dismiss()
            }
        })
        postDataTask.resume()
    }
    
    class func requestApiWithBody( param : NSDictionary,serverUrl urlString : String, showAlert isAlert : Bool, showHud isHud : Bool, andHeader isHeader : Bool ,vc : UIViewController, completionHandler : @escaping ABCompletionBlock) -> URLSessionDataTask {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        
        
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
        
        print("Request URL: \(kBaseURL)\(urlString)")
        print("Data: \(myString!)")
        
        var request = URLRequest(url: URL(string: (kBaseURL + urlString))!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 45)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        if isHud {
            SVProgressHUD.setBackgroundColor(UIColor.white)
            SVProgressHUD.setRingThickness(5.0)
            SVProgressHUD.setForegroundColor(kThemeColor1)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show()
        }
        
        if isHeader {
            
            //            request.setValue(UserDefaults.standard.value(forKey: "") as? String, forHTTPHeaderField: "splalgoval")
        }
        
        if urlString != kURL_Signup {
            let lang = languageHelper.language == "en" ? "eng" : "ara";
            request.setValue(lang, forHTTPHeaderField: "language")
        }
        
        request.timeoutInterval = 45
        var postDataTask = URLSessionDataTask()
        postDataTask.priority = URLSessionDataTask.highPriority
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            //            var json : (Any);
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
//                    let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: json , options: .prettyPrinted)
                    let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    print("Result: \(myString ?? "")")
                    
                    let dict : NSDictionary = (json as! NSDictionary).value(forKey: "response") as! NSDictionary
                    let status = "\((dict ).value(forKey: "status") ?? "false")"
                    let message = (dict ).value(forKey: "message") as? String ?? "Request failed."
                    if status == "1" {
                        let data = (dict ).value(forKey: "data") as? NSDictionary  ?? [:]
                        completionHandler(data, message, status)
                    }else {
                        completionHandler([:], message, status)
                    }
                }catch {
                    print(error.localizedDescription)
                    if isAlert {
//                        HelperClass.showErrorMessage(msg: error.localizedDescription, on: vc)
                        HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "jsonError"), title: kAPPName)
                    }
                }
            }else if error != nil {
                print((error?.localizedDescription)!)
                
                if isAlert {
                    HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "failError"), title: kAPPName);
                }
            }else {
                if isAlert {
//                    HelperClass.showErrorMessage(msg: "Request failed with unknown error.", on: vc)
                    HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "unknownError"), title: kAPPName);
                }
            }
            if isHud {
                SVProgressHUD.dismiss()
            }
        })
        postDataTask.resume()
        return postDataTask
    }
    
    class func formRequestApiWithBody( param : NSDictionary, urlString : NSString, mediaData : UIImage?, isHeader : Bool , showAlert isAlert : Bool, showHud isHud : Bool, vc : UIViewController, completionHandler : @escaping ABCompletionBlock) -> Void {
        if isHud {
            SVProgressHUD.show()
        }
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: param, options:.prettyPrinted)
        let myString = String(data: jsonData!, encoding: String.Encoding.utf8)!
        
        print("Request URL: \((kBaseURL + (urlString as String)))")
        print("Data: \(String(describing: myString))")
        
        var request = URLRequest(url: URL(string: (kBaseURL + (urlString as String)))!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 45)
        
        request.httpMethod = "POST"
        
        if isHeader {
//            request.setValue(UserDefaults.standard.value(forKey: "") as? String, forHTTPHeaderField: "splalgoval")
        }
        
//        if (urlString as String) != kURL_Signup {
//            let lang = languageHelper.language == "en" ? "eng" : "ara";
//            request.setValue(lang, forHTTPHeaderField: "language")
//        }
        
        var body = Data()
        let boundary: String = "0xKhTmLbOuNdArY"
        let kNewLine: String = "\r\n"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Add the parameters from the dictionary to the request body
        
        body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=data".data(using: String.Encoding.utf8)!)
        // For simple data types, such as text or numbers, there's no need to set the content type
        body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
        body.append(jsonData!)
        body.append(kNewLine.data(using: String.Encoding.utf8)!)
        
        
        // Add the image to the request body
        if mediaData != nil {
            
            let datas = UIImageJPEGRepresentation(mediaData!, 0.5)
            body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=image; filename=file_name.jpeg; Content-Type:image/jpeg;".data(using: String.Encoding.utf8)!)
            body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append(datas!)
            body.append(kNewLine.data(using: String.Encoding.utf8)!)
            
        }
        // Add the terminating boundary marker to signal that we're at the end of the request body
        body.append("--\(boundary)--".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body;
        var postDataTask = URLSessionDataTask()
        postDataTask.priority = URLSessionTask.highPriority
        
        postDataTask = session.dataTask(with: request, completionHandler: { (data : Data?,response : URLResponse?, error : Error?) in
            //            var json : (Any);
            if data != nil && response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    let results = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: results! , options: .prettyPrinted)
                    let myString = String(data: jsonData!, encoding: String.Encoding.utf8)
                    print("Result: \(myString ?? "")")
                    
                    let dict : NSDictionary = (json as! NSDictionary).value(forKey: "response") as! NSDictionary;
                    let status = "\((dict ).value(forKey: "status") ?? "0")"
                    let message = (dict ).value(forKey: "message") as? String ?? "Request failed."
                    if status == "1" {
                        let data = (dict ).value(forKey: "data") as? NSDictionary ?? [:]
                        completionHandler(data, message, status)
                    } else {
                        completionHandler([:], message, status)
                    }
                }catch {
                    print(error.localizedDescription)
                    
                    if isAlert {
//                        HelperClass.showErrorMessage(msg: error.localizedDescription, on: vc)
                        HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "jsonError"), title: kAPPName);
                    }
                }
                if isHud {
                    SVProgressHUD.dismiss()
                }
            }else if error != nil {
                if isHud {
                    SVProgressHUD.dismiss()
                }
                print((error?.localizedDescription)!)
                if isAlert {
//                    HelperClass.showErrorMessage(msg: (error?.localizedDescription)!, on: vc)
                    HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "failError"), title: kAPPName)
                }
            }else {
                if isHud {
                    SVProgressHUD.dismiss()
                }
                if isAlert {
//                    HelperClass.showErrorMessage(msg: "Request failed with unknown error.", on: vc)
                    HelperClass.showPopupAlertController(sender: vc, message: languageHelper.LocalString(key: "unknownError"), title: kAPPName)
                }
            }
            if isHud {
                SVProgressHUD.dismiss()
            }
        })
        postDataTask.resume()
        
    }
    
    class func showErrorMessage(msg : String, on vc : UIViewController) {
        let message = msg
        let refreshAlert = UIAlertController(title: kAPPName, message: message, preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.view.tintColor = kThemeColor1
        refreshAlert.setValue(NSAttributedString(string: kAPPName, attributes: [NSAttributedStringKey.foregroundColor : kThemeColor1]), forKey: "attributedTitle")
        
        refreshAlert.addAction(UIAlertAction(title: languageHelper.LocalString(key:"Cancel_Title"), style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: false, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: languageHelper.LocalString(key:"Call_Title"), style: .default, handler: { (action: UIAlertAction!) in
            if let phoneCallURL:URL = URL(string: "tel:+96892227392") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            }
            refreshAlert.dismiss(animated: false, completion: nil)
        }))
        vc.present(refreshAlert, animated: true, completion: nil)
    }
    
    class func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    class func addShadowToView(view:UIView, radius:CGFloat) -> Void {
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor .groupTableViewBackground.cgColor
        view.layer.shadowColor = UIColor .darkGray.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = radius
        view.layer.shadowOffset = CGSize.init(width: 0.0, height: 0.0)
    }
    
    func startGettingMyLocation() {
        self.locationManager = CLLocationManager();
        self.locationManager?.delegate = (self as! CLLocationManagerDelegate)
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager?.startUpdatingLocation();
    }
    
    func stopGettingMyLocation() {
        if (self.locationManager != nil) {
            self.locationManager?.stopUpdatingLocation()
            self.locationManager = nil
        }
    }
}

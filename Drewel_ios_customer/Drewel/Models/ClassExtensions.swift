//
//  ClassExtensions.swift
//  Sahel
//
//  Created by Octal on 30/10/17.
//  Copyright © 2017 Octal. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

extension UITextField
{
    @IBInspectable var bottomBorderColor:UIColor{
        set {
            setBottomBorder(borderColor: newValue)
        }
        get{
            return UIColor.clear
        }
    }
    func setBottomBorder(borderColor: UIColor)
    {
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        
        DispatchQueue.main.async {
            let width = 1.0
            
            let borderLine = UIView()
            borderLine.tag = 1
            // self.layoutIfNeeded()
            borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
            
            borderLine.backgroundColor = borderColor
            self.addSubview(borderLine)
        }
    }
    func addPaddingView(width: Double, onSide side: NSInteger)
    {
        let paddingView = UIView()
        //self.layoutIfNeeded()
        paddingView.frame = CGRect(x: 0, y: 0, width: width, height: Double(self.frame.height))
        paddingView.backgroundColor = UIColor.clear
        if side == 0{
            self.leftView = paddingView
            self.leftViewMode = .always
        }else{
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
}

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 2
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}

public extension UIColor {
    public class var myThemeColor:UIColor? {
        set {
            UIColor.myThemeColor = UIColor(red:0.52, green:0.35, blue:0.35, alpha:1.0);
        }
        get {
            return UIColor(red:0.52, green:0.35, blue:0.35, alpha:1.0);
        }
    }
}

@IBDesignable extension UIView {
    
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
        
    }
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
            layer.masksToBounds = false
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
}

extension String {
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options = [
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentAttributeKey.characterEncoding.rawValue: String.Encoding.utf8.rawValue
            ] as! [NSAttributedString.DocumentReadingOptionKey: Any]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    var trimWhitespaces: String {
        return self.trimmingCharacters(in: .whitespaces)
        //return components(separatedBy: .whitespaces).joined(separator: "")
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return ""
        }
        
        return String(data: data, encoding: .utf8)
        
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    var parseJSONString: Any? {
        let data = self.data(using: .utf8)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json
        } catch {
            return nil
        }
    }
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let charcter  = NSCharacterSet.init(charactersIn: "+0123456789").inverted
        var filtered:String!
        let inputString:NSArray = self.components(separatedBy: (charcter)) as NSArray
        filtered = inputString.componentsJoined(by: "")
        return  self == filtered
    }
    
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
}

//extension NSString {
//    //validate PhoneNumber
//    var isPhoneNumber: Bool {
//
//        let charcter  = NSCharacterSet.init(charactersIn: "0123456789").inverted
//        var filtered:NSString!
//        let inputString:NSArray = self.components(separatedBy: (charcter)) as NSArray
//        filtered = inputString.componentsJoined(by: "") as NSString
//        return  self == filtered
//    }
//}

extension Array {
    
    init?(jsonString: String) {
        guard let array = (
            try? JSONSerialization.jsonObject(with: Data(jsonString.utf8))
            ) as? [Element]
            else { return nil }
        
        self.init(array)
    }
}
extension Dictionary {
    func toJson() {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        print("JSON string = \(jsonString)")
    }
    
    
    func nullKeyRemoval() -> [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = self
        
        let keysToRemove = dict.keys.filter { dict[$0] is NSNull }
        let keysToCheck = dict.keys.filter({ dict[$0] is Dictionary })
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        for key in keysToCheck {
            if let valueDict = dict[key] as? [AnyHashable: Any] {
                dict.updateValue(valueDict.nullKeyRemoval(), forKey: key)
            }
        }
        return dict
    }
}

extension NSDictionary {
    func toJson() {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        print("JSON string = \(jsonString ?? "")")
    }
    
    func removeNullValueFromDict()-> NSDictionary
    {
        let mutableDictionary:NSMutableDictionary = NSMutableDictionary(dictionary: self)
        for key in mutableDictionary.allKeys
        {
            if("\(mutableDictionary.object(forKey: "\(key)")!)" == "<null>")
            {
                mutableDictionary.setValue("", forKey: key as! String)
            }
            else if((mutableDictionary.object(forKey: "\(key)")! as AnyObject).isKind(of: NSNull.classForCoder()))
            {
                mutableDictionary.setValue("", forKey: key as! String)
            }
            else if ((mutableDictionary.object(forKey: "\(key)")! as AnyObject).isKind(of: NSDictionary.classForCoder()))
            {
                
//                mutableDictionary.setValue(mutableDictionary.object(forKey: "\(key)")! as AnyObject, forKey: "\(key)")
                
                
                
                
                mutableDictionary.setValue((mutableDictionary.object(forKey: "\(key)")! as! NSDictionary).removeNullValueFromDict(), forKey: key as! String)
                
            }
        }
        return mutableDictionary
    }
}

extension CLLocationCoordinate2D {
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}


extension UIImageView
{
    func setAppBGImage() {
        let height :CGFloat =  567.00 //SCREEN_HEIGHT
        switch height {
        case 480:
            self.image = UIImage(named: "bg_comon@2x.png")
        case 568:
            self.image = UIImage(named: "bg_comon568h.png")
        case 667:
            self.image = UIImage(named: "bg_comon667@2x.png")
        case 736:
            self.image = UIImage(named: "bg_comon@3x.png")
        default:
            self.image = UIImage(named: "bg_comon667.png")
        }
    }
    
    func setImage(url: URL , withPlaceHolder placeholder_image : UIImage) {
        let imageCache = NSCache<NSString, AnyObject>()
        
        // MARK: - Properties
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
        } else {
            self.image = placeholder_image
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    if imageToCache != nil {
                        imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                        self.image = imageToCache
                    }
                }
            }.resume()
        }
    }
}
extension UIImage {
    
    /**
     Returns an UIImage with a specified background color.
     - parameter color: The color of the background
     */
    convenience init(withBackground color: UIColor) {
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.setFillColor(color.cgColor);
        context.fill(rect)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.init(ciImage: CIImage(image: image)!)
        
    }
}
extension UIImagePickerController {
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return nil
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                if gesture.isKind(of: UITapGestureRecognizer.classForCoder()) {
                    view.removeGestureRecognizer(gesture)
                }
            }
        }
    }
}

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0;
extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(8)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)".replaceEnglishDigitsWithArabic
        label.alignmentMode = kCAAlignmentCenter
        label.fontSize = 12
        label.frame = CGRect(origin: CGPoint(x: location.x - (number>9 ? 8 : 5), y: offset.y), size: CGSize(width: number>9 ? 14 : 9, height: 16))
        label.foregroundColor = filled ? kThemeColor1.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}

extension UICollectionView {
    func indexPathForView(view: AnyObject) -> NSIndexPath? {
        let originInCollectioView = self.convert(CGPoint(x: 0,y :0), from: (view as! UIView))
        return (self.indexPathForItem(at: originInCollectioView)! as NSIndexPath)
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

//extension URL {
//    var queryItems: [String: String]? {
//        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
//            .queryItems?
//            .flatMap { $0.dictionaryRepresentation }
//            .reduce([:], +)
//    }
//}

extension URLQueryItem {
    var dictionaryRepresentation: [String: String]? {
        if let value = value {
            return [name: value]
        }
        return nil
    }
}





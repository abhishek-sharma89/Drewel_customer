import Foundation;
import UIKit;


// MARK: Localizable
public protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    
    public var localized: String {
//        let lll = LocalizationSystem.sharedLocal()
        let vv = languageHelper.LocalString(key: self)
        return  vv // (lll?.localizedString(forKey: self, value: "")!)!
        //return AMLocalizedString(self, comment: "")
    }
}

// MARK: XIBLocalizable
public protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

public protocol XIBMultiLocalizable {
    var xibLocKeys: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}

extension UITextField: XIBLocalizable {
    @IBInspectable public var xibLocKey : String? {
        get { return nil }
        set(key) {
            semanticContentAttribute = languageHelper.isArabic() ? UISemanticContentAttribute.forceRightToLeft : UISemanticContentAttribute.forceLeftToRight
            DispatchQueue.main.async {
                self.placeholder = key?.localized
            }
        }
    }
}

extension UISegmentedControl: XIBMultiLocalizable {
    @IBInspectable public var xibLocKeys: String? {
        get { return nil }
        set(keys) {
            guard let keys = keys?.components(separatedBy: ","), !keys.isEmpty else { return }
            for (index, title) in keys.enumerated() {
                setTitle(title.localized, forSegmentAt: index)
            }
        }
    }
}

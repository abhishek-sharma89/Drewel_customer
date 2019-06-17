//  SearchAddressVC.swift
//  Drewel
//
//  Created by Octal on 13/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@objc protocol SetDefaultAddressDelegate
{
    func seDefaultAddress(dict :NSDictionary);
}

class SearchAddressVC: UIViewController, SetLocationDelegate {
    @IBOutlet weak var tblAddress: UITableView!
    @IBOutlet weak var lblAddAddress: UILabel!
    
    var userData = UserData.sharedInstance;
    var delegate: SetDefaultAddressDelegate? = nil
    
    var lat : Double = 0.00;
    var long : Double = 0.00;
    var address : String = "";
    var placeName : String = "";
    var zipCode : String = "";
    let geoCoder = GMSGeocoder()
    
    var arrAdrsDict = Array<NSDictionary>()
    
    var defaultAddrsIndex : Int = 0
    // MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.setInitialValues()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.checkForDeliveryAddress()
        self.getAddressAPI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.hidesBackButton = false
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "selectYourAddress")
    }
    
    func checkForDeliveryAddress() {
        let address = UserDefaults.standard.object(forKey: kDefaultAddress)
        if address == nil {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func btnSearchAddressAction(_ sender: UIButton) {
        let vc = GMSAutocompleteViewController()
        vc.delegate = self
//        let filter = GMSAutocompleteFilter()
//        filter.country = Locale.current.regionCode  //appropriate country code
//        vc.autocompleteFilter = filter
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
        if self.arrAdrsDict.count <= 0 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "ADD_ADDRESS_MESSAGE"), title: kAPPName)
            return;
        }
        self.navigationController?.popViewController(animated: true)
        self.delegate?.seDefaultAddress(dict: self.arrAdrsDict[self.defaultAddrsIndex].removeNullValueFromDict())
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        if "\(self.arrAdrsDict[(self.tblAddress.indexPath(for: cell)?.row)!].removeNullValueFromDict().value(forKey: "is_default") ?? "0")" == "1" {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "deleteDefaultAddressMSG"), title: kAPPName)
            return
        }
        
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "delete_Address_MSG"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "no"), style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "yes"), style: UIAlertActionStyle.default) { _ in
            self.deleteAddressAPI(reqId: "\(self.arrAdrsDict[(self.tblAddress.indexPath(for: cell)?.row)!].value(forKey: "id") ?? "0")")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - SetLocationDelegate
    func setLocationWithAddress(latitude: Double, longitude: Double, fullAddress: String, zipcode: String, name: String) {
        self.lat = latitude
        self.long = longitude
        self.address = fullAddress
        self.zipCode = zipcode
        self.placeName = name
        self.saveNewAddressAPI()
    }
    
    // MARK: - WebService Method
    func getAddressAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Address_List, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let arrAdrs = (result.removeNullValueFromDict().value(forKey: "Address") as! NSArray)
                self.arrAdrsDict.removeAll()
                self.arrAdrsDict = arrAdrs as? [NSDictionary] ?? Array<NSDictionary>()
                self.tblAddress.reloadData()
                if self.arrAdrsDict.count > 0 {
                    self.lblAddAddress.text = languageHelper.LocalString(key: "addAnotherAddress")
                }else {
                    self.lblAddAddress.text = languageHelper.LocalString(key: "addAddress")
                }
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func saveNewAddressAPI() {
        let param : NSDictionary = ["address"   : self.address,
                                    "user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "latitude"  : "\(self.lat)",
                                    "longitude" : "\(self.long)",
                                    "is_default": "1",
                                    "name"      : self.placeName,
                                    "zip_code"  : self.zipCode,
                             "iremember_tokens" : self.userData.remember_token]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Add_Address, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
                let dict = ["address"   : self.address,
                            "longitude" : "\(self.long)",
                            "id"        : result.value(forKey: "address_id") as? String ?? "",
                            "is_default": "1",
                            "zip_code"  : self.zipCode,
                            "latitude"  : "\(self.lat)",
                            "name"      : self.placeName]
                
                if self.arrAdrsDict.count > 0 {
                    let dict2 = self.arrAdrsDict[self.defaultAddrsIndex].mutableCopy() as! NSMutableDictionary
                    dict2.setValue("0", forKey: "is_default")
                    
                    self.arrAdrsDict.append(dict2)
                    
                    self.arrAdrsDict[self.defaultAddrsIndex] = dict as NSDictionary
                }else {
                    self.arrAdrsDict.append(dict as NSDictionary)
                }
                
                self.tblAddress.reloadData()
                
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func deleteAddressAPI(reqId : String) {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "address_id": reqId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delete_Address, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.getAddressAPI()
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func setDefaultAddressAPI(oldIndex : Int, newIndex : Int) {
        
        let param : NSDictionary = ["address_id": self.arrAdrsDict[newIndex].value(forKey: "id") ?? "0",
                                    "user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Set_Default_Address, showAlert: true, showHud: false, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                
            }else {
                let dict1 = self.arrAdrsDict[oldIndex].mutableCopy() as! NSMutableDictionary
                dict1.setValue("1", forKey: "is_default")
                self.arrAdrsDict[oldIndex] = dict1
                
                let dict2 = self.arrAdrsDict[newIndex].mutableCopy() as! NSMutableDictionary
                dict2.setValue("0", forKey: "is_default")
                self.arrAdrsDict[newIndex] = dict2
                
                self.tblAddress.reloadRows(at: [IndexPath.init(row: oldIndex, section: 0), IndexPath.init(row: newIndex, section: 0)], with: .automatic)
                self.defaultAddrsIndex = oldIndex
                
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    
    // MARK: - Navigation
     
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSetLocation" {
//            let vc = segue.destination as! SetLocationVC
//            vc.delegate = self
        }
    }
}

//MARK: -

extension SearchAddressVC : GMSAutocompleteViewControllerDelegate{
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress!)
        
        lat = place.coordinate.latitude
        long = place.coordinate.longitude
        self.address = place.formattedAddress ?? ""
        self.placeName = place.name
        if place.addressComponents != nil {
            if (place.addressComponents?.count)! > 0 {
                if place.addressComponents?.last?.type == "postal_code" {
                    self.zipCode = (place.addressComponents?.last?.name)!
                }
            }
        }
        
        let alert = UIAlertController(title: kAPPName, message: languageHelper.LocalString(key: "Add_Address_MSG"), preferredStyle: .alert)
        alert.view.tintColor = kThemeColor1;
        // relate actions to controllers
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "OK_Title"), style: UIAlertActionStyle.default) { _ in
            self.saveNewAddressAPI();
        })
        
        alert.addAction(UIAlertAction(title: languageHelper.LocalString(key: "Cancel_Title"), style: UIAlertActionStyle.cancel, handler: nil))
        
        self.dismiss(animated: true, completion: nil)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // To handle error
        print(error)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @nonobjc func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @nonobjc func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


// MARK: -
//UITableView Delegate & Datasource
extension SearchAddressVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrAdrsDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let address = self.arrAdrsDict[indexPath.row].removeNullValueFromDict()
        (cell.viewWithTag(1) as! UILabel).text = address.value(forKey: "name") as? String ?? ""
        (cell.viewWithTag(2) as! UILabel).text = address.value(forKey: "address") as? String ?? ""
        (cell.viewWithTag(3) as! UIImageView).image = (address.value(forKey: "is_default") as? String ?? "") == "0" ? #imageLiteral(resourceName: "radio_unselected") : #imageLiteral(resourceName: "radio_selected")
        let addressType = address.value(forKey: "delivery_address_type") as? String ?? ""
        (cell.viewWithTag(4) as! UILabel).text = addressType.count > 0 ? ((languageHelper.LocalString(key: (addressType == "1" ? "apartment" : addressType == "2" ? "house" : "office"))) + " - ") : ""
        (cell.viewWithTag(5) as! UIButton).addTarget(self, action: #selector(btnEditAction(_:)), for: .touchUpInside)
        
        self.defaultAddrsIndex = (address.value(forKey: "is_default") as? String ?? "") == "0" ? defaultAddrsIndex : indexPath.row
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != self.defaultAddrsIndex {
            let dict1 = self.arrAdrsDict[indexPath.row].mutableCopy() as! NSMutableDictionary
            dict1.setValue("1", forKey: "is_default")
            self.arrAdrsDict[indexPath.row] = dict1
            
            let dict2 = self.arrAdrsDict[self.defaultAddrsIndex].mutableCopy() as! NSMutableDictionary
            dict2.setValue("0", forKey: "is_default")
            self.arrAdrsDict[self.defaultAddrsIndex] = dict2
            tableView.reloadRows(at: [indexPath, IndexPath.init(row: self.defaultAddrsIndex, section: 0)], with: .automatic)
            
            
            self.setDefaultAddressAPI(oldIndex: self.defaultAddrsIndex, newIndex: indexPath.row)
            self.defaultAddrsIndex = indexPath.row
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 143
    }
}

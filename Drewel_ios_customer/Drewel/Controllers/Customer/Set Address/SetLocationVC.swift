//
//  SetLocationVC.swift
//  Sahel
//
//  Created by Octal on 02/11/17.
//  Copyright © 2017 Octal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SVProgressHUD

@objc protocol SetLocationDelegate
{
    func setLocationWithAddress(latitude: Double, longitude: Double, fullAddress: String, zipcode : String, name : String);
}

class SetLocationVC: BaseViewController {
    
    @IBOutlet weak var viewCustom: UIView!
    @IBOutlet weak var btnSetLocation: UIButton!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    
    var delegate: SetLocationDelegate? = nil
    var lat : Double = 0.0;
    var long : Double = 0.0;
    var address : String = "";
    var placeName : String = "";
    var postalCode : String = "";
    var mapView = GMSMapView()
    var isObserving = false
    
    // MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.tintColor = .white
    }
    
    deinit {
        if self.isObserving {
            self.mapView.removeObserver(self, forKeyPath: "myLocation")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setInitialValues() {
//        self.navigationController?.navigationBar.tintColor = .white
        self.title = languageHelper.LocalString(key: "selectYourLocation")
        self.loadMapView()
        
//        self.btnSetLocation.layer.cornerRadius = self.btnSetLocation.frame.size.height/2;
//        self.btnCurrentLocation.layer.cornerRadius = self.btnCurrentLocation.frame.size.height/2;
    }
    
    func loadMapView() {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(withLatitude: 31.9454, longitude:35.9284,
                                                  zoom: 15)
            self.mapView = GMSMapView.map(withFrame: self.viewCustom.bounds, camera: camera)
            //            self.mapView.mapType = kGMSTypeNormal;
            self.mapView.isMyLocationEnabled = true;
            self.mapView.camera = camera;
            self.mapView.delegate = self
            self.mapView.tintColor = kThemeColor1;
            self.mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
            self.isObserving = true
            //            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: (self.viewGradient.frame.size.height + 20), right: 0)
            
            do {
                // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
                if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                    self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    print("Unable to find style.json")
                }
            } catch {
                print("The style definition could not be loaded: \(error)")
            }
            self.mapView.removeFromSuperview();
            self.viewCustom.addSubview(self.mapView)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let update = change, let myLocation = update[NSKeyValueChangeKey.newKey] as? CLLocation else {
            return
        }
        
        self.mapView.animate(toLocation: myLocation.coordinate);
//        self.lat = myLocation.coordinate.latitude
//        self.long = myLocation.coordinate.longitude
        
        self.mapView.removeObserver(self, forKeyPath: "myLocation")
        self.isObserving = false
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func btnSearchLocationAction(_ sender: UIButton) {
        let autocompletecontroller = GMSAutocompleteViewController()
        autocompletecontroller.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.country = "OM"//Locale.current.regionCode  //appropriate country code
        autocompletecontroller.autocompleteFilter = filter
        self.present(autocompletecontroller, animated: true, completion: nil)
    }
    
    @IBAction func btnSetLocationAction(_ sender: UIButton) {
        lat = self.mapView.camera.target.latitude
        long = self.mapView.camera.target.longitude
        if !self.address.isEmpty && !self.placeName.isEmpty {
            self.callSetLocationDelegate()
        }else {
            GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D.init(latitude: self.lat, longitude: self.long)) { (response, error) in
                if let result = response , error == nil {
                    let dict = (result.firstResult())!
                    
                    var name = (dict.value(forKey: "thoroughfare") as? String ?? "")
                    
                    name = name + ((!(dict.value(forKey: "subLocality") as? String ?? "").isEmpty && !name.isEmpty) ? ", " : "")
                    name = name + (dict.value(forKey: "subLocality") as? String ?? "")
                    
                    name = name + ((!(dict.value(forKey: "locality") as? String ?? "").isEmpty && !name.isEmpty) ? ", " : "")
                    name = name + (dict.value(forKey: "locality") as? String ?? "")
                    
                    
                    self.address = (dict.value(forKey: "lines") as! NSArray).componentsJoined(by: ", ")
                    self.address = self.address.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
                    self.placeName = name.isEmpty ? self.address : name
                    self.postalCode = (dict.value(forKey: "postalCode") as? String ?? "")
                    self.callSetLocationDelegate()
                }
            }
        }
    }
    
    func callSetLocationDelegate() {
        self.checkAddressDeliveryAPI()
    }
    
    @IBAction func btnCurrentLocationAction(_ sender: UIButton) {
        if self.mapView.myLocation != nil {
            self.mapView.animate(toLocation: (self.mapView.myLocation?.coordinate)!);
        }
    }
    
    func getAddressFromLocation() {
        SVProgressHUD.show()
        
        let components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + "\(lat)" + "," + "\(long)" + "&sensor=false&key=AIzaSyD5WhSIjQ8wYCyvEc1F4jmiWTT3NWlfVLw&language=en")!
        
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                
                SVProgressHUD.dismiss()
                return
            }
            
            guard let json = try! JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                SVProgressHUD.dismiss()
                return
            }
            
            guard let results = json["results"] as? [[String: Any]],
                let status = json["status"] as? String,
                status == "OK" else {
                    print("no results")
                    print(String(describing: json))
                    SVProgressHUD.dismiss()
                    return
            }
            SVProgressHUD.dismiss()
            DispatchQueue.main.async {
                // now do something with the results, e.g. grab `formatted_address`:
                let strings = results.compactMap { $0["formatted_address"] as? String }
                print(strings)
                
            }
        }
        
        task.resume()
    }
    
    // MARK: - WebService Method
    
    func checkAddressDeliveryAPI() {
        
        let param : NSDictionary = ["user_id"               : self.userData.user_id,//
                                    "language"              : languageHelper.language,//
                                    "latitude"              : "\(self.lat)",//
                                    "longitude"             : "\(self.long)"]//
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: "availability_check", showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "DeliveryDetailsVC") as! DeliveryDetailsVC
                vc.latitude = self.lat
                vc.longitude = self.long
                vc.fullAddress = self.address
                vc.zipcode = self.postalCode
                vc.name = self.placeName
                self.navigationController?.show(vc, sender: nil)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
}

//MARK: -
extension SetLocationVC : GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress!)
        
        DispatchQueue.main.async {
            self.mapView.tag = 1
            self.mapView.animate(toLocation: place.coordinate);
            self.address = place.formattedAddress ?? ""
            self.placeName = place.name
            if place.addressComponents != nil {
                if (place.addressComponents?.count)! > 0 {
                    if place.addressComponents?.last?.type == "postal_code" {
                        self.postalCode = (place.addressComponents?.last?.name)!
                    }
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
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

extension SetLocationVC : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if self.mapView.tag != 1 {
            self.address = ""
            self.placeName = ""
            self.postalCode = ""
        }else {
            self.mapView.tag = 0
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.address = ""
        self.placeName = ""
        self.postalCode = ""
        self.mapView.animate(toLocation: coordinate)
    }
}

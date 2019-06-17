//
//  FullMapVC.swift
//  Sahel
//
//  Created by Octal on 29/01/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class FullMapVC: UIViewController {
    @IBOutlet weak var customView: UIView!
    
    var mapView = GMSMapView()
    
    var isProvider = Bool()
    var providerId = String()
    
    var originLat = Double()
    var originLong = Double()
    
    var destinationLat = Double()
    var destinationLong = Double()
    
    var originMarker = GMSMarker()
    
    var refreshCount = 2
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        self.loadMapView()
        self.title = languageHelper.LocalString(key: "trackOrder")
//        NotificationCenter.default.addObserver(self, selector: #selector(updateMapView(_:)), name: Notification.Name("updateFullMap"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("updateFullMap"), object: nil)
    }
    
    func setInitialValues() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.setTimerData), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @objc func setTimerData() {
        self.getDeliveryBoyLocationAPI()
    }
    
    func loadMapView() {
        DispatchQueue.main.async {
            
            let camera = GMSCameraPosition.camera(withLatitude: self.destinationLat, longitude: self.destinationLong,
                                                  zoom: 16)
            self.mapView = GMSMapView.map(withFrame: self.customView.bounds, camera: camera)
            self.mapView.isMyLocationEnabled = self.isProvider;
            self.mapView.camera = camera;
            self.mapView.settings.myLocationButton = false;
            self.mapView.tintColor = kThemeColor1;
            
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
            self.customView.addSubview(self.mapView)
            
            self.setDestinationMarkerView()
        }
    }
    
    func upDateMarkersOnMap() {
        self.showRoute()
        
        if !self.isProvider {
            self.setOriginMarkerView()
        }
        self.locationFitToBounds()
    }
    
    func locationFitToBounds() {
        DispatchQueue.main.async {
            let bounds = GMSCoordinateBounds.init(coordinate: CLLocationCoordinate2D.init(latitude: self.originLat, longitude: self.originLong), coordinate: CLLocationCoordinate2D.init(latitude: self.destinationLat, longitude: self.destinationLong))
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsets.init(top: 60, left: 20, bottom: 20, right: 20)))
        }
    }
    
    func setDestinationMarkerView() {
        // Set destination (Service Location) on Map
        let marker = GMSMarker.init(position: CLLocationCoordinate2D(latitude: self.destinationLat, longitude: self.destinationLong))
        let markerView = UIImageView()
        markerView.image = #imageLiteral(resourceName: "address")
        marker.iconView = markerView
        markerView.sizeToFit()
        marker.map = self.mapView
    }
    
    func setOriginMarkerView() {
        // Set origin (Service Location) on Map
        self.originMarker.map = nil
        self.originMarker = GMSMarker.init(position: CLLocationCoordinate2D(latitude: self.originLat, longitude: self.originLong))
        let markerView = UIImageView()
        markerView.image = #imageLiteral(resourceName: "rider")
        self.originMarker.iconView = markerView
        markerView.sizeToFit()
        self.originMarker.map = self.mapView
    }
    
    func showRoute()
    {
        let todoEndpoint: String =  "http://maps.googleapis.com/maps/api/directions/json?origin=\(self.originLat),\(self.originLong)&destination=\(self.destinationLat),\(self.destinationLong)&sensor=true&mode=driving&language=en"
        print(todoEndpoint)
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {    
                    let routes = json["routes"] as! NSArray
                    if routes.count != 0
                    {
                        let overViewPolyLines = routes[0] as! NSDictionary
//                        print(overViewPolyLines);
//                        let legs = overViewPolyLines["legs"] as! NSArray
//                        let steps = legs.value(forKey: "steps") as! NSArray
//                        print("steps",steps.count)
                        
                        let overview = overViewPolyLines["overview_polyline"] as! NSDictionary
                        let point =  overview.value(forKey: "points") as! String
                        
//                        let arrpoints = NSMutableArray()
                        DispatchQueue.main.async
                            {
                                
                                self.mapView.clear()
                                self.setDestinationMarkerView()
                                if !self.isProvider {
                                    self.setOriginMarkerView()
                                }
                                
                                let path = GMSMutablePath(fromEncodedPath: point)
                                let polyLine = GMSPolyline(path: path)
                                polyLine.strokeWidth = 5
                                polyLine.strokeColor = kThemeColor2
                                polyLine.map = self.mapView
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    // MARK: - WebService Method
    func getDeliveryBoyLocationAPI() {
        
        let param : NSDictionary = ["user_id"   : UserData.sharedInstance.user_id,
                                    "language"  : languageHelper.language,
                                    "delivery_boy_id" : self.providerId]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Delivery_Boy_Loc, showAlert: false , showHud: false, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let loc = result.value(forKey: "location") as! NSDictionary
                self.originLat = Double("\(loc.value(forKey: "latitude") ?? "0.00")") ?? 0.00
                self.originLong = Double("\(loc.value(forKey: "longitude") ?? "0.00")") ?? 0.00
                
                if self.view.tag == 0 {
                    self.upDateMarkersOnMap()
                    self.view.tag = 1
                }else {
                    self.view.tag = (self.view.tag >= 5) ? 0 : (self.view.tag + 1)
                    if !self.isProvider {
                        self.setOriginMarkerView()
                    }
                }
                
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
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

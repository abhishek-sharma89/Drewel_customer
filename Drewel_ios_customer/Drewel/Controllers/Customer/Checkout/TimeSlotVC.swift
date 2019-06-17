//
//  TimeSlotVC.swift
//  Drewel
//
//  Created by Octal on 11/06/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

@objc protocol SetDeliverySlotDelegate
{
    func setDeliverySlot(dateIndex : Int, slotIndex : Int, arrSlots : [String]);
}

class TimeSlotVC: BaseViewController {
    @IBOutlet weak var collectionDate: UICollectionView!
    @IBOutlet weak var tblSlots: UITableView!
    @IBOutlet weak var btnDeliveryNow: UIButton!
    
    var delegate : SetDeliverySlotDelegate?
    
    var arrDeliveryTypes = Array<String>() // Next Day Delivery Slots
    var arrDeliverySlots = Array<String>() // Today Delivery Slots
    var arrDeliveryCharges = Array<Double>()
    
    var selectedDate = 0
    var selectedSlot = -1
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
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "chooseDeliveryType")
        let price = ("\(self.arrDeliveryCharges[0])").replaceEnglishDigitsWithArabic
        self.btnDeliveryNow.setTitle((price + " \(languageHelper.LocalString(key: "OMR"))"), for: .normal)
        DispatchQueue.main.async {
            self.setupLayout(collection: self.collectionDate)
        }
    }
    
    fileprivate func setupLayout(collection : UICollectionView) {
        //setup collection view layout
        let cellWidth = self.view.frame.size.width/7;
        let cellheight : CGFloat = collection.frame.size.height;
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = collection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        collection.reloadData()
    }
    
    @IBAction func btnDeliverySlot(_ sender: UIButton) {
        self.delegate?.setDeliverySlot(dateIndex: 0, slotIndex: 0, arrSlots: arrDeliverySlots)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBookTimeSlotAction(_ sender: UIButton) {
        if selectedSlot >= 0 {
            let slotIndex = (selectedDate == 0) ? (selectedSlot) : selectedSlot
            let arrSlots = (selectedDate == 0) ? self.arrDeliverySlots : self.arrDeliveryTypes
            self.delegate?.setDeliverySlot(dateIndex: selectedDate, slotIndex: slotIndex, arrSlots: arrSlots)
            self.navigationController?.popViewController(animated: true)
        }else {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Select_Delivery_Type"), title: "")
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

// MARK: -
//UITableView Delegate & Datasource
extension TimeSlotVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedDate == 0 ? (self.arrDeliverySlots.count ) : self.arrDeliveryTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var slot = selectedDate == 0 ? self.arrDeliverySlots[indexPath.row] : self.arrDeliveryTypes[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa"
        var sDate = formatter.date(from: (slot.components(separatedBy: " - "))[0])
        var eDate = formatter.date(from: (slot.components(separatedBy: " - "))[1])
        if sDate == nil || eDate == nil {
            formatter.dateFormat = "HH:mm"
            sDate = formatter.date(from: (slot.components(separatedBy: " - "))[0]) ?? Date()
            eDate = formatter.date(from: (slot.components(separatedBy: " - "))[1]) ?? Date()
        }
        formatter.locale = languageHelper.getLocale()
        formatter.dateFormat = "hh:mm a"
        slot = formatter.string(from: sDate!) + " - " + formatter.string(from: eDate!)
        
        var price = (selectedDate == 0) ? (indexPath.row == 0 ? (String.init(format: "%.3f", arguments: [self.arrDeliveryCharges[0]])) : (String.init(format: "%.3f", arguments: [self.arrDeliveryCharges[1]])))  : (String.init(format: "%.3f", arguments: [self.arrDeliveryCharges[2]]))
        price = price.replaceEnglishDigitsWithArabic + " \(languageHelper.LocalString(key: "OMR"))"
        
        (cell.viewWithTag(1) as! UILabel).text = slot
        (cell.viewWithTag(2) as! UILabel).text = price
        (cell.viewWithTag(1) as! UILabel).textColor = selectedSlot == indexPath.row ? .red : .black
        (cell.viewWithTag(2) as! UILabel).textColor = selectedSlot == indexPath.row ? .red : .black
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dateIndex = selectedDate
        let slotIndex = (selectedDate == 0) ? (indexPath.row) : indexPath.row
        let arrSlots = (selectedDate == 0) ? self.arrDeliverySlots : self.arrDeliveryTypes
        
        let del_slot = arrSlots[slotIndex]
        var del_date = Date()
        
        if dateIndex != 0 {
            del_date = Calendar.current.date(byAdding: .day, value: dateIndex, to: Date())!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let strDeliveryDate = formatter.string(from: del_date)
        
        
        var strStartTime = ""
        var strEndTime = ""
        
        let arr = del_slot.components(separatedBy: " - ")
        if arr.count > 0
        {
            //                formatter.locale = Locale.init(identifier: "en_US_POSIX")
            formatter.dateFormat = "hh:mm aa"
            var sTime = formatter.date(from: arr[0])
            var eTime = formatter.date(from: arr[1])
            if sTime == nil || eTime == nil {
                formatter.dateFormat = "HH:mm"
                sTime = formatter.date(from: arr[0]) ?? Date()
                eTime = formatter.date(from: arr[1]) ?? Date()
            }
            formatter.dateFormat = "HH:mm:ss"
            strStartTime = formatter.string(from: sTime!)
            strEndTime = formatter.string(from: eTime!)
        }
        
        self.checkSlotAPI(date: strDeliveryDate, strtTime: strStartTime, endTime: strEndTime, slotIndex: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func checkSlotAPI(date : String, strtTime : String, endTime : String, slotIndex : IndexPath) {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "delivery_date"   : date,
                                    "delivery_start_time" : strtTime,
                                    "delivery_end_time" : endTime]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Slot_Check, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                let previousSlot = self.selectedSlot
                self.selectedSlot = slotIndex.row
                if previousSlot >= 0 {
                    self.tblSlots.reloadRows(at: [IndexPath(row: previousSlot, section: 0)], with: .fade)
                }
                
                self.tblSlots.reloadRows(at: [slotIndex], with: .fade)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
}



// MARK: -
// UICollectionView Delegate & Datasource
extension TimeSlotVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        var date = Date()
        date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: date)!
        let formatter = DateFormatter();
        formatter.dateFormat = "EEE";
        let dFormatter = DateFormatter();
        dFormatter.dateFormat = "dd\nMMM"
        dFormatter.locale = languageHelper.getLocale()
        formatter.locale = languageHelper.getLocale()
        (cell.viewWithTag(1) as! UILabel).text = indexPath.row == 0 ? languageHelper.LocalString(key: "today") : ((formatter.string(from: date).replaceArabicOfWeekdays) + "\n" + "\(dFormatter.string(from: date))" )
        print(formatter.string(from: date))
        cell.viewWithTag(2)?.isHidden = indexPath.row != self.selectedDate
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedSlot = -1
        
        let previousSlot = self.selectedDate
        self.selectedDate = indexPath.row
        collectionView.reloadItems(at: [IndexPath(item: previousSlot, section: 0)])
        collectionView.reloadItems(at: [indexPath])
        self.tblSlots.reloadData()
    }
}

extension String {
    public var replaceEnglishDigitsWithArabic: String {
        if !languageHelper.isArabic() {
            return self
        }
        var str = self
        let map = ["0": "٠",
                   "1": "١",
                   "2": "٢",
                   "3": "٣",
                   "4": "٤",
                   "5": "٥",
                   "6": "٦",
                   "7": "٧",
                   "8": "٨",
                   "9": "٩"]
        map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
        return str
    }
    
    public var replaceArabicOfWeekdays: String {
        if !languageHelper.isArabic() {
            return self
        }
        var str = self
        let sun = "أحد"
        let mon = "اثنين"
        let tue = "ثلاثاء"
        let wed = "أربعاء"
        let thu = "خميس"
        let fri = "جمعة"
        let sat = "سبت"
        
        let map = [sun          : "الاحد",
                   mon          : "الاثنين",
                   tue          : "الثلاثاء",
                   wed          : "الأربعاء",
                   thu          : "الخميس",
                   fri          : "الجمعة",
                   sat          : "السبت"]
        map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
        return str
    }
}

//
//  FilterProductVC.swift
//  Drewel
//
//  Created by Octal on 11/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func applyFilterWithData(fData : FilterData, isFilter : Bool) ;
}


class FilterProductVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblFilters: UITableView!
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    
    @IBOutlet weak var const_tblFilter_bottom: NSLayoutConstraint!
    @IBOutlet weak var const_tblFilter_height: NSLayoutConstraint!
    
    var delegate : FilterDelegate!
    
    var totalBrands = 0
    var brands = Array<BrandDetails>()
    var brandData = Array<String>()
    var minPrice = Double()
    var maxPrice = Double()
    var filterData = FilterData()
    var isFilter = Bool()
    
    // MARK: - VC Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
    } 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setInitialValues() {
        self.const_tblFilter_height.constant = 375
        self.rangeSlider.minValue = CGFloat.init(minPrice)
        self.rangeSlider.maxValue = CGFloat.init(maxPrice)
        self.rangeSlider.minDistance = 1.00
        
        self.rangeSlider.selectedMinValue = filterData.min_Price.isEmpty ? self.rangeSlider.minValue : CGFloat(Double(filterData.min_Price) ?? 0.00)
        
        self.rangeSlider.selectedMaxValue = filterData.max_Price.isEmpty ? self.rangeSlider.maxValue : CGFloat(Double(filterData.max_Price) ?? 0.00)
        self.brandData = self.filterData.brand_iDs.count > 0 ? self.filterData.brand_iDs : Array<String>()
        self.ratingView.rating = !(self.filterData.star_Rating.isEmpty) ? Double(self.filterData.star_Rating)! : 0.00
        
        if self.filterData.brand_iDs.count > 0 {
            totalBrands = self.brands.count
            self.tblFilters.reloadData()
            self.const_tblFilter_bottom.priority = UILayoutPriority(rawValue: 750)
            self.const_tblFilter_height.priority = UILayoutPriority(rawValue: 250)
        }
    }
    
    // MARK: - UIButton Actions
    @IBAction func btnSortAction(_ sender: UIButton) {
        let parentVC = (self.presentingViewController as! UINavigationController).topViewController as! ProductsInCategoryVC
        self.dismiss(animated: false) {
            let vc = kStoryboard_Customer.instantiateViewController(withIdentifier: "SortProductVC") as! SortProductVC
            vc.delegate = parentVC
            vc.selectedIndex =  Int(parentVC.sortingIndex) ?? -1
            vc.modalPresentationStyle = .overCurrentContext
            parentVC.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnDismissAction(_ sender: UIButton) {
        if sender.tag == 1 {
            self.delegate.applyFilterWithData(fData: FilterData(), isFilter: false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnShowHideBrandAction(_ sender: UIButton) {
        if totalBrands == 0 {
            
            totalBrands = self.brands.count
            self.tblFilters.reloadData()
            self.const_tblFilter_bottom.priority = UILayoutPriority(rawValue: 750)
            self.const_tblFilter_height.priority = UILayoutPriority(rawValue: 250)
            
            sender.tag = 1
        }else {
            totalBrands = 0
            self.tblFilters.reloadData()
            self.const_tblFilter_bottom.priority = UILayoutPriority(rawValue: 250)
            self.const_tblFilter_height.priority = UILayoutPriority(rawValue: 750)
            
            sender.tag = 0
        }
    }
    
    @IBAction func btnApplyAction(_ sender: UIButton) {
        var filterData = FilterData()
        filterData.brand_iDs = self.brandData
        filterData.min_Price = "\(rangeSlider.selectedMinValue)"
        filterData.max_Price = "\(rangeSlider.selectedMaxValue)"
        filterData.star_Rating = "\(ratingView.rating)"
        self.delegate.applyFilterWithData(fData: filterData, isFilter: true)
        self.dismiss(animated: true, completion: nil)
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
extension FilterProductVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalBrands
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFilter", for: indexPath)
        
        (cell.contentView.viewWithTag(2) as! UILabel).text = self.brands[indexPath.row].brand_name
        
        if self.brandData.contains(self.brands[indexPath.row].brand_id) {
            (cell.contentView.viewWithTag(1) as! UIImageView).image = #imageLiteral(resourceName: "radio_selected")
        }else {
            (cell.contentView.viewWithTag(1) as! UIImageView).image = #imageLiteral(resourceName: "radio_unselected")
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.brandData.contains(self.brands[indexPath.row].brand_id) {
            self.brandData.remove(at: self.brandData.index(of: self.brands[indexPath.row].brand_id)!)
        }else {
            self.brandData.append(self.brands[indexPath.row].brand_id)
        }
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
}

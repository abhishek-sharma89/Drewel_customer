//
//  ProductReviewVC.swift
//  Drewel
//
//  Created by Octal on 08/06/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import Kingfisher

class ProductReviewVC: UITableViewController {
    
    
    
    var userData = UserData.sharedInstance;
    var product = ProductsData()
    var arrReviews = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = languageHelper.LocalString(key: "reviews")
        self.getReviewListAPI()
        
        self.tableView.tableHeaderView?.frame.size.height = (product.review_submited == "1") ? 60 : 0
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIButton Actions
    
    @IBAction func btnSubmitReviewAction(_ sender: UIButton) {
        let cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProductReviewCell
        let cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! ProductReviewCell
        if (cell1.viewRating?.rating ?? 0.00) < 1.00 {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Add_Rating"), title: kAPPName)
        }else if cell2.txtReview.text.replacingOccurrences(of: " ", with: "").isEmpty || (cell2.txtReview.text == languageHelper.LocalString(key: "writeComment")) {
            HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "MSG_Add_Review"), title: kAPPName)
        }else {
            self.rateProductAPI(rating: cell1.viewRating.rating, review: cell2.txtReview.text)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ((product.review_submited == "1") ? 0 : 3) + self.arrReviews.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = (product.review_submited == "1") ? (indexPath.row + 3) : indexPath.row
        
        let identifier = index < 4 ? "Cell\(index)" : "Cell3"
//        identifier = (languageHelper.isArabic() && index == 0) ? "Cell00" : identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ProductReviewCell
        
        switch index {
        case 0:
//            cell.semanticContentAttribute =  .forceLeftToRight
            DispatchQueue.main.async {
                cell.viewRating.rating = 0
                cell.viewRating.layoutIfNeeded()
            }
            
            let imgUrl = product.ProductImage.count > 0 ? product.ProductImage[0] : product.product_image
            cell.imgProduct.kf.setImage(with:
                URL.init(string: imgUrl),
                                        placeholder: #imageLiteral(resourceName: "appicon.png"),
                                        options: KingfisherOptionsInfo.init(arrayLiteral: KingfisherOptionsInfoItem.cacheOriginalImage),
                                        progressBlock: nil,
                                        completionHandler: nil)
            
            cell.lblProductName.text = product.product_name
            var strCat = ""
            if product.category.count > 0 {
                strCat = product.category[0].category_name
                if product.category[0].subcategories.count > 0 {
                    strCat = strCat + " > " + product.category[0].subcategories[0].category_name
                }
            }
            cell.lblProductCategory.text = strCat
            break
        case 1:
            cell.txtReview.text = languageHelper.LocalString(key: "writeComment")
            break
        case 2:
            cell.btnSubmit.addTarget(self, action: #selector(btnSubmitReviewAction(_:)), for: .touchUpInside)
            
            break
        default:
            let reviewData = self.arrReviews[index - 3] as? NSDictionary ?? NSDictionary()
            cell.viewRating.isUserInteractionEnabled = false
            cell.lblReviewerName.text = "\(reviewData.value(forKey: "user_name") ?? "")"
            cell.lblReviews.text = "\(reviewData.value(forKey: "reviews") ?? "")"
            cell.viewRating.rating = Double("\(reviewData.value(forKey: "ratings") ?? "")") ?? 0.0
            cell.lblRating.text = String.init(format: "%.1f", cell.viewRating.rating)
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        DispatchQueue.main.async {
//            let cell1 = tableView.cellForRow(at: indexPath) as! ProductReviewCell
//            cell1.viewRating.rating = 0
//            cell1.viewRating.layoutIfNeeded()
//        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - WebService Method
    func rateProductAPI(rating : Double, review : String) {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": self.product.product_id,
                                    "reviews"   : review,
                                    "ratings"   : String.init(format: "%.0f", rating)]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_Add_Rating, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.navigationController?.popViewController(animated: true)
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }else {
                HelperClass.showPopupAlertController(sender: self, message: message, title: kAPPName)
            }
        }
    }
    
    func getReviewListAPI() {
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : languageHelper.language,
                                    "product_id": self.product.product_id]
        
        HelperClass.requestForAllApiWithBody(param: param, serverUrl: kURL_Product_Reviews, showAlert: true, showHud: true, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrReviews = result.value(forKey: "reviews") as? NSArray ?? NSArray()
                self.tableView.reloadData()
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

class ProductReviewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductCategory: UILabel!
    @IBOutlet weak var viewRateUs: CosmosView!
    @IBOutlet weak var txtReview: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var lblReviewerName: UILabel!
    @IBOutlet weak var viewRating: CosmosView!
    @IBOutlet weak var lblReviews: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var viewNewRate: UIView!
    
    var viewRate: CosmosView!
    
    // MARK: - UITextView Delegate
    var tap = UITapGestureRecognizer()
    let strTextDescribe = languageHelper.LocalString(key: "writeComment")
    func textViewDidBeginEditing(_ textView: UITextView) {
        tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(sender:)))
        self.superview?.superview?.addGestureRecognizer(tap)
        if self.txtReview.text == strTextDescribe {
            self.txtReview.text = "";
            self.txtReview.textColor = UIColor.black;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.superview?.superview?.removeGestureRecognizer(tap)
        if self.txtReview.text.isEmpty {
            self.txtReview.text = strTextDescribe;
            self.txtReview.textColor = UIColor.lightGray;
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.superview?.superview?.endEditing(true)
        if self.txtReview.text.isEmpty {
            self.txtReview.text = strTextDescribe;
            self.txtReview.textColor = UIColor.lightGray;
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
}

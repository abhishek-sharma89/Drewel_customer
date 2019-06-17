//
//  SearchCategoryVC.swift
//  Drewel
//
//  Created by Octal on 10/04/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit

class SearchCategoryVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSearchList: UITableView!
    var suggestion : String = ""
    var task : URLSessionDataTask?
    var getTask = DispatchWorkItem {
        
    }
    
    var arrSuggestions = Array<String>()
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
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        IQKeyboardManager.shared.enable = true
    }
    
    func setInitialValues() {
        self.title = languageHelper.LocalString(key: "search")
        self.txtSearch.becomeFirstResponder()
    }
    
    // MARK: - UITextfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if range.location >= 35 && string != "" {
            return false
        }
        self.arrSuggestions.removeAll()
        self.tblSearchList.reloadData()
//        print("Location: \(range.location)")
//        print("Length: \(range.length)")
//        print("String: \(string)")
        getTask.cancel()
        task?.cancel()
        if (range.location - range.length) >= 2  {
            // execute task in 2 seconds
            self.suggestion = (textField.text! + string)
            getTask = DispatchWorkItem {
                self.getSearchListAPI()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: getTask)
        }else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        return true;
    }
    
    // MARK: - WebService Method
    func getSearchListAPI() {
        var lang = self.txtSearch.textInputMode?.primaryLanguage ?? languageHelper.language!
        lang = String(lang.prefix(2))
        lang = (lang == "ar" || lang == "en") ? lang : languageHelper.language
        let param : NSDictionary = ["user_id"   : self.userData.user_id,
                                    "language"  : lang,
                                    "key"       : self.suggestion]
        
        task = HelperClass.requestApiWithBody(param: param, serverUrl: kURL_Search_Keyword, showAlert: false, showHud: false, andHeader: false, vc: self) { (result, message, status) in
            if status == "1" {
                self.arrSuggestions.removeAll()
                let dict = result.removeNullValueFromDict()
                let arrData = dict.object(forKey: "Suggestions") as? Array<String> ?? Array<String>()
                if arrData.count > 0 {
                    self.arrSuggestions.append(contentsOf: arrData)
                }
                self.tblSearchList.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueProductList" {
            let vc = segue.destination as! ProductListVC
            vc.isSeaching = true
            vc.searchKey = sender as! String
        }
    }
 
    
}

// MARK: -
//UITableView Delegate & Datasource
extension SearchCategoryVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = self.arrSuggestions[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "segueProductList", sender: self.arrSuggestions[indexPath.row])
    }
}


//
//  ShareProductVC.swift
//  Drewel
//
//  Created by Octal on 07/05/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import MessageUI
import FBSDKShareKit
import TwitterKit

class ShareProductVC: UIViewController, UIDocumentInteractionControllerDelegate {

    
    
    var image = UIImage()
    var imgUrl = String()
    var shareText = String()
    var productName = String()
    
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnDismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnShareOnWhatsappAction(_ sender: UIButton) {
        let composer = TWTRComposer()
        
        composer.setText(shareText)
        composer.setImage(image)
        
        // Called from a UIViewController
        composer.show(from: self) { result in
            if (result == TWTRComposerResult.cancelled) {
                print("Tweet composition cancelled")
                HelperClass.showPopupAlertController(sender: self, message: languageHelper.LocalString(key: "No_Twitter_App_MSG"), title: "")
            }
            else {
                print("Sending tweet!")
            }
        }
    }
    
    @IBAction func btnShareOnFacebookAction(_ sender: UIButton) {
        
        let content = FBSDKShareLinkContent()
        content.contentURL = URL.init(string: self.imgUrl)
//        content.quote = self.shareText
        
//        let photo = FBSDKSharePhoto()
//        photo.image = self.image
//        photo.isUserGenerated = false
//        let content = FBSDKSharePhotoContent()
//        content.photos = [photo]
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.shareSheet
        if !dialog.show() {
            dialog.mode = FBSDKShareDialogMode.browser
            dialog.show()
        }
//        FBSDKShareDialog.show(from: self, with: content, delegate: self)
    }
    
    @IBAction func btnShareOnMailAction(_ sender: UIButton) {
        let mc: MFMailComposeViewController? = MFMailComposeViewController()
        mc?.mailComposeDelegate = self
        mc?.setSubject("Drewel: \(productName)")
        mc?.addAttachmentData(UIImageJPEGRepresentation(self.image, 1)!, mimeType: "image/jpeg", fileName: "\(productName).jpeg")
        mc?.setMessageBody(shareText, isHTML: false)
        mc?.setToRecipients([""])
        
        if (mc != nil) {
            self.present(mc!, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnShareOnMessageAction(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = self.shareText
            controller.recipients = []
            controller.addAttachmentData(UIImageJPEGRepresentation(self.image, 1)!, typeIdentifier: "image/jpeg", filename: "\(productName).jpeg")
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
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

extension ShareProductVC : MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error?.localizedDescription ?? "error")")
        }
        self.dismiss(animated: false) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: false) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

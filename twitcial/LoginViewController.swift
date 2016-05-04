//
//  LoginViewController.swift
//  twitcial
//
//  Created by Tripathi, Roopesh on 12/04/16.
//  Copyright © 2016 Tripathi, Roopesh. All rights reserved.
//

import UIKit
import Social
import Accounts

class LoginViewController: UIViewController {
    
    @IBAction func signIn(sender: AnyObject) {
        
        self.myAlert("Login Alert", alertMessage: "Please goto iPhone setting and login to a Twitter account to tweet.", otherButtonTitle:"Settings", cancelButtonTitle: "Cancel")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        let twitteraccess = TwitterAuthenticationClass()
        let isTwitterAccountAvalabile = twitteraccess.checkAccess()
        print("isTwitterAccountAvalabile: ", isTwitterAccountAvalabile)
        
        if isTwitterAccountAvalabile{
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            let controller = ViewController(collectionViewLayout: layout)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func myAlert(alertTitle:String?, alertMessage:String, otherButtonTitle:String?, cancelButtonTitle:String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: otherButtonTitle, style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=TWITTER")!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
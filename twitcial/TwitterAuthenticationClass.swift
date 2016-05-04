//
//  TwitterAuthenticationClass.swift
//  twitcial
//
//  Created by Tripathi, Roopesh on 29/04/16.
//  Copyright © 2016 Tripathi, Roopesh. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterAuthenticationClass {

    func checkAccess() -> Bool{
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            return true;
        }
        
        else{
           return false
        }
        
    }
}

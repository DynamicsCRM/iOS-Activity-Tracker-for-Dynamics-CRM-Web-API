//
//  SettingsViewController.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import ADAL

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var endpointField: UITextField!
    
    convenience init() {
        self.init(nibName:"SettingsView", bundle:nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = "Settings";
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Save", style:.Plain, target:self, action:#selector(SettingsViewController.saveTapped(_:)));
        self.navigationItem.rightBarButtonItem!.tintColor = LIGHT_BLUE;
        
        label.textColor = DARK_GREY;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        let hostString = LocalStorage.localStorage.getHost();
        
        if (hostString != nil) {
            endpointField.text = hostString;
        }
    }
    
    func saveTapped(sender:AnyObject?) {
        
        let hostString = LocalStorage.localStorage.getHost();
        
        if (hostString == endpointField.text)
        {
            self.navigationController!.popViewControllerAnimated(true);
        }
        else
        {
            CRMClient.sharedClient.setNewEndpoint(endpointField.text!, completionBlock: { (success) -> Void in
                if (success)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.popViewControllerAnimated(true);
                    });
                }
                else
                {
                    let errorAlert = UIAlertController(title: "Error", message: "There was an error logging you in.  Check your endpoint URL and credentials.", preferredStyle:UIAlertControllerStyle.Alert);
                    errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil));
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(errorAlert, animated: true, completion: nil);
                    });
                }
            });
        }
    }
}

//
//  ObjectDetailsViewController.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

class ObjectDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var displayObject = CRMObject(),
        CellIdentifier = "ResultsCell";

    @IBOutlet weak var detailsView : UIView!;
    @IBOutlet weak var mainLabel : UILabel!;
    @IBOutlet weak var secondaryLabel : UILabel!;
    @IBOutlet weak var thirdLabel : UILabel!;
    @IBOutlet weak var addressLabel : UILabel!;
    @IBOutlet weak var phoneLabel : UILabel!;
    @IBOutlet weak var emailLabel : UILabel!;
    
    @IBOutlet weak var activitiesList : UITableView!;
    @IBOutlet weak var loadingIndicator : UIImageView!;

    convenience init() {
        self.init(nibName:"ObjectDetailsView", bundle:nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = "Contact";
        
        detailsView.backgroundColor = VERY_LIGHT_GREY;
        mainLabel.textColor = LIGHT_BLUE;
        secondaryLabel.textColor = MEDIUM_GREY;
        thirdLabel.textColor = MEDIUM_GREY;
        addressLabel.textColor = DARK_GREY;
        phoneLabel.textColor = DARK_GREY;
        emailLabel.textColor = DARK_GREY;
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil);
        
        activitiesList.tableFooterView = UIView(frame: CGRectZero);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        refreshObject();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (displayObject.recentActivities.count == 0)
        {
            animateSpinner();
        }
        
        CRMClient.sharedClient.getRecentActivities(self.displayObject as! CRMContact) { (success) -> Void in
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activitiesList.reloadData();
                    self.stopSpinner()
                });
            }
            else
            {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error retrieving the recent activities. Please ensure you are connected to the internet.", preferredStyle:UIAlertControllerStyle.Alert);
                errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil));
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(errorAlert, animated: true, completion: nil);
                });
            }
        };
        
        CRMClient.sharedClient.getContactDetails(self.displayObject as! CRMContact) { (success) -> Void in
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.refreshObject();
                });

                LocalStorage.localStorage.addToRecents(self.displayObject);
            }
            else
            {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error retrieving the contact's details. Please ensure you are connected to the internet.", preferredStyle:UIAlertControllerStyle.Alert);
                errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil));
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(errorAlert, animated: true, completion: nil);
                });
            }
        }
    }

    func refreshObject() {
        mainLabel.text = displayObject.detailLine1.dashesForEmpty();
        secondaryLabel.text = displayObject.detailLine2.dashesForEmpty();
        thirdLabel.text = displayObject.detailLine3.dashesForEmpty();
        addressLabel.text = displayObject.addressInfo.dashesForEmpty();
        phoneLabel.text = displayObject.mainPhone.dashesForEmpty();
        emailLabel.text = displayObject.mainEmail.dashesForEmpty();
        
        activitiesList.setContentOffset(CGPointZero, animated: false);
    }
    
    
    @IBAction func actionTapped(sender: AnyObject) {
        let activityView = NewActivityViewController();
        activityView.displayObject = displayObject;
        
        let activityButton = sender as! UIButton;
        
        switch (activityButton.tag)
        {
        case 10:
            activityView.activityType = "Check In";
            break;
        case 11:
            activityView.activityType = "Note";
            break;
        case 12:
            activityView.activityType = "Follow Up";
            break;
        case 13:
            activityView.activityType = "Phone Call";
            break;
        default:
            break;
        }
        
        self.navigationController!.pushViewController(activityView, animated: true);
    }
    
    @IBAction func addressTapped(sender: AnyObject) {
        if (displayObject.addressInfo.characters.count == 0)
        {
            return;
        }
        
        let addressString = addressLabel.text?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
            mapsURL = NSURL(string: String(format: "https://maps.apple.com?q=%@", arguments: [addressString!]));
        
        UIApplication.sharedApplication().openURL(mapsURL!);
    }
    
    @IBAction func phoneTapped(sender: AnyObject) {
        
        if (displayObject.mainPhone.characters.count == 0)
        {
            return;
        }
        
        let cleanedString = displayObject.mainPhone.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "0123456789-+()").invertedSet).joinWithSeparator(""),
            escapedPhoneNumber = cleanedString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()),
            phoneURL = NSURL(string: String(format: "tel:%@", arguments: [escapedPhoneNumber!]));
        
        UIApplication.sharedApplication().openURL(phoneURL!);
    }
    
    @IBAction func emailTapped(sender: AnyObject) {
        
        if (displayObject.mainEmail.characters.count == 0)
        {
            return;
        }
        let emailURL = NSURL(string: String(format: "mailto:%@", arguments: [displayObject.mainEmail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!]));
        
        UIApplication.sharedApplication().openURL(emailURL!);
    }
    
    // The spinner methods show a custom progress indicator
    func animateSpinner() {
        loadingIndicator.hidden = false;
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z");
        rotationAnimation.toValue = M_PI;
        rotationAnimation.duration = 0.5;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = HUGE;
        
        loadingIndicator.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation");
    }
    
    func stopSpinner() {
        loadingIndicator.hidden = true;
        loadingIndicator.layer.removeAnimationForKey("rotationAnimation");
    }
    
    // MARK: UITableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayObject.recentActivities.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM d, yyyy";
        
        var retVal = tableView.dequeueReusableCellWithIdentifier(CellIdentifier);
        if (retVal == nil)
        {
            retVal = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier);
        }
        
        let currActivity = displayObject.recentActivities[indexPath.row];
        
        retVal!.textLabel!.text = currActivity.activitySubject;
        retVal!.textLabel!.textColor = DARK_PURPLE;
        
        retVal!.detailTextLabel!.text = dateFormatter.stringFromDate(currActivity.activityDate);
        retVal!.detailTextLabel!.textColor = MEDIUM_GREY;
        
        retVal!.imageView!.image = currActivity.activityImage();
        
        return retVal!;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "RECENTLY COMPLETED ACTIVITIES";
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26.0;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.delegate!.tableView!(tableView, heightForHeaderInSection: section)));
        header.backgroundColor = UIColor.whiteColor();
        
        let textLabel = UILabel();
        textLabel.text = tableView.dataSource?.tableView!(tableView, titleForHeaderInSection: section);
        textLabel.textColor = DARK_GREY;
        textLabel.font = textLabel.font.fontWithSize(14.0);
        textLabel.sizeToFit();
        textLabel.frame = CGRectMake(20,
            (header.frame.size.height  - textLabel.frame.size.height),
            textLabel.frame.size.width,
            textLabel.frame.size.height);
        header.addSubview(textLabel);
        
        return header;
    }
}

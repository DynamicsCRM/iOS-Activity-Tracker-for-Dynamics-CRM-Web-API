//
//  NewActivityViewController.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

class NewActivityViewController: UIViewController, UITextViewDelegate {
    var displayObject = CRMObject();
    var activityType = String();
    
    @IBOutlet weak var loadingIndicator : UIImageView!;
    @IBOutlet weak var detailsView : UIView!;
    @IBOutlet weak var mainLabel : UILabel!;
    @IBOutlet weak var secondaryLabel : UILabel!;
    @IBOutlet weak var thirdLabel : UILabel!;
    
    @IBOutlet weak var scroller : UIScrollView!;
    @IBOutlet weak var scrollerBackground : UIView!;
    
    @IBOutlet weak var subjectField : UITextField!;
    @IBOutlet weak var dateField : UITextField!;
    @IBOutlet weak var notesView : UITextView!;
    
    @IBOutlet var fieldLabels : [UILabel]!;
    
    var activityDate = NSDate();
    var dateFormatter = NSDateFormatter();
    
    convenience init() {
        self.init(nibName:"NewActivityView", bundle:nil);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        for label in fieldLabels {
            label.textColor = DARK_GREY;
        }
        
        detailsView.backgroundColor = VERY_LIGHT_GREY;
        scrollerBackground.backgroundColor = LINE_COLOR;
        
        mainLabel.text = displayObject.detailLine1;
        mainLabel.textColor = LIGHT_BLUE;
        
        secondaryLabel.text = displayObject.detailLine2;
        secondaryLabel.textColor = MEDIUM_GREY;
        
        thirdLabel.text = displayObject.detailLine3;
        thirdLabel.textColor = MEDIUM_GREY;
        
        activityDate = NSDate();
        dateFormatter.dateFormat = "M/d/yyyy";
        
        dateField.text = dateFormatter.stringFromDate(activityDate);
        
        let datePicker = UIDatePicker(frame: CGRectZero);
        datePicker.date = activityDate;
        datePicker.datePickerMode = .Date;
        datePicker.addTarget(self, action:#selector(NewActivityViewController.dateChanged(_:)), forControlEvents:.ValueChanged);
        
        dateField.inputView = datePicker;
        
        self.title = self.activityType;
        
        subjectField.text = String(format:"%@ with %@ on %@", self.activityType, self.displayObject.resultLine1, dateFormatter.stringFromDate(activityDate));
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style:.Plain, target:self, action:#selector(NewActivityViewController.submitTapped(_:)));
        self.navigationItem.rightBarButtonItem!.tintColor = LIGHT_BLUE;
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewActivityViewController.keyboardShow(_:)), name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewActivityViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        
        NSNotificationCenter.defaultCenter().removeObserver(self);
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
    
    func dateChanged(sender:AnyObject) {
        
        let picker = sender as! UIDatePicker;
        if (subjectField.text == String(format:"%@ with %@ on %@", self.activityType, self.displayObject.resultLine1, dateFormatter.stringFromDate(activityDate)))
        {
            activityDate = picker.date;
            dateField.text = dateFormatter.stringFromDate(activityDate);
            subjectField.text = String(format:"%@ with %@ on %@", self.activityType, self.displayObject.resultLine1, dateFormatter.stringFromDate(activityDate));
        }
        else
        {
            activityDate = picker.date;
            dateField.text = dateFormatter.stringFromDate(activityDate);
        }
    }
    
    func submitTapped(sender:AnyObject) {
        if (subjectField.text?.characters.count == 0)
        {
            let errorAlert = UIAlertController(title: "Subject Required", message: "A subject is required.", preferredStyle:.Alert);
            errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil));
            self.presentViewController(errorAlert, animated: true, completion: nil);
            return;
        }
        self.navigationItem.rightBarButtonItem!.enabled = false;
        self.navigationItem.setHidesBackButton(true, animated: true);
        self.view.endEditing(true);
        
        let newActivity = CRMActivity();
        newActivity.activityType = "task";
        newActivity.activityDate = activityDate;
        newActivity.activitySubject = subjectField.text!;
        newActivity.activityNotes = notesView.text;
        
        self.displayObject.recentActivities.insert(newActivity, atIndex: 0);
        
        animateSpinner();
        
        CRMClient.sharedClient.create(newActivity, relatedTo: self.displayObject as! CRMContact) { (success) -> Void in
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController!.popViewControllerAnimated(true);
                    self.stopSpinner();
                });
            }
            else
            {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error creating the new activity. Please ensure you are connected to the internet.", preferredStyle:UIAlertControllerStyle.Alert);
                errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil));
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(errorAlert, animated: true, completion: nil);
                    self.navigationItem.rightBarButtonItem!.enabled = true;
                    self.navigationItem.setHidesBackButton(false, animated: true);
                    self.stopSpinner();
                });
            }
        };
    }

    // MARK: Keyboard Notifications
    func keyboardShow(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue(),
                contentSize = CGSizeMake(scroller.frame.size.width, scroller.frame.size.height + keyboardFrame.size.height);
            scroller.contentSize = contentSize;
            scroller.scrollEnabled = true;
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        scroller.scrollEnabled = false;
        scroller.setContentOffset(CGPointZero, animated:true);
    }

    // MARK: UITextView Delegate
    func textViewDidBeginEditing(textView: UITextView) {
        
        let scrollPoint = textView.superview!.frame.origin;
        scroller.setContentOffset(scrollPoint, animated:true);
    }
}

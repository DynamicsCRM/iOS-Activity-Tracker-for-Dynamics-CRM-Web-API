//
//  CRMActivity.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import UIKit

class CRMActivity: CRMObject {
    
    var activityType = "";
    var activitySubject = "";
    var activityDate = NSDate();
    var activityNotes = "";
    
    // Determine which image to show in recent list
    func activityImage() -> UIImage {
        if (self.activityType == "task")
        {
            return UIImage(named:"icon-activity-check")!;
        }
        else if (self.activityType == "phonecall")
        {
            return UIImage(named:"icon-activity-phone")!;
        }
        else if (self.activityType == "appointment")
        {
            return UIImage(named:"icon-activity-appt")!;
        }
        return UIImage(named:"icon-activity-generic")!;
    }
    
    // This determines which fields are returned from the OData endpoint
    class override func selectString(includeRelated:Bool) -> String {
        return "activityid,subject,actualend,description,activitytypecode,statecode,statuscode";
    }
    
    // Update the record with the results from the OData endpoint
    func updateFromDict(dict:Dictionary<String,AnyObject>) {
        
        if let value = dict["activityid"] {
            if !(value is NSNull) {
                self.crmID = value as! String;
            }
        }
        if let value = dict["subject"] {
            if !(value is NSNull) {
                self.activitySubject = value as! String;
            }
        }
        if let value = dict["actualend"] {
            if !(value is NSNull) {
                let dateFormatter = NSDateFormatter();
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
                
                self.activityDate = dateFormatter.dateFromString(value as! String)!;
            }
        }
        if let value = dict["description"] {
            if !(value is NSNull) {
                self.activityNotes = value as! String;
            }
        }
        if let value = dict["activitytypecode"] {
            if !(value is NSNull) {
                self.activityType = value as! String;
            }
        }
    }
    
    // Return a dictionary to send to the OData endpoint in order to create a new activity record
    func createDictionary(relatedTo: CRMObject) -> Dictionary<String,AnyObject> {
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
        
        var retVal = Dictionary<String,AnyObject>();
        retVal["subject"] = self.activitySubject;
        retVal["actualend"] = dateFormatter.stringFromDate(self.activityDate);
        retVal["description"] = self.activityNotes;
        retVal["regardingobjectid_contact_task@odata.bind"] = String(format:"/contacts(%@)",relatedTo.crmID);

        return retVal;
    }
    
    func markAsCompleteDictionary () -> Dictionary<String,AnyObject>
    {
        return ["value":1];
    }
}
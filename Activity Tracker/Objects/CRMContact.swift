//
//  CRMContact.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

class CRMContact: CRMObject {
    
    var fullName = "";
    var jobTitle = "";
    var email = "";
    var phoneNumber = "";
    var accountName = "";
    
    var addressLine1 = "";
    var addressCity = "";
    var addressState = "";
    var addressZip = "";

    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder);
        aCoder.encodeObject(fullName, forKey: "fullName");
        aCoder.encodeObject(jobTitle, forKey: "jobTitle");
        aCoder.encodeObject(email, forKey: "email");
        aCoder.encodeObject(phoneNumber, forKey: "phoneNumber");
        aCoder.encodeObject(accountName, forKey: "accountName");
        aCoder.encodeObject(addressLine1, forKey: "addressLine1");
        aCoder.encodeObject(addressCity, forKey: "addressCity");
        aCoder.encodeObject(addressState, forKey: "addressState");
        aCoder.encodeObject(addressZip, forKey: "addressZip");
    }
    
    override init() {
        super.init();
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.crmID = aDecoder.decodeObjectForKey("crmID") as! String;
        self.fullName = aDecoder.decodeObjectForKey("fullName") as! String;
        self.jobTitle = aDecoder.decodeObjectForKey("jobTitle") as! String;
        self.email = aDecoder.decodeObjectForKey("email") as! String;
        self.phoneNumber = aDecoder.decodeObjectForKey("phoneNumber") as! String;
        self.accountName = aDecoder.decodeObjectForKey("accountName") as! String;
        self.addressLine1 = aDecoder.decodeObjectForKey("addressLine1") as! String;
        self.addressCity = aDecoder.decodeObjectForKey("addressCity") as! String;
        self.addressState = aDecoder.decodeObjectForKey("addressState") as! String;
        self.addressZip = aDecoder.decodeObjectForKey("addressZip") as! String;

    }
    
    override func supportsSecureEncoding() -> Bool {
        return true;
    }
    
    override var resultLine1 : String {
        return self.fullName;
    }
    
    override var resultLine2 : String {
        var retVal = "";

        if (self.accountName.characters.count > 0)
        {
            retVal.appendContentsOf(self.accountName);
        }

        if (self.jobTitle.characters.count > 0)
        {
            if (retVal.characters.count != 0)
            {
                retVal.appendContentsOf(" - ");
            }
            
            retVal.appendContentsOf(self.jobTitle);
        }
        return retVal;
    }
    
    override var detailLine1 : String {
        return self.fullName;
    }
    
    override var detailLine2: String {
        return self.jobTitle;
    }
    
    override var detailLine3: String {
        return self.accountName;
    }
    
    override var addressInfo: String {
        if (self.addressLine1.characters.count == 0 && self.addressCity.characters.count == 0 && self.addressState.characters.count == 0 && self.addressZip.characters.count == 0)
        {
            return "";
        }
        return String(format: "%@\n%@ %@ %@", self.addressLine1.dashesForEmpty(),self.addressCity.dashesForEmpty(),self.addressState.dashesForEmpty(),self.addressZip.dashesForEmpty());
    }
    
    override var mainPhone: String {
        return self.phoneNumber;
    }
    
    override var mainEmail: String {
        return self.email;
    }

    // This determines which fields are returned from the OData endpoint
    class override func selectString(includeRelated:Bool) -> String {
        var retVal =  "contactid,fullname,address1_line1,address1_city,address1_stateorprovince,address1_postalcode,emailaddress1,jobtitle,telephone1";
        if (includeRelated) {
            retVal = retVal.stringByAppendingString("&$expand=parentcustomerid_account($select=name)");
        }
        return retVal;
    }
    
    func parseActivities(activities:[[String:AnyObject]]) {
        self.recentActivities = [];
        for objectDict in activities {
            self.addActivity(objectDict);
        }
        self.recentActivities = self.recentActivities.sort({$0.activityDate.compare($1.activityDate) == .OrderedDescending});
    }
    
    func addActivity(objectDict:Dictionary<String,AnyObject>) -> CRMActivity{
        let result = CRMActivity();
        result.updateFromDict(objectDict);
        self.recentActivities.append(result);
        return result;
    }

    // I dont think we actually need this any more, the web api returns the actual objects as contacts
//    class func parseResults(results:[AnyObject]) -> [CRMContact] {
//        
//        var retVal = [CRMContact]();
//    
//        for (var i = 0; i < results.count; i++)
//        {
//            var objectDict = results[i] as [String:AnyObject];
//            let result = CRMContact();
//            let attributes = objectDict["Attributes"] as! [AnyObject];
//            
//            for attributeDict in attributes {
//                result.updateFromSOAPDict(attributeDict as! [String:AnyObject]);
//            }
//            retVal.append(result);
//        }
//        
//        return retVal;
//    }
    
    // Update the record with the results from the OData endpoint
    func updateFromDict(dict:[String:AnyObject]) {
                
        if let value = dict["contactid"] {
            if !(value is NSNull) {
                self.crmID = value as! String;
            }
        }
        if let value = dict["fullname"] {
            if !(value is NSNull) {
                self.fullName = value as! String;
            }
        }
        if let value = dict["jobtitle"] {
            if !(value is NSNull) {
                self.jobTitle = value as! String;
            }
        }
        if let value = dict["emailaddress1"] {
            if !(value is NSNull) {
                self.email = value as! String;
            }
        }
        if let value = dict["telephone1"] {
            if !(value is NSNull) {
                self.phoneNumber = value as! String;
            }
        }
        if let value = dict["address1_line1"] {
            if !(value is NSNull) {
                self.addressLine1 = value as! String;
            }
        }
        if let value = dict["address1_city"] {
            if !(value is NSNull) {
                self.addressCity = value as! String;
            }
        }
        if let value = dict["address1_stateorprovince"] {
            if !(value is NSNull) {
                self.addressState = value as! String;
            }
        }
        if let value = dict["address1_postalcode"] {
            if !(value is NSNull) {
                self.addressZip = value as! String;
            }
        }
        if let value = dict["parentcustomerid_account"] {
            if !(value is NSNull) {
                if let val = value["name"] {
                    if !(val is NSNull) {
                        self.accountName = val as! String;
                    }
                }
            }
        }
    }
    
}
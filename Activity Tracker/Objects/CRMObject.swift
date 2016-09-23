//
//  CRMObject.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import UIKit

class CRMObject: NSObject, NSCoding  {
    
    var crmID = "";
    var recentActivities = [CRMActivity]();
    
    var resultLine1 : String { return ""; };
    var resultLine2 : String { return ""; };
    
    var detailLine1 : String { return ""; };
    var detailLine2 : String { return ""; };
    var detailLine3 : String { return ""; };
    
    var addressInfo : String { return ""; };
    var mainPhone : String { return ""; };
    var mainEmail : String { return ""; };
    
    override init()
    {
        recentActivities = [];
        super.init();
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init();
        self.crmID = aDecoder.decodeObjectForKey("crmID") as! String;
    }
    
    func encodeWithCoder(aCoder:NSCoder) {
        aCoder.encodeObject(crmID, forKey: "crmID");
    }
    
    func supportsSecureEncoding() -> Bool {
        return true;
    }
    
    class func selectString(includeRelated:Bool) -> String {
        return "";
    }
}
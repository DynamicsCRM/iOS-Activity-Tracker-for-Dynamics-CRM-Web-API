//
//  LocalStorage.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation

var HOST_KEY: String { get {return "CRMHost";}}
var RECENTS_KEY: String { get { return "RecentRecords";}}

class LocalStorage {
    
    static let localStorage = LocalStorage();
    
    func getHost() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults();
        return defaults.stringForKey(HOST_KEY);
    }
    
    func saveHost(host: String) {
        let defaults = NSUserDefaults.standardUserDefaults(),
            currHost = defaults.stringForKey(HOST_KEY);
        
        if (currHost != nil && currHost != host)
        {
            defaults.removeObjectForKey(RECENTS_KEY);
        }
        
        defaults.setObject(host, forKey: HOST_KEY);
        defaults.synchronize();
    }
    
    // Recent records need to use an Archiver and Unarchiver to properly store the objects
    func getRecents() -> [AnyObject] {
        var results = NSMutableOrderedSet();

        let defaults = NSUserDefaults.standardUserDefaults(),
            recentData = defaults.objectForKey(RECENTS_KEY) as? NSData;

        if (recentData != nil)
        {
            let recents = NSKeyedUnarchiver.unarchiveObjectWithData(recentData!);
            if (recents != nil) {
                results = recents as! NSMutableOrderedSet!;
            }
        }
        
        return results.array;
    }
    
    func addToRecents(recent:CRMObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults(),
            recentData = defaults.objectForKey(RECENTS_KEY) as? NSData;

        var recents = NSMutableOrderedSet?();
        if (recentData != nil)
        {
            recents = NSKeyedUnarchiver.unarchiveObjectWithData(recentData!) as? NSMutableOrderedSet;
            let filtered = recents!.filter() {$0.crmID == recent.crmID;};
            recents!.removeObjectsInArray(filtered);
        }
        
        if (recents == nil) {
            recents = NSMutableOrderedSet(object: recent);
        }
        else {
            recents!.insertObject(recent, atIndex: 0);
        }
        
        if (recents?.count > 10)
        {
            recents?.removeObjectAtIndex(10);
        }
        
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(recents!), forKey: RECENTS_KEY);
        defaults.synchronize();
    }

}
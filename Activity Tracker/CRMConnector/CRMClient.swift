//
//  CRMClient.swift
//  Activity Tracker
//
//  Created by Kyle Gerstner on 4/20/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import ADAL

//TODO: Update the clientID and redirectUri after you register a new app with AD
var CLIENT_ID: String { get {return "1dc3cd16-85f4-449e-9145-98c996ea6a85";}}
var REDIRECT_URI: String { get { return "http://crm.codesamples/";}}

class CRMClient : NSObject
{
    static let sharedClient = CRMClient();
    
    var accessToken:String = "";
    var endpointURL:NSURL = NSURL();
    var authority:String?;
    var tokenExpirationDate:NSDate?;
    
    private func oDataRequestForEndpoint(endpoint:String) -> NSMutableURLRequest
    {
        let path = String(format: "/api/data/v8.0/%@", arguments: [endpoint]);
        
        let retVal = NSMutableURLRequest(URL: NSURL(string: path.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!, relativeToURL: self.endpointURL)!);
        retVal.setValue(String(format: "Bearer %@", arguments: [self.accessToken]), forHTTPHeaderField: "Authorization");
        retVal.setValue("application/json", forHTTPHeaderField: "Accept");
        retVal.setValue("4.0", forHTTPHeaderField: "OData-MaxVersion");
        retVal.setValue("4.0", forHTTPHeaderField: "OData-Version");
        
        return retVal;
    }
    
    private func oDataGetRequestForNSURLResponse(response:NSURLResponse?) -> NSURLRequest? {
        if (response == nil) {
            return nil;
        }
        
        let httpRepsonse = response as! NSHTTPURLResponse,
            headers = httpRepsonse.allHeaderFields,
            path = headers["OData-EntityId"] as! String,
            url =  NSURL(string: path.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!, relativeToURL: endpointURL),
            retVal = NSMutableURLRequest(URL: url!);
        
        retVal.HTTPMethod = "GET";
        retVal.setValue(String(format: "Bearer %@", arguments: [self.accessToken]), forHTTPHeaderField: "Authorization");
        retVal.setValue("application/json", forHTTPHeaderField: "Accept");
        retVal.setValue("4.0", forHTTPHeaderField: "OData-MaxVersion");
        retVal.setValue("4.0", forHTTPHeaderField: "OData-Version");
        
        return retVal;
    }
    
    private func oDataGetRequestForEndpoint(endpoint:String) -> NSURLRequest
    {
        let retVal = self.oDataRequestForEndpoint(endpoint);

        retVal.HTTPMethod = "GET";
        
        return retVal;
    }
    
    private func oDataPostRequestForEndpoint(endpoint:String, body:NSData) -> NSURLRequest
    {
        let retVal = self.oDataRequestForEndpoint(endpoint);
        
        retVal.HTTPMethod = "POST";
        retVal.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type");
        retVal.HTTPBody = body;
        
        return retVal;
    }
    
    private func oDataPutRequestForEndpoint(endpoint:String, body:NSData) -> NSURLRequest
    {
        let retVal = self.oDataRequestForEndpoint(endpoint);
        
        retVal.HTTPMethod = "PUT";
        retVal.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type");
        retVal.HTTPBody = body;
        
        return retVal;
    }
    
    private func refreshAuthToken(completionBlock:(success:Bool) -> Void)
    {
        if let tokenExpirationDate = self.tokenExpirationDate
        {
            if (NSDate().compare(tokenExpirationDate) == NSComparisonResult.OrderedAscending)
            {
                completionBlock(success: true);
                return;
            }
        }
        
        if let authority = self.authority
        {
            let authContext = ADAuthenticationContext (authority: authority, validateAuthority: false, error: nil);
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                authContext.acquireTokenWithResource(self.endpointURL.absoluteString, clientId: CLIENT_ID, redirectUri: NSURL(string: REDIRECT_URI), completionBlock: { (result: ADAuthenticationResult!) -> Void in
                    if (result.status != AD_SUCCEEDED)
                    {
                        completionBlock(success: false);
                        return;
                    }
                    
                    self.accessToken = result.accessToken;
                    self.tokenExpirationDate = result.tokenCacheItem.expiresOn;
                    
                    completionBlock(success: true);
                });
                
            });
        }
        else
        {
            completionBlock(success: false);
        }

    }
    
    func setNewEndpoint(endpoint:String, completionBlock:(success:Bool) -> Void)
    {
        self.endpointURL = NSURL(string: endpoint)!;
        
        let path = "/api/data/v8.0/";
        
        let authorityRequest = NSMutableURLRequest(URL: NSURL(string: path, relativeToURL: self.endpointURL)!);
        authorityRequest.HTTPMethod = "GET";
        authorityRequest.setValue("Bearer", forHTTPHeaderField: "Authorization");
        authorityRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept");
        
        let authorityTask = NSURLSession.sharedSession().dataTaskWithRequest(authorityRequest) { (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if (response == nil) {
                completionBlock(success: false);
                return;
            }
            let httpResponse = response as! NSHTTPURLResponse;
            var authenticationHeader:NSString = (httpResponse.allHeaderFields as NSDictionary).objectForKey("WWW-Authenticate") as! NSString;
            
            let commaRange = authenticationHeader.rangeOfString(",");
            if (commaRange.location != NSNotFound)
            {
                authenticationHeader = authenticationHeader.substringToIndex(commaRange.location);
            }
            
            let equalRange = authenticationHeader.rangeOfString("=");
            if (equalRange.location != NSNotFound)
            {
                authenticationHeader = NSString(format: "%@\"%@\"", authenticationHeader.substringToIndex(equalRange.location+1), authenticationHeader.substringFromIndex(equalRange.location+1));
            }
            
            //var adError:ADAuthenticationError?;
            let authParams = ADAuthenticationParameters(fromResponseAuthenticateHeader: authenticationHeader as String, error: nil);
            
            self.authority = authParams.authority;
            
            let authContext = ADAuthenticationContext (authority: authParams.authority, validateAuthority: false, error: nil);
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                authContext.acquireTokenWithResource(endpoint, clientId: CLIENT_ID, redirectUri: NSURL(string: REDIRECT_URI), completionBlock: { (result: ADAuthenticationResult!) -> Void in
                    if (result.status != AD_SUCCEEDED)
                    {
                        completionBlock(success: false);
                        return;
                    }
                    
                    self.accessToken = result.accessToken;
                    self.tokenExpirationDate = result.tokenCacheItem.expiresOn;
                    
                    LocalStorage.localStorage.saveHost(endpoint);
                    
                    completionBlock(success: true);
                });
            
            });

        }
        authorityTask.resume();
    }
    
    func searchFor(searchString: String, completionBlock:(results:NSArray?, error:NSError? ) -> Void)
    {
        
        self.refreshAuthToken { (success:Bool) -> Void in
            if (success)
            {
                let path = "contacts";
                let selectString = CRMContact.selectString(false);
                let search = String(format: "$filter=contains(fullname, '%@')", arguments: [searchString])
                let fullPath = String(format: "%@?$select=%@&%@", arguments: [path, selectString, search]);
                
                let fetchRequest = self.oDataGetRequestForEndpoint(fullPath);
                let fetchTask = NSURLSession.sharedSession().dataTaskWithRequest(fetchRequest) { (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    if (error == nil)
                    {
                        do
                        {
                            let resultDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary;
                            let results:NSArray = resultDict.objectForKey("value") as! NSArray;
                            
                            let retVal:NSMutableArray = NSMutableArray();
                            for result in results
                            {
                                let contact = CRMContact();
                                contact.updateFromDict(result as! [String : AnyObject]);
                                retVal.addObject(contact);
                            }
                            
                            completionBlock(results: retVal, error: nil);
                        }
                        catch
                        {
                            completionBlock(results: nil, error: nil);
                            return;
                        }
                    }
                    else
                    {
                        completionBlock(results: nil, error: error);
                    }
                }
                
                fetchTask.resume();
            }
            else
            {
                completionBlock(results: nil, error: NSError(domain: "Could not refresh authentication token", code: 0, userInfo: nil));
            }
        }
    }
    
    func getContactDetails(contact: CRMContact, completionBlock:(success:Bool) -> Void)
    {
        self.refreshAuthToken { (success:Bool) -> Void in
            if (success)
            {
                let path = String(format: "contacts(%@)", arguments: [contact.crmID]);
                let selectString = CRMContact.selectString(true);
                let fullPath = String(format: "%@?$select=%@", arguments: [path, selectString]);
                
                let fetchRequest = self.oDataGetRequestForEndpoint(fullPath);
                let fetchTask = NSURLSession.sharedSession().dataTaskWithRequest(fetchRequest) { (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    if (error == nil)
                    {
                        do
                        {
                            let resultDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary;
                            contact.updateFromDict(resultDict as! [String : AnyObject]);
                            completionBlock (success: true);
                        }
                        catch
                        {
                            completionBlock(success: false);
                            return;
                        }
                    }
                    else {
                        completionBlock(success: false);
                    }
                }
                
                fetchTask.resume();
            }
            else
            {
                completionBlock(success: false);
            }
        }
    }
    
    func getRecentActivities(contact: CRMContact, completionBlock:(success:Bool) -> Void)
    {
        self.refreshAuthToken { (success:Bool) -> Void in
            if (success)
            {
                let path = String(format: "/contacts(%@)/Contact_ActivityPointers", arguments: [contact.crmID]),
                selectString = CRMActivity.selectString(false),
                fullPath = String(format: "%@?$select=%@&$filter=actualend ne null&$top=5", arguments: [path, selectString]),
                fetchRequest = self.oDataGetRequestForEndpoint(fullPath);
                
                contact.recentActivities = [];
                
                let fetchTask = NSURLSession.sharedSession().dataTaskWithRequest(fetchRequest) { (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    if (error == nil)
                    {
                        do
                        {
                            let resultDict:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary;
                            contact.parseActivities(resultDict["value"] as! [[String : AnyObject]]);
                            completionBlock (success: true);
                        }
                        catch
                        {
                            completionBlock(success: false);
                            return;
                        }
                    }
                    else {
                        completionBlock(success: false);
                    }
                }
                
                fetchTask.resume();
            }
            else
            {
                completionBlock(success: false);
            }
        }
    }
    
    func create(object: CRMActivity, relatedTo: CRMContact, completionBlock:(success:Bool) -> Void)
    {
        self.refreshAuthToken { (success:Bool) -> Void in
            if (success)
            {
                let path = String(format: "tasks");
                
                var bodyData:NSData? = nil;
                do
                {
                    bodyData = try NSJSONSerialization.dataWithJSONObject(object.createDictionary(relatedTo), options: NSJSONWritingOptions.PrettyPrinted);
                }
                catch
                {
                    completionBlock(success: false);
                }
                
                let createRequest = self.oDataPostRequestForEndpoint(path, body: bodyData!);
                let createTask = NSURLSession.sharedSession().dataTaskWithRequest(createRequest) {  (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    
                    if (error == nil)
                    {
                        let fetchRequest = self.oDataGetRequestForNSURLResponse(response);
                        let fetchTask = NSURLSession.sharedSession().dataTaskWithRequest(fetchRequest!) { (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                            if (error == nil)
                            {
                                do
                                {
                                    let resultDict:[String:AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject];
                                    let newobject = relatedTo.addActivity(resultDict);
                                    relatedTo.recentActivities = relatedTo.recentActivities.sort({$0.activityDate.compare($1.activityDate) == .OrderedDescending});
                                    self.complete(newobject, completionBlock: completionBlock);
                                }
                                catch
                                {
                                    completionBlock(success: false);
                                    return;
                                }
                            }
                        }
                        fetchTask.resume();
                    }
                    else {
                        completionBlock(success: false);
                    }
                }
                createTask.resume();

            }
            else
            {
                completionBlock(success: false);
            }
        }
        
    }
    
    func complete(object: CRMActivity, completionBlock:(success:Bool) -> Void)
    {
        self.refreshAuthToken { (success:Bool) -> Void in
            if (success)
            {
                let path = String(format: "tasks(%@)/statecode", arguments: [object.crmID]);
                
                var bodyData:NSData? = nil;
                do
                {
                    bodyData = try NSJSONSerialization.dataWithJSONObject(object.markAsCompleteDictionary(), options: NSJSONWritingOptions.PrettyPrinted);
                }
                catch
                {
                    completionBlock(success: false);
                }
                
                let createRequest = self.oDataPutRequestForEndpoint(path, body: bodyData!);
                let createTask = NSURLSession.sharedSession().dataTaskWithRequest(createRequest) {  (data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    
                    completionBlock (success: error == nil);
                    
                }
                createTask.resume();
            }
            else
            {
                completionBlock(success: false);
            }
        }
    }
}
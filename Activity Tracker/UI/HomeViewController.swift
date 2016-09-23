//
//  HomeViewController.swift
//  Activity Tracker
//
//  Created by Ben Toepke on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

enum HomeViewDisplayMode {
    case HomeViewDisplayRecents
    case HomeViewDisplaySearch
}


class HomeViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var theSearchBar: UISearchBar!
    @IBOutlet weak var resultsView: UITableView!
    @IBOutlet weak var loadingIndicator: UIImageView!
    
    var CellIdentifier = "ResultsCell",
        currMode = HomeViewDisplayMode.HomeViewDisplayRecents,
        recents = [AnyObject]?(),
        searchResults = [AnyObject]?();
    
    convenience init() {
        self.init(nibName:"HomeView", bundle:nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = "Activity Tracker";
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style:.Plain, target: nil, action: nil);
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "icon-settings"), style:.Plain, target: self, action: #selector(HomeViewController.settingsTapped(_:)));
        
        
        if (LocalStorage.localStorage.getHost() != nil) {
            CRMClient.sharedClient.setNewEndpoint(LocalStorage.localStorage.getHost()!) { (success) -> Void in };
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        recents = LocalStorage.localStorage.getRecents();
        resultsView.reloadData();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (LocalStorage.localStorage.getHost() == nil) {
            settingsTapped(nil);
        }
//        else {
//            CRMClient.sharedClient.setNewEndpoint(LocalStorage.localStorage.getHost()!) { (success) -> Void in };
//        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        if let indexPath = resultsView.indexPathForSelectedRow {
            resultsView.deselectRowAtIndexPath(indexPath, animated: false);
        }
    }
    
    func settingsTapped(sender:AnyObject?) {
        let settingsView = SettingsViewController();
        self.navigationController?.pushViewController(settingsView, animated: true);
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
    
    // MARK: UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (searchBar.text?.characters.count != 0) {
            currMode = .HomeViewDisplaySearch;
            searchResults = nil;
            resultsView.reloadData();
            searchBar.resignFirstResponder();
            animateSpinner();
            
            CRMClient.sharedClient.searchFor(searchBar.text!, completionBlock: { (results, error) -> Void in
                if (error != nil) {
                    let errorAlert = UIAlertController(title: "Error", message: "There was an error performing your search. Please ensure you are connected to the internet.", preferredStyle:UIAlertControllerStyle.Alert);
                    errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil));
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(errorAlert, animated: true, completion: nil);
                    });
                }
                else {
                    self.searchResults = results as? [AnyObject];
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.resultsView.reloadData();
                        searchBar.setShowsCancelButton(true, animated: true);
                        self.stopSpinner();
                    });
                }
            });
        }
        else {
            currMode = .HomeViewDisplayRecents;
            recents = LocalStorage.localStorage.getRecents();
            searchBar.setShowsCancelButton(false, animated: true);
            
            resultsView.reloadData();
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true);
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
        searchBar.text = "";
        currMode = .HomeViewDisplayRecents;
        recents = LocalStorage.localStorage.getRecents();
        searchBar.setShowsCancelButton(false, animated: true);
        
        resultsView.reloadData();
    }
    
    // MARK: UITableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (currMode) {
            case .HomeViewDisplayRecents:
                return recents != nil ? recents!.count : 0;
            case .HomeViewDisplaySearch:
                return searchResults != nil ? searchResults!.count : 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var retVal = tableView.dequeueReusableCellWithIdentifier(CellIdentifier);
        if (retVal == nil)
        {
            retVal = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier);
            retVal!.selectedBackgroundView = UIView();
        }
        
        var currObject = CRMObject();
        if (currMode == .HomeViewDisplayRecents)
        {
            currObject = recents?[indexPath.row] as! CRMObject;
        }
        else
        {
            currObject = searchResults?[indexPath.row] as! CRMObject;
        }
        
        retVal!.textLabel!.text = currObject.resultLine1;
        retVal!.detailTextLabel!.text = currObject.resultLine2;
        retVal!.imageView!.image = UIImage(named:"icon-contact");
        retVal!.selectedBackgroundView!.backgroundColor = BLUE_HIGHLIGHT;
        retVal!.textLabel!.textColor = LIGHT_BLUE;
        retVal!.detailTextLabel!.textColor = MEDIUM_GREY;
        
        return retVal!;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (currMode == .HomeViewDisplayRecents)
        {
            return "RECENT RECORDS";
        }
        else
        {
            return "SEARCH RESULTS";
        }
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var currObject = CRMObject();
        if (currMode == .HomeViewDisplayRecents)
        {
            currObject = recents?[indexPath.row] as! CRMObject;
        }
        else
        {
            currObject = searchResults?[indexPath.row] as! CRMObject;
        }
        
        let details = ObjectDetailsViewController();
        details.displayObject = currObject;
        
        LocalStorage.localStorage.addToRecents(currObject);

        self.navigationController?.pushViewController(details, animated: true);
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

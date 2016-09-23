//
//  AppDelegate.swift
//  Activity Tracker
//
//  Created by Kyle Gerstner on 4/18/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func setupColorsAndFonts() {
        let titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()];
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes;
        UINavigationBar.appearance().barTintColor = DARK_BLUE;
        UINavigationBar.appearance().tintColor = UIColor.whiteColor();
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "icon-back");
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "icon-back");
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupColorsAndFonts();
        self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds);
        self.window?.backgroundColor = UIColor.whiteColor();
        
        let homeView = HomeViewController(),
            mainNav = UINavigationController(rootViewController: homeView);
        mainNav.navigationBar.translucent = false;
        
        self.window?.rootViewController = mainNav;
        self.window?.makeKeyAndVisible();
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


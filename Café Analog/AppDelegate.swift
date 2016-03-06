//
//  AppDelegate.swift
//  Café Analog
//
//  Created by Jacob Benjamin Cholewa on 25/02/2016.
//  Copyright © 2016 Jacob Benjamin Cholewa. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate{
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var lastNotification:NSDate?
    var lastLeave:NSDate?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        locationManager.delegate = self
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
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let _ = region as? CLBeaconRegion {
            Alamofire.request(.GET, "http://cafeanalog.dk/api/open/").responseJSON {
                response in switch response.result {
                case .Success(let JSON):
                    
                    //Get JSON response data
                    let response = JSON as! NSDictionary
                    let open:Bool = response.objectForKey("open") as! Bool
                    
                    //Escape criteria
                    if(!open) { return } //If not open
                    //If the user got a notification within the last 15 minutes
                    if(self.lastNotification != nil && Int((self.lastNotification?.timeIntervalSinceNow)!) < 900){ return }
                    //If the user only briefly left the ITU beacon zone (Eg. there is no beacon visibility in the bathrooms)
                    if(self.lastLeave != nil && Int((self.lastLeave?.timeIntervalSinceNow)!) < 60){ return }
                    
                    //Fireing notification
                    let notification = UILocalNotification()
                    notification.alertTitle = "Analog is ÅPEN"
                    notification.alertBody = "Come by and grab a cup of coffee!"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                    
                    //Setting lastNotification
                    self.lastNotification = NSDate()
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.lastLeave = NSDate()
    }
}


//
//  AppDelegate.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 22..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import HealthKit
import FHIR
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().tintColor = UIColor(red: 241/255, green: 128/255, blue: 90/255, alpha: 1.0)
        getHeartRates()
        
        prefs.set(nil, forKey: "patientId")
        prefs.set(nil, forKey: "name")
        prefs.set(false, forKey: "autoLogin")
        prefs.set(nil, forKey: "id")
        prefs.set(nil, forKey: "password")
        prefs.set(false, forKey: "connectHpa")
        prefs.set("ict.demo.hongil4@gmail.com", forKey: "dropboxId")
        
        if isLogined {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        getHeartRates()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        getHeartRates()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        getHeartRates()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getHeartRates() -> Void {
        healthKitManager?.readHeartRates() { (results, error) -> Void in
            NSLog("start HealthKitManager")
            if (error != nil) {
                print("Error: Reading HeartRate \(error?.localizedDescription)")
                return
            } else {
                print("heartRates read successfully!")
                heartRates = results as! [HKQuantitySample]
            }
        }
    }
    
}

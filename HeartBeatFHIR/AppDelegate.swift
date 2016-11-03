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

// uesrInfo
let user = [ "id" : "test", "password" : "test", "patientId" : "7", "familyName": "이", "givenName" : "진기", "telecom" : "82+ 10-7769-1093", "gender" : "남", "birthDate" : "1990-01-14" ]

var prefs = UserDefaults.standard

let currentVersion = "0.0.1"
var isLogined: Bool = false

// HealthKit
var bpmUnit = HKUnit(from: "count/min")
var heartRates = [HKQuantitySample]()
var healthKitManager: HealthKitManager? = HealthKitManager()

// FHIR
let baseUrl = "http://hitlab.gachon.ac.kr:8888/gachon-fhir-server/baseDstu2"
let fhirServer = FHIROpenServer(baseURL: URL(string: baseUrl)!)
//let fhirServer: Server = Server(baseURL: URL(string: baseUrl)!)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UITabBar.appearance().tintColor = UIColor(red: 241/255, green: 128/255, blue: 90/255, alpha: 1.0)
        
        getHeartRates()
        
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

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

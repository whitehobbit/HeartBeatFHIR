//
//  HealthKitManager.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 22..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import HealthKit

class HealthKitManager {
    let store = HKHealthStore()
    
    init() {
        print("\nHealthKitManager init")
        authorizeHealthKit { (success, error) in
            if success {
                print("HealthKit authorization received.\n")
            }
            else
            {
                print("HealthKit authorization denied!\n")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }
    
    // HealthKit Authorization func
    func authorizeHealthKit(_ completion: ((Bool, Error?) -> Void)!) {
        let healthKitTypesToReads = Set(arrayLiteral: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
        let healthKitTypesToWrites = Set(arrayLiteral: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
        
        // not available device return error
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "kr.ac.gachon.hitlab.", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available in this Device"])
            if (completion != nil) {
                completion(false, error)
            }
            return
        }
        
       store.requestAuthorization(toShare: healthKitTypesToWrites, read: healthKitTypesToReads) {  (success, error) -> Void in
            if (completion != nil) {
                completion(success, error)
            }
        }
    }
    
    func recentHeartRates(_ completion: ((Double, Error?) -> Void)!) {
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        // 1. Predicate to read only running workouts
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: Date(), options: HKQueryOptions())
        // 2. Order the workouts by date
        
        // 3. Create the query
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil) { (query, results, error) -> Void in
            var heartRates: Double = 0
            if (results?.count)! > 0 {
                for result in results as! [HKQuantitySample] {
                    heartRates += result.quantity.doubleValue(for: HKUnit.count())
                }
            }
            completion(heartRates, error)
        }
        // 4. Excute the query
        store.execute(query)
    }
    
    func readHeartRates(_ completion: (([AnyObject]?, Error?) -> Void)!) {
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let past = Date.distantPast
        let now = Date()
        // 1. Predicate to read only running workouts
        let predicate =  HKQuery.predicateForSamples(withStart: past, end: now, options: HKQueryOptions())
        
        // 2. Order the workouts by date
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // 3. Create the query
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { (sampleQuery, result, error) -> Void in
            completion(result, error)
        }
        // 4. Excute the query
        store.execute(query)
    }
}

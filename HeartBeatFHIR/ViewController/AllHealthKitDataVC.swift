//
//  AllHealthKitDataVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 29..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import HealthKit
import Alamofire
import SwiftyJSON

class AllHealthKitDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let healthKitDataCellIdentifier = "healthKitDataCell"
    var heartRateDateDic = [String : String]()
    var heartRateDic = [String : Array<HKQuantitySample>]()
    var heartRateDateKeys = [String]()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY. MM. dd."
        return formatter
    }()
    var sectionSize = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
        
//        heartRates.map { }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.setTableData()
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
        self.reloadTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heartRateDateKeys.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath: \(indexPath.row), heartRateKey: \(self.heartRateDateKeys[indexPath.row])")
        let cell = tableView.dequeueReusableCell(withIdentifier: self.healthKitDataCellIdentifier, for: indexPath)
        let heartRate: String? = self.heartRateDateKeys[indexPath.row]
        let numberOfHeartRate = heartRateDateDic[heartRate!]
        
        cell.textLabel?.text = "\(numberOfHeartRate!)"
        cell.detailTextLabel?.text = self.heartRateDateKeys[indexPath.row]
        
        return cell
    }
    
    func setTableData() {
        self.heartRateDic.removeAll()
        self.heartRateDateKeys.removeAll()
        var beforeDate: String? = nil
        var minHeartRate = Int((heartRates.first?.quantity.doubleValue(for: bpmUnit))!)
        var maxHeartRate = minHeartRate
        
        for heartRate in heartRates {
            let currentHeartRate = Int(heartRate.quantity.doubleValue(for: bpmUnit))
            let currentDate: String? = self.dateFormatter.string(from: heartRate.startDate)
            
            if beforeDate != currentDate {
                self.heartRateDic[currentDate!] = [HKQuantitySample]()
                
                if beforeDate != nil {
                    self.heartRateDateKeys.append(beforeDate!)
                    self.heartRateDateDic[beforeDate!] = "\(minHeartRate) - \(maxHeartRate)"
                }
                beforeDate = currentDate
                minHeartRate = currentHeartRate
                maxHeartRate = currentHeartRate
            }
            
            if beforeDate != nil {
                self.heartRateDic[currentDate!]?.append(heartRate)
            }
            
            if minHeartRate > currentHeartRate {
                minHeartRate = currentHeartRate
            } else if maxHeartRate < currentHeartRate {
                maxHeartRate = currentHeartRate
            }
        }
        
        self.heartRateDateKeys.append(beforeDate!)
        self.heartRateDateDic[beforeDate!] = "\(minHeartRate) - \(maxHeartRate)"
        
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allHealthKitToSelectDate" {
            let destinationVC = segue.destination as! SelectDateVC
            let myIndexPath = self.tableView.indexPathForSelectedRow
            let row = (myIndexPath as NSIndexPath?)?.row
            print ("\(heartRateDic[heartRateDateKeys[row!]]!.count)")
            
            for heartRate in self.heartRateDic[self.heartRateDateKeys[row!]]! {
                destinationVC.heartRates.append(heartRate)
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
}

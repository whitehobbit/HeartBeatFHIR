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
    
    var weightDateDic = [String : String]()
    var weightDic = [String : Array<HKQuantitySample>]()
    var weightDateKeys = [String]()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY. MM. dd."
        return formatter
    }()
    var sectionSize = 2
    let activityIndicator = UIActivityIndicatorView()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableSetting()
        self.setActivityIndicator()
        self.setTableData()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return heartRateDateKeys.count
        case 1:
            return weightDateKeys.count
        default:
            return 0
        }
        
//        return heartRateDateKeys.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionSize
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Heart Rate"
        case 1:
            return "Weight"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("indexPath: \(indexPath.row), heartRateKey: \(self.heartRateDateKeys[indexPath.row])")
//        print("INFO: cell: \(self.heartRateDateKeys.count)")
        let cell = tableView.dequeueReusableCell(withIdentifier: self.healthKitDataCellIdentifier, for: indexPath)
        
        var textLabel = ""
        var detailLabel = ""
//        print("\(indexPath.section) \(indexPath.row)")

        switch indexPath.section {
        case 0:
            let heartRate: String? = self.heartRateDateKeys[indexPath.row]
            textLabel = heartRateDateDic[heartRate!] ?? ""
            detailLabel = heartRateDateKeys[indexPath.row]
        case 1:
            let weight: String? = self.weightDateKeys[indexPath.row]
            textLabel = weightDateDic[weight!] ?? ""
            detailLabel = weightDateKeys[indexPath.row]
        default:
            textLabel = ""
            detailLabel = ""
        }
        
        cell.textLabel?.text = textLabel
        cell.detailTextLabel?.text = detailLabel
        
        return cell
    }
    
    func setTableData() {
        print(self.heartRateDateKeys.count)
        
        startActivityIndicator()
        healthKitManager?.readHeartRates { (results, error) in
            guard let hkDatas = results as! [HKQuantitySample]? else {
                print("ERROR: hkDatas")
                return
            }
            self.heartRateDic.removeAll()
            self.heartRateDateKeys.removeAll()
            print("INFO: hkrs OK")
            var beforeDate: String? = nil
//            print(hkDatas.first?.toJSON())
            var minHeartRate = Int((hkDatas.first?.quantity.doubleValue(for: bpmUnit))!)
            var maxHeartRate = minHeartRate
            for hkData in hkDatas {
//                print(hkData.toJSON())
                let currentHtr = Int(hkData.quantity.doubleValue(for: bpmUnit))
                let currentDate: String? = self.dateFormatter.string(from: hkData.startDate)
                
                if beforeDate != currentDate {
                    self.heartRateDic[currentDate!] = [HKQuantitySample]()
                    
                    if beforeDate != nil {
                        
                            self.heartRateDateKeys.append(beforeDate!)
                            self.heartRateDateDic[beforeDate!] = "\(minHeartRate) - \(maxHeartRate)"
                    }
                    beforeDate = currentDate
                    minHeartRate = currentHtr
                    maxHeartRate = currentHtr
                }
                
                if beforeDate != nil {
                    self.heartRateDic[currentDate!]?.append(hkData)
                }
                
                if minHeartRate > currentHtr {
                    minHeartRate = currentHtr
                } else if maxHeartRate < currentHtr {
                    maxHeartRate = currentHtr
                }
//                print("INFO: for \(self.heartRateDateKeys.count)")
            }
            self.heartRateDateKeys.append(beforeDate!)
            self.heartRateDateDic[beforeDate!] = "\(minHeartRate) - \(maxHeartRate)"
            self.reloadTable()

        }
        
        healthKitManager?.readWeights { (results, error) in
            guard let hkDatas = results as! [HKQuantitySample]? else {
                print("ERROR: hkDatas")
                return
            }
            self.weightDic.removeAll()
            self.weightDateKeys.removeAll()
            print("INFO: hkDatas OK")
            var beforeDate: String? = nil
            var minWeight = Int((hkDatas.first?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))!)
            var maxWeight = minWeight
            for hkData in hkDatas {
                let currentWeight = Int(hkData.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))
                let currentDate: String? = self.dateFormatter.string(from: hkData.startDate)
                
                if beforeDate != currentDate {
                    self.weightDic[currentDate!] = [HKQuantitySample]()
                    
                    if beforeDate != nil {
                        
                        self.weightDateKeys.append(beforeDate!)
                        self.weightDateDic[beforeDate!] = "\(minWeight) - \(maxWeight)"
                    }
                    beforeDate = currentDate
                    minWeight = currentWeight
                    maxWeight = currentWeight
                }
                
                if beforeDate != nil {
                    self.weightDic[currentDate!]?.append(hkData)
                }
                
                if minWeight > currentWeight {
                    minWeight = currentWeight
                } else if maxWeight < currentWeight {
                    maxWeight = currentWeight
                }
                //                print("INFO: for \(self.heartRateDateKeys.count)")
            }
            self.weightDateKeys.append(beforeDate!)
            self.weightDateDic[beforeDate!] = "\(minWeight) - \(maxWeight)"
            self.reloadTable()
            
        }
//        
//        for heartRate in heartRates {
//            let currentHeartRate = Int(heartRate.quantity.doubleValue(for: bpmUnit))
//            let currentDate: String? = self.dateFormatter.string(from: heartRate.startDate)
//            
//            if beforeDate != currentDate {
//                self.heartRateDic[currentDate!] = [HKQuantitySample]()
//                
//                if beforeDate != nil {
//                    self.heartRateDateKeys.append(beforeDate!)
//                    self.heartRateDateDic[beforeDate!] = "\(minHeartRate) - \(maxHeartRate)"
//                }
//                beforeDate = currentDate
//                minHeartRate = currentHeartRate
//                maxHeartRate = currentHeartRate
//            }
//            
//            if beforeDate != nil {
//                self.heartRateDic[currentDate!]?.append(heartRate)
//            }
//            
//            if minHeartRate > currentHeartRate {
//                minHeartRate = currentHeartRate
//            } else if maxHeartRate < currentHeartRate {
//                maxHeartRate = currentHeartRate
//            }
//        }
//        
    }
    
    func setTableSetting() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            self.tableView.reloadData()
            return
        }
    }
    
    func refresh(sender: Any) {
        
        self.setTableData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allHealthKitToSelectDate" {
            let destinationVC = segue.destination as! SelectDateVC
            
            ///
            guard let myIndexPath = self.tableView.indexPathForSelectedRow else {
                return
            }
            guard let row = (myIndexPath as NSIndexPath?)?.row else {
                return
            }
            
            switch myIndexPath.section {
            case 0:
                for heartRate in self.heartRateDic[self.heartRateDateKeys[row]]! {
//                    destinationVC.heartRates.append(heartRate)
                    destinationVC.hk_datas.append(heartRate)
                }
            case 1:
                for weight in self.weightDic[self.weightDateKeys[row]]! {
                    //destinationVC.weights.append(weight)
                    destinationVC.hk_datas.append(weight)
                }
            default:
                return
            }
            ///
            
//            let myIndexPath = self.tableView.indexPathForSelectedRow
//            let row = (myIndexPath as NSIndexPath?)?.row
//            print ("\(heartRateDic[heartRateDateKeys[row!]]!.count)")
//            
//            
//            
//            for heartRate in self.heartRateDic[self.heartRateDateKeys[row!]]! {
//                destinationVC.heartRates.append(heartRate)
//            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Indicator
    func setActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    }
    
    func startActivityIndicator() {
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
    }
}

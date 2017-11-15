//
//  SelectDateVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 29..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import HealthKit
import SwiftyJSON

class SelectDateVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var heartRates = [HKQuantitySample?]()
    var hk_datas = [HKQuantitySample?]()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a hh:mm"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY. MM. dd"
//            return dateFormatter.string(from: heartRates.first!!.startDate)
            return dateFormatter.string(from: hk_datas.first!!.startDate) ///
        }()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
        setActivityIndicator()
        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return (heartRates.count)
        return (hk_datas.count) ///
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDataCell", for: indexPath)
        var textLabel = ""
        var detailLabel = ""
        guard let hk_data = hk_datas[indexPath.row] else {
            return cell
        }
//        print(hk_data.quantityType.identifier)
        switch hk_data.quantityType.identifier {
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            textLabel = "\(hk_data.quantity.doubleValue(for: bpmUnit))"
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            print("weight")
            textLabel = "\(hk_data.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))"
        default:
            print("default")
        }
        
        detailLabel = "\(dateFormatter.string(from: hk_data.startDate))"
        
        cell.textLabel?.text = textLabel
        cell.detailTextLabel?.text = detailLabel
//        let heartRate = heartRates[indexPath.row]
//        print(heartRate?.quantityType.identifier == HKQuantityTypeIdentifier.heartRate.rawValue)
//        cell.textLabel?.text = "\(heartRate!.quantity.doubleValue(for: bpmUnit))"
//        cell.detailTextLabel?.text = "\(self.dateFormatter.string(from: (heartRates[indexPath.row]?.startDate)!))"
        return cell
    }
    
    @IBAction func clickHillingUpload(_ sender: UIButton) {
        
        func errorAlert(_ msg: String = "Create Failed") {
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        connectHPA = prefs.bool(forKey: "connectHpa")
        
        guard connectHPA else {
            errorAlert("HPA not connected")
            return
        }
        
        guard !hk_datas.isEmpty else {
            
            errorAlert("hk_data is empty")
            return
        }
        
        guard let name = prefs.string(forKey: "name") else {
            errorAlert("name is nil")
            return
        }
        startActivityIndicator()
        
        print(name)
        
        let ccrM = CCRManager()
        var hkd = [HKQuantitySample]()
        for hkData in hk_datas {
            hkd.append(hkData!)
        }
        let ccr = ccrM.convertCCR(hkDatas: hkd)
        
        
        
        HTOS_API.uploadHPA(name: name, user: uid, ccr: ccr) { data in
            guard let data = data else {
                errorAlert("response nil")
                return
            }
            
            guard data["handle"] != nil else {
                errorAlert()
                return
            }
            print(data)
            
            self.stopActivityIndicator()
            let alert = UIAlertController(title: "Success", message: "전송 성공", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
        }
//                print(ccr.asString())
    }
    
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "selectToDetail" {
            let destiantionVC = segue.destination as! DetailHealthKitVC
            let myIndexPath = self.tableView.indexPathForSelectedRow
            
            guard let row = myIndexPath?.row else{
                return
            }
            
            destiantionVC.hk_data = self.hk_datas[row]
        }
    }
 

}

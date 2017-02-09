//
//  FhirServerVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 10. 7..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import FHIR
import Alamofire
import SwiftyJSON

class FhirServerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var heartRateDic = [String: [Int]]()
    var obsDic = [String: [Observation]]()
    var heartRateDicKey = [String]()
    
    let dateFormatter: DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YY. MM. dd"
        return dateFormat
    }()
    
    override func viewDidLoad() {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\n\n=================== FhirServerVC viewWillAppear===================")
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
        self.getFHIR()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("\n\nkeyCount: \(self.heartRateDicKey.count)")
        return self.heartRateDicKey.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fhirCell", for: indexPath)
        
        let key = self.heartRateDicKey[indexPath.row]
//        print("\n\n\(key)")
        cell.textLabel?.text = "\((self.heartRateDic[key]?.min())!) -  \((self.heartRateDic[key]?.max())!) (\((self.heartRateDic[key]?.count)!))"
        cell.detailTextLabel?.text = key

        return cell
    }

    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }
    
    // MARK: - 테이블셀 사이즈에 맞춰 테이블뷰 조절
    func tableViewAutoHeight() {
        if self.tableView.contentSize.height < self.tableView.frame.height {
            var frame: CGRect = self.tableView.frame
            frame.size.height = self.tableView.contentSize.height
            self.tableView.frame = frame
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fhirServerToFhirDate" {
            let destinationVC = segue.destination as! FhirDateVC
            let myIndexPath = self.tableView.indexPathForSelectedRow
            let low = (myIndexPath as NSIndexPath?)?.row
            
            for obs in self.obsDic[heartRateDicKey[low!]]! {
                destinationVC.obss.append(obs)
                destinationVC.title = heartRateDicKey[low!]
            }
        }
    }

    
    func getFHIR() {
        let user = prefs.dictionary(forKey: "userLoginInfo")!
        let (code, pId) = ("8867-4", user["patientId"] as! String)
        heartRateDic.removeAll()
        heartRateDicKey.removeAll()
        obsDic.removeAll()
        var heartRateDicTemp = [String: [Int]]()
        var heartRateKeyTemp = [String]()
        
        var searchUrl = fhirServer.baseURL.absoluteString + Observation.resourceType + "?patient=" + pId + "&code=" + code + "&_count=50"
 
        Alamofire.request(searchUrl).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let total = JSON(value)["total"].stringValue
                let entrys = JSON(value)["entry"].array
                let bundle = Bundle(json: JSON(value).dictionaryObject)
                
                for entry in bundle.entry! {
                    let obs: Observation = entry.resource as! Observation
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YY. MM. dd"
                    let date = dateFormatter.string(from: (obs.effectiveDateTime?.nsDate)!)
                    if !(self.heartRateDicKey.contains(date)) {
                        self.heartRateDicKey.append(date)
                    }
                    if self.heartRateDic[date] == nil {
                        self.heartRateDic[date] = [Int]()
                        self.obsDic[date] = [Observation]()
                    }
                    self.heartRateDic[date]?.append(Int((obs.valueQuantity?.value)!))
                    self.obsDic[date]?.append(obs)
//                    print(obs.id)
                }
                self.heartRateDicKey.sort()
                self.heartRateDicKey.reverse()
                self.reloadTable()
//                searchUrl = searchUrl + "&_count=" + total
//                print("in: \(searchUrl)")
//
//                Alamofire.request(searchUrl).validate().responseJSON { res in
//                    
//                    switch res.result {
//                    case .success(let value):
//                        let bundleJson = JSON(value)
////                        print(bundleJson["entry"].count)
//                        let obsEntrys = bundleJson["entry"].array!
//                        for obsEntry in obsEntrys {
//                            let obsResource = obsEntry["resource"]
//                            let obs = Observation(json: obsResource.dictionaryObject)
//                            print(obs.id)
//                        }
//                    case .failure(let error):
//                        print(error)
//                    }
//                    
//                }
            case .failure(let error):
                print(error)
            }
        }
//        let search = Observation.search([
//            "code" : "8867-4",
//            "patient" : user["patientId"]!
//            ])
//        
//        search.perform(fhirServer) { (bundle, error) in
//            if error != nil {
//                dump(error)
//            } else {
//                var bundleEntry = [BundleEntry]()
//                var bund = bundle
//                for entry in (bundle?.entry)! {
//                    bundleEntry.append(entry)
//                }
////                print("\n\ncount: \(bundleEntry.count)")
//                
//                while (bund?.link?.contains { element in
//                    bund?.link?.removeAll()
//                    if element.relation == "next" {
//                        bund?.link?.append(element)
//                        return true
//                    } else {
//                        return false
//                    }
//                    })! {
//                        let url = (bund?.link?.first?.url?.absoluteURL)!
//                        bund = FHIR.Bundle(json: FhirJsonManager.getFhirJson(url: url))
//                        for entry in (bund?.entry)! {
//                            bundleEntry.append(entry)
//                        }
//                }
////                print("\n\ncount: \(bundleEntry.count)")
//                
//                for entry in bundleEntry {
//                    let json = FhirJsonManager.getFhirJson(url: (entry.fullUrl?.absoluteURL)!)
//                    FhirJsonManager.printJsonPretty(json!)
//                    let obs = Observation(json: json)
//                    let date = self.dateFormatter.string(from: (obs.effectiveDateTime?.nsDate)!)
//                    let value: Int = (obs.valueQuantity?.value?.intValue)!
////                    print("value: "); dump(value)
//                    if heartRateDicTemp[date] == nil {
//                        heartRateDicTemp[date] = [Int]()
//                        self.obsDic[date] = [Observation]()
//                    }
//                    if !(heartRateKeyTemp.contains(date)) {
//                        heartRateKeyTemp.append(date)
//                    }
//                    heartRateDicTemp[date]?.append(value)
//                    self.obsDic[date]?.append(obs)
////                    print("heartRateDicTemp: \(date)"); dump(heartRateDicTemp)
////                    print("heartRateKeyTemp: "); dump(heartRateKeyTemp)
//                }
//                self.heartRateDicKey = heartRateKeyTemp.sorted().reversed()
//                dump(self.heartRateDicKey)
//                self.heartRateDic = heartRateDicTemp
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
        
    }
}

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

class HillingPlatformTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var hpaButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var hillingData = [String: [String: [Results]]]()
    var providers = [String]()
    var hillingDataKey = [String: [String]]()
    
    var hd = [String: [Results]]()
    
    let dateFormatter: DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YY. MM. dd"
        return dateFormat
    }()
    
    override func viewDidLoad() {
        print("============ HPAVC viewDidLoad() ============")
        super.viewDidLoad()
        connectHPA = prefs.bool(forKey: "connectHpa")
        print("viewDidLoad() \(connectHPA)")
        if connectHPA {
            hpaButton.isEnabled = false
            self.getHPAData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("=================== HPAVC viewWillAppear===================")
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
        //        self.getFHIR()
        hd.removeAll()
        providers.removeAll()
        connectHPA = prefs.bool(forKey: "connectHpa")
        if connectHPA {
            hpaButton.isEnabled = false
            self.getHPAData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let sectionSize = self.providers.count == 0 ? 1 : self.providers.count
        print("INFO: numberOfSections() sectionSize: \(sectionSize)")
        return sectionSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        print("\n\nkeyCount: \(self.heartRateDicKey.count)")
        var size = 0
        for i in 0...self.providers.count {
            if section == i {
                if !self.providers.isEmpty {
                    print("INFO: tableView(_:numberOfRowsInSection:) providers[\(i)]: \(providers[i])")
                    //                    size = (self.hillingData[self.providers[i]]?.count)!
                    size = (self.hd[providers[i]]?.count)!
                }
            }
        }
        print("INFO: tableView(_:numberOfRowsInSection:) size: \(size)")
        return size
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HillingCell", for: indexPath)
        
        let provider = self.providers[indexPath.section]
        var keys = [String]()
        var values = [String]()
        var units = [String]()
        var types = [String]()
        var descriptions = [String]()
        
        for key in hd[provider]! {
            keys.append(key.dateTime)
            values.append(key.value)
            units.append(key.unit)
            types.append(key.type)
            descriptions.append(key.description)
        }
        //        let key = self.heartRateDicKey[indexPath.row]
        //        print("\n\n\(key)")
        //        cell.textLabel?.text = "\((self.hillingData[provider]?[key!]?.min())!) -  \((self.heartRateDic[key]?.max())!) (\((self.heartRateDic[key]?.count)!))"
        cell.textLabel?.text = "\(descriptions[indexPath.row]) \(values[indexPath.row])\(units[indexPath.row])"
        cell.detailTextLabel?.text = keys[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("INFO: tableView(_:titleForHeaderInSection:) section: \(section)")
        let text: String? = self.providers.isEmpty ? nil : self.providers[section]
        return text
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }

    @IBAction func clickHpaButton(_ sender: Any) {
        guard let sender = sender as? UIButton else {
            return
        }
        var isResistered = false
        HTOS_API.registerHpaToken(user: user["id"]) { (json, flag) in
            print(json)
            isResistered = flag
            //            print(isResistered)
            
            if isResistered {
                HTOS_API.connectRepository(user: "ict.demo.hongil4@gmail.com") { (data) in
                    
                    let url = URL(string: data!)!
                    let controller = self as UIViewController
                    
                    let web = InAppDropBoxConnectorController(URL: url) { succeed in
                        DispatchQueue.main.async {
                            prefs.set(succeed, forKey: "connectHpa")
                            connectHPA = prefs.bool(forKey: "connectHpa")
                            self.checkHPAConnection(connectHPA, sender: sender)
                        }
                    }
                    let navigationController = UINavigationController(rootViewController: web)
                    
                    controller.present(navigationController, animated: true, completion: nil)
                    
                }
                
            }
        }
        
    }
    
    func checkHPAConnection(_ isConnectHPA: Bool, sender: UIButton) {
        if isConnectHPA {
            sender.isEnabled = false
            sender.setTitle("힐링플랫폼 연동 성공", for: .disabled)
            sender.backgroundColor = UIColor.lightGray
        } else {
            sender.isEnabled = true
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
        //        if segue.identifier == "fhirServerToFhirDate" {
        //            let destinationVC = segue.destination as! FhirDateVC
        //            let myIndexPath = self.tableView.indexPathForSelectedRow
        //            let low = (myIndexPath as NSIndexPath?)?.row
        //
        //            for obs in self.obsDic[heartRateDicKey[low!]]! {
        //                destinationVC.obss.append(obs)
        //                destinationVC.title = heartRateDicKey[low!]
        //            }
        //        }
    }
    
    func getHPAData() {
        let user = "ict.demo.hongil4@gmail.com"
        
        HTOS_API.getHPAData(user: user) { datas in
            guard let datas = datas else {
                print("ERROR: callback is NULL")
                return
            }
            //            print(datas)
            
            guard let docsArray = datas["documents"].array else {
                if let error = datas.string {
                    print(error)
                } else {
                    print("ERROR: \"documnets\" is not found")
                }
                return
            }
            let dateFormatYYMMdd = DateFormatter()
            dateFormatYYMMdd.dateFormat = "YY. MM. dd"
            let dateFormatYYYYMMddhhmmss = DateFormatter()
            dateFormatYYYYMMddhhmmss.dateFormat = "YYYYMMddhhmmss"
            
            for docs in docsArray {
                guard let results = docs["results"].array, let provider = docs["provider"].string else {
                    return
                }
                
                if !self.providers.contains(provider) {
                    self.providers.append(provider)
                    self.hillingData[provider] = [String: [Results]]()
                    self.hillingDataKey[provider] = [String]()
                    self.hd[provider] = [Results]()
                }
                
                for result in results {
//                    guard result["type"].string == "심박" else {
//                        break
//                    }
                    guard let value = result["value"].string, let oid = result["oid"].string else {
                        break
                    }
                    guard let tmp = Results(result) else {
                        break
                    }
                    
                    print(tmp)
                    
                    let tt = oid.replacingOccurrences(of: "vitalsigns.", with: "")
                    var date = dateFormatYYYYMMddhhmmss.date(from: tt)
                    var dateStr = dateFormatYYMMdd.string(from: date!)
                    if !(self.hillingDataKey[provider]?.contains(dateStr))! {
                        self.hillingDataKey[provider]?.append(dateStr)
                        self.hillingData[provider]?[dateStr] = [Results]()
                    }
                    self.hillingData[provider]?[tmp.dateTime]?.append(tmp)
                    
                    
                    self.hd[provider]?.append(tmp)
                }
            }
            print("INFO: hillingData: \(self.hillingData)")
            print("INFO: hillingData.providr.size: \(self.hillingData)")
            print("INFO: providers: \(self.providers)")
            
            for key in self.providers {
                self.hillingDataKey[key]?.sort()
                self.hillingDataKey[key]?.reverse()
            }
            self.reloadTable()
        }
    }
}



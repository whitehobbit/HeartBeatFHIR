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
    
    @IBOutlet weak var hpaButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView()
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
        self.setActivityIndicator()
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
        guard let pId = prefs.string(forKey: "patientId") else {
            return
        }
        startActivityIndicator()
        let code = "8867-4"
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

            case .failure(let error):
                print(error)
            }
            self.stopActivityIndicator()
        }
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
}

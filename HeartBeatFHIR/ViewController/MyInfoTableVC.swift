//
//  MyInfoTableVC.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2016. 11. 9..
//  Copyright © 2016년 WhiteHobbit. All rights reserved.
//

import UIKit
import FHIR
import Alamofire
import SwiftyJSON

class MyInfoTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let myInfoIdentifier = "MyInfoCell"
    var dataKey = ["ID", "PatientId", "Name", "Gender", "Birthdate", "Tel"]
    var dataDic = [String: String?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        automaticallyAdjustsScrollViewInsets = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
        self.setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewAutoHeight()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDic.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.myInfoIdentifier, for: indexPath)
        
        let key = dataKey[indexPath.row]
        cell.textLabel?.text = NSLocalizedString(key, comment: "")
        if let value = dataDic[key] {
            cell.detailTextLabel?.text = value
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func setData() {
        for key in dataKey {
            dataDic[key] = ""
        }
        dataDic[dataKey[0]] = user["id"]
        
        guard let pId = user["patientId"] else {
            return
        }
        
        dataDic["PatientId"] = user["patientId"]
        
        let urlPath = fhirServer.baseURL.absoluteString + Patient.resourceType + "/" + pId
        
        Alamofire.request(urlPath).responseJSON { res in
            guard let json = res.result.value else {
                print("no response")
                return
            }
            let swiftyJson = JSON(json)
            let fhirJson = swiftyJson.dictionaryObject
            
            let pat = Patient(json: fhirJson)
            
            if let family = pat.name?.first?.family?.first, let given = pat.name?.first?.given?.first {
                self.dataDic["Name"] = given + " " + family
            }
            if let gender = pat.gender {
                self.dataDic["Gender"] = gender
            }
            if let birthdate = pat.birthDate?.nsDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY. MM. dd"
                self.dataDic["Birthdate"] = dateFormatter.string(from: birthdate)
            }
            if let tel = pat.telecom?.first?.value {
                self.dataDic["Tel"] = tel
            }
            self.reloadTable()
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

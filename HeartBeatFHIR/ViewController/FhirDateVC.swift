//
//  FhirDateVC.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 1. 31..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//

import UIKit
import FHIR

class FhirDateVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var obss = [Observation]()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a hh:mm"
        return formatter
    }()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
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
        return self.obss.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fhirDateCell", for: indexPath)
        let obs = obss[indexPath.row]
        let date = obs.effectiveDateTime?.nsDate
        //        print("\n\n\(key)")
        let value = Int((obs.valueQuantity?.value) ?? 0)
        cell.textLabel?.text = "\(value)"
        cell.detailTextLabel?.text = self.dateFormatter.string(from: date!)
        
        
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
        if segue.identifier == "FHIRDateToFHIRDetail" {
            let destinationVC = segue.destination as! FHIRDetailVC
            let myIndexPath = self.tableView.indexPathForSelectedRow
            let low = (myIndexPath as NSIndexPath?)?.row
            let obs: Observation = self.obss[low!]
            destinationVC.obs = obs
        }
    }
 

}

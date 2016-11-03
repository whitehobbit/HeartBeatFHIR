//
//  FhirServerVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 10. 7..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import FHIR

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
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\n\n=================== FhirServerVC viewWillAppear===================")
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
        print("\n\n\(key)")
        cell.textLabel?.text = "\((self.heartRateDic[key]?.min())!) -  \((self.heartRateDic[key]?.max())!) (\((self.heartRateDic[key]?.count)!))"
        cell.detailTextLabel?.text = key

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, 
    canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getFHIR() {
        var user = prefs.dictionary(forKey: "userLoginInfo")!
        let search = Observation.search([
            "code" : "8867-4",
            "patient" : user["patientId"]!
            ])
        
        var heartRateDicTemp = [String: [Int]]()
        var heartRateKeyTemp = [String]()
        
        search.perform(fhirServer) { (bundle, error) in
            if error != nil {
                dump(error)
            } else {
                var bundleEntry = [BundleEntry]()
                var bund = bundle
                for entry in (bundle?.entry)! {
                    bundleEntry.append(entry)
                }
//                print("\n\ncount: \(bundleEntry.count)")
                
                while (bund?.link?.contains { element in
                    bund?.link?.removeAll()
                    if element.relation == "next" {
                        bund?.link?.append(element)
                        return true
                    } else {
                        return false
                    }
                    })! {
                        let url = (bund?.link?.first?.url?.absoluteURL)!
                        bund = FHIR.Bundle(json: FhirJsonManager.getFhirJson(url: url))
                        for entry in (bund?.entry)! {
                            bundleEntry.append(entry)
                        }
                }
//                print("\n\ncount: \(bundleEntry.count)")
                
                for entry in bundleEntry {
                    let json = FhirJsonManager.getFhirJson(url: (entry.fullUrl?.absoluteURL)!)
                    FhirJsonManager.printJsonPretty(json!)
                    let obs = Observation(json: json)
                    let date = self.dateFormatter.string(from: (obs.effectiveDateTime?.nsDate)!)
                    let value: Int = (obs.valueQuantity?.value?.intValue)!
//                    print("value: "); dump(value)
                    if heartRateDicTemp[date] == nil {
                        heartRateDicTemp[date] = [Int]()
                        self.obsDic[date] = [Observation]()
                    }
                    if !(heartRateKeyTemp.contains(date)) {
                        heartRateKeyTemp.append(date)
                    }
                    heartRateDicTemp[date]?.append(value)
                    self.obsDic[date]?.append(obs)
//                    print("heartRateDicTemp: \(date)"); dump(heartRateDicTemp)
//                    print("heartRateKeyTemp: "); dump(heartRateKeyTemp)
                }
                self.heartRateDicKey = heartRateKeyTemp.sorted().reversed()
                dump(self.heartRateDicKey)
                self.heartRateDic = heartRateDicTemp
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
}

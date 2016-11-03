//
//  SettingVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 10. 10..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit

class SettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 5
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicDisclosure", for: indexPath)
                cell.textLabel?.text = "계정 관리"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail", for: indexPath)
                cell.textLabel?.text = "현재 버전"
                cell.detailTextLabel?.text = currentVersion
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail", for: indexPath)
                cell.textLabel?.text = "최신 버전"
                cell.detailTextLabel?.text = currentVersion
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicDisclosure", for: indexPath)
            cell.textLabel?.text = "\(indexPath.section).\(indexPath.row)"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logout", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "section2", for: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "개인정보/고객지원"
        case 1:
            return "FHIR 서버 관리"
        case 2:
            return " "
        default:
            return "error"
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

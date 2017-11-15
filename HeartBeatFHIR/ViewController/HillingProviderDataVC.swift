//
//  HillingProviderDataVC.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 3. 23..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//

import UIKit
import SwiftyJSON

class HillingProviderDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView()
    var type: HPAProvider = .NONE
    var providerData = [String: [Date: String]]()
    var sources = [String]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = type.toString()
        self.setTableSetting()
        self.setActivityIndicator()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setData(uid, provider: self.type)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let cellCount = self.providerData[sources[section]] else {
            return 1
        }
        return cellCount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HillingProviderDataCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY. MM. dd HH:mm:ss"
        
        let source = self.sources[indexPath.section]
        var keys = [Date] (self.providerData[source]!.keys)
        keys.sort()
        keys.reverse()
        
        let key = keys[indexPath.row]
        let title = self.providerData[source]?[key]
        let detail = dateFormatter.string(from: key)
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(sources[section])"
    }
    
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }
    
    func refresh(sender: Any) {
        self.setData(uid, provider: self.type)
        refreshControl.endRefreshing()
    }
    
    // MARK: - 테이블셀 사이즈에 맞춰 테이블뷰 조절
    func tableViewAutoHeight() {
        if self.tableView.contentSize.height < self.tableView.frame.height {
            var frame: CGRect = self.tableView.frame
            frame.size.height = self.tableView.contentSize.height
            self.tableView.frame = frame
        }
    }
    
    func setTableSetting() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
        self.tableView.cornerRadius = 7.0
    }
    
    // MARK: - setData
    
    func setData(_ user: String = uid, provider: HPAProvider) {
        self.startActivityIndicator()
        
        HTOS_API.getHPAData(user: uid, provider: provider) { data in
            guard let data = data else {
                let error = makeErrorMsg(name: "GET_HPADATA_ERROR", msg: "해당하는 데이터가 존재하지 않습니다.")
                self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
                self.stopActivityIndicator()
                return
            }
            
            guard let count = data["count"].int, count != 0 else {
                let error = makeErrorMsg(name: "GET_HPADATA_ERROR", msg: "해당하는 데이터가 존재하지 않습니다.")
                self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
                self.stopActivityIndicator()
                return
            }
            
            guard let docs = data["documents"].array else {
                let error = makeErrorMsg(name: "GET_HPADATA_ERROR", msg: "documents가 존재하지 않습니다.")
                self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
                self.stopActivityIndicator()
                return
            }
            
            let dateFormatYYMMdd = DateFormatter()
            dateFormatYYMMdd.dateFormat = "YY. MM. dd"
            let dateFormatYYYYMMddHHmmss = DateFormatter()
            dateFormatYYYYMMddHHmmss.dateFormat = "YYYYMMddHHmmss"
            
            for doc in docs {
                guard  let document = Documents(doc) else {
                    continue
                }
                
                for result in document.results {
                    print(result.oid)
                    let tmp = result.oid.replacingOccurrences(of: "vitalsigns.", with: "")
                    print(tmp)
                    let date = dateFormatYYYYMMddHHmmss.date(from: tmp)!
                    
                    if !(self.sources.contains(result.type)) {
                        self.sources.append(result.type)
                        self.providerData[result.type] = [Date: String]()
                    }
                    self.providerData[result.type]?[date] = "\(result.description) \(result.value) \(result.unit)"
                }
            }
            
            self.sources.sort()
            self.stopActivityIndicator()
            self.reloadTable()
            
        }

//        HTOS_API.getHpaHandle(user: uid, provider: provider) { json in
//            guard let json = json else {
//                let error = makeErrorMsg(name: "GET_HPAHANDLE_ERROR", msg: "HpaHandle의 헤더와 파라미터를 확인하세요.")
//                self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
//                self.stopActivityIndicator()
//                return
//            }
//            guard let count = json["count"].int, let handles = json.rawString() else {
//                let error = makeErrorMsg(name: "GET_HPAHANDLE_ERROR", msg: "HpaHandle의 헤더와 파라미터를 확인하세요.")
//                self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
//                self.stopActivityIndicator()
//                return
//            }
//            guard count != 0 else {
//                let error = makeErrorMsg(name: "GET_HPAHANDLE_ERROR", msg: "해당하는 데이터가 존재하지 않습니다.")
//                print(error["error"])
//                self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
//                self.stopActivityIndicator()
//                return
//            }
//            
//            HTOS_API.getHpaData(user: user, handles: handles) { datas in
//            
//                print(handles)
//                guard let data = datas else {
//                    let error = makeErrorMsg(name: "GET_HPADATA_ERROR", msg: "해당하는 데이터가 존재하지 않습니다.")
//                    self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
//                    self.stopActivityIndicator()
//                    return
//                }
//                print(data)
//                guard let docs = data["documents"].array else {
//                    let error = makeErrorMsg(name: "GET_HPADATA_ERROR", msg: "documents가 존재하지 않습니다.")
//                    self.setAlert(title: error["error"]["name"].string!, message: error["error"]["message"].string!)
//                    self.stopActivityIndicator()
//                    return
//                }
//                
//                let dateFormatYYMMdd = DateFormatter()
//                dateFormatYYMMdd.dateFormat = "YY. MM. dd"
//                let dateFormatYYYYMMddHHmmss = DateFormatter()
//                dateFormatYYYYMMddHHmmss.dateFormat = "YYYYMMddHHmmss"
//                
//                for doc in docs {
//                    guard  let document = Documents(doc) else {
//                        continue
//                    }
//                    
//                    for result in document.results {
//                        print(result.oid)
//                        let tmp = result.oid.replacingOccurrences(of: "vitalsigns.", with: "")
//                        print(tmp)
//                        let date = dateFormatYYYYMMddHHmmss.date(from: tmp)!
//                        
//                        if !(self.sources.contains(result.type)) {
//                            self.sources.append(result.type)
//                            self.providerData[result.type] = [Date: String]()
//                        }
//                        self.providerData[result.type]?[date] = "\(result.description) \(result.value) \(result.unit)"
//                    }
//                }
//                
//                self.sources.sort()
//                self.stopActivityIndicator()
//                self.reloadTable()
//            }
//        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: - Alert
    func setAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
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

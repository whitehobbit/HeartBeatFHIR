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

let uid = "ict.demo.hongil4@gmail.com"
let huid = "ict.demo.hongil4@gmail.com"

class HillingPlatformVC: UIViewController {
    
    @IBOutlet weak var hpaButton: UIButton!
    
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var nhisBtn: UIButton!
    @IBOutlet weak var uracleBtn: UIButton!
    @IBOutlet weak var snuhBtn: UIButton!
    @IBOutlet weak var healthKitBtn: UIButton!
    @IBOutlet weak var lsBtn: UIButton!
    
    let activityIndicator = UIActivityIndicatorView()
    var providerData = [Date: String]()
    
    let dateFormatter: DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "YY. MM. dd"
        return dateFormat
    }()
    
    override func viewDidLoad() {
        print("============ HPAVC viewDidLoad() ============")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("=================== HPAVC viewWillAppear===================")
        automaticallyAdjustsScrollViewInsets = false
        super.viewWillAppear(animated)
//        self.getFHIR()
        connectHPA = prefs.bool(forKey: "connectHpa")
//        connectHPA = true
        if connectHPA {
            hpaButton.isEnabled = false
            btnView.isHidden = false
        } else {
            btnView.isHidden = true
        }
        setActivityIndicator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickHpaButton(_ sender: Any) {
        guard let sender = sender as? UIButton else {
            return
        }
        var isResistered = false
        HTOS_API.registerHpaToken(user: uid) { (json, flag) in
            print(json)
            isResistered = flag
//            print(isResistered)
            
            if isResistered {
                HTOS_API.connectRepository(user: uid) { (data) in

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
    
    @IBAction func btnClicked(_ sender: UIButton) {
        
        guard connectHPA else {
            errorAlert("힐링플랫폼 연동 후 사용하세요.")
            return
        }
//        getHPAData(sender: sender)
        self.performSegue(withIdentifier: "toHillingProvider", sender: sender)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let sender = sender as? UIButton else {
            return
        }
        
        let destinationVC = segue.destination as! HillingProviderDataVC
        var type: HPAProvider!
        
        switch sender {
        case nhisBtn:
            type = .NHIS
        case snuhBtn:
            type = .SNUH
        case uracleBtn:
            type = .URACLE
        case lsBtn:
            type = .LIFESEMANTICS
        case healthKitBtn:
            type = .HEALTHKIT
        default:
            type = .NONE
        }
        print("INFO: \(type.toString()) clicked")
        destinationVC.type = type
//        destinationVC.title = type.toString()
//        destinationVC.providerData = self.providerData
    }
    
    func getHPAData(_ user: String = huid, sender: UIButton) {
        var type: HPAProvider
        self.providerData.removeAll()
        startActivityIndicator()
        switch sender {
        case self.snuhBtn:
            type = .SNUH
        case self.uracleBtn:
            type = .URACLE
        case self.nhisBtn:
            type = .NHIS
        case self.healthKitBtn:
            type = .HEALTHKIT
        default:
            type = .NONE
        }
        print(type.rawData())
        print(type.docType())
        HTOS_API.getHPAData(user: user, provider: type) { datas in
//        HTOS_API.getHPAData(user: user, provider: type.rawData()) { datas in
            guard let datas = datas else {
                self.errorAlert("ERROR: callback is NULL")
                return
            }
//            print(datas)
            
            guard let docsArray = datas["documents"].array else {
                if let error = datas["error"] as JSON? {
                    self.errorAlert("\(error)")
                } else {
                    self.errorAlert("ERROR: \"documnets\" is not found")
                }
                self.stopActivityIndicator()
                return
            }
            let dateFormatYYMMdd = DateFormatter()
            dateFormatYYMMdd.dateFormat = "YY. MM. dd"
            let dateFormatYYYYMMddhhmmss = DateFormatter()
            dateFormatYYYYMMddhhmmss.dateFormat = "YYYYMMddHHmmss"
            
            for docs in docsArray {
                guard let results = docs["results"].array, let provider = docs["provider"].string else {
                    return
                }
                print("\(provider)")
                guard type == HPAProvider(provider) else {
                    print("ERROR: type is not match \(type)")
                    continue
                }
                
                print("INFO: type is matched \(type)")
                
                for result in results {
//                    guard result["type"].string == "심박" else {
//                        continue
//                    }
                    
                    guard let tmp = Results(result) else {
                        break
                    }
                    
                    let tt = tmp.oid.replacingOccurrences(of: "vitalsigns.", with: "")
                    let date = dateFormatYYYYMMddhhmmss.date(from: tt)
                    let dateStr = dateFormatYYMMdd.string(from: date!)
                    let val = "\(tmp.description) \(tmp.value) \(tmp.unit)"
                    
                    print("INFO: key: \(date) val: \(val)")
                    self.providerData[date!] = val
                }
            }
            self.stopActivityIndicator()
            self.performSegue(withIdentifier: "toHillingProvider", sender: sender)
        }
    }
    
    func errorAlert(_ msg: String = "Create Failed") {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
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

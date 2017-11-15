//
//  DetailHealthKitVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 29..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import HealthKit
import FHIR
import SwiftyJSON
import Alamofire

class DetailHealthKitVC: UIViewController {

    var heartRate: HKQuantitySample?
    var hk_data: HKQuantitySample?
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 a h:m"
        return formatter
    }()
    let activityIndicator = UIActivityIndicatorView()
    var deviceName: String = ""
    var sourceName: String = ""
    var value: Double = 0.0
    var unit: String = ""
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hk_dataTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let hk_data = hk_data else {
            return
        }
        var dataTypeText = ""
        var dataValText = ""
        switch hk_data.quantityType.identifier {
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            dataTypeText = "Heart Rate"
            self.value = hk_data.quantity.doubleValue(for: bpmUnit)
            dataValText = "\(Int(self.value))"
            self.unit = "bpm"
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            dataTypeText = "Weight"
            self.value = hk_data.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            dataValText = "\(Int(self.value))"
            self.unit = "Kg"
        default:
            break
        }
        
        deviceName = hk_data.device?.name ?? ""
        sourceName = hk_data.sourceRevision.source.name
        
        titleLabel?.text = dataTypeText + " Detail"
        hk_dataTypeLabel?.text = dataTypeText
        heartRateLabel?.text = dataValText
        dateLabel?.text = dateFormatter.string(from: hk_data.startDate)
        sourceLabel?.text = sourceName
        
//        deviceName = heartRate?.device?.name != nil ? "\((heartRate?.device?.name)!)" : ""
//        
//        sourceName = heartRate?.sourceRevision.source.name != nil ? "\((heartRate?.sourceRevision.source.name)!)" : ""
//        heartRateLabel?.text = "\(Int((heartRate?.quantity.doubleValue(for: bpmUnit))!))bpm"
//        
//        dateLabel?.text = "\(dateFormatter.string(from: (heartRate?.startDate)!))"
//        sourceLabel?.text = sourceName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setActivityIndicator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func makeJsonFhirObservation(_ hkData: HKQuantitySample?) -> Observation? {
        guard hkData?.quantityType.identifier != HKQuantityTypeIdentifier.heartRate.rawValue else {
            return nil
        }
        let heartRate2Int: Int = Int((hkData?.quantity.doubleValue(for: bpmUnit))!)
        let device: String = deviceName
        //        let source: String = (heartRate?.sourceRevision.source.name)!
        let date: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS:SZ"
            return dateFormatter.string(from: (hkData?.startDate)!)
        }()
        let code: CodeableConcept? = CodeableConcept(json: [
            "coding":[
                [
                    "system":"http://loinc.org",
                    "code":"8867-4",
                    "display":"Heart Rate"
                ]]
            ])
        let obs: Observation? = Observation(code: code!, status: "final")
        obs?.device = Reference(json: [
            "display": "\(device)"
            ])
        obs?.subject = Reference(json: ["reference" : "Patient/\(user["patientId"]!)"])
        obs?.valueQuantity = Quantity(json: [
            "value" : heartRate2Int,
            "unit" : "bpm"
            ])
        obs?.text = Narrative(div: "<div>Heart Rate, \(heartRate2Int) bpm</div>", status: "generated")
        obs?.meta = Meta(json: nil)
        obs?.meta?.versionId = "1"
        obs?.meta?.lastUpdated = Instant(date: FHIRDate.today, time: FHIRTime.now, timeZone: TimeZone.current)
        obs?.effectiveDateTime = DateTime(string: date)
        
        return obs
    }
    
    @IBAction func postAPIServer(_ sender: Any) {
        let serverUrl = "http://192.9.44.103:8080/api/hkfhir"
        let parameter = createHKFHIR(hk_data)!
        print(JSON(parameter))
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(serverUrl, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.setAlert(title: "SUCCESS", message: "성공")
            case .failure(let err):
                self.setAlert(title: "ERROR", message: err.humanized)
                
            }
        
//        let url = "http://192.9.44.103:8080"
//
//            Alamofire.request(url, method: .get).responseJSON{ response in
//                print(response.request?.description)
//                switch response.result {
//                case .success(let value):
//                    print(JSON(value))
//                case .failure(let err):
//                    print(err)
//
//            }
        }
        
        
//        startActivityIndicator()
        
    }
    
    @IBAction func clickUpload(_ sender: AnyObject) {
        startActivityIndicator()
        let obs = self.makeJsonFhirObservation(heartRate)
        obs?.create(fhirServer as! FHIRServer) { error in
            if (error != nil) {
                print("\n\(error)")
                self.stopActivityIndicator()
                let alert = UIAlertController(title: "Error", message: "전송 실패", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.stopActivityIndicator()
                let alert = UIAlertController(title: "Success", message: "전송 성공", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        FhirJsonManager.printJsonPretty((obs?.asJSON())!)
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
    
    func createHKFHIR(_ hkData: HKQuantitySample?) -> FHIRJSON? {
        guard let hkData = hkData else {
            return nil
        }
        let tmp = [
            "hkObservation": createHKObservation(hkData),
            "hkPatient": createHKPatient(hkData)
        ]
        return tmp
    }
    
    func createHKObservation(_ hkData: HKQuantitySample) -> FHIRJSON {
        let startDate: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS:SZ"
            return dateFormatter.string(from: (hkData.startDate))
        }()
        let endDate: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS:SZ"
            return dateFormatter.string(from: (hkData.endDate))
        }()
        
        let hkObservation = [
            "className": "\(type(of: hkData) )",
            "startDate": "\(startDate)",
            "endDate": "\(endDate)",
            "metaData": "\(hkData.metadata?.description ?? "nil")",
            "uuid": "\(hkData.uuid.uuidString)",
            "device": "\(hkData.device?.name)",
            "type": "\(hkData.sampleType.identifier)",
            "sourceRevision": "\(hkData.sourceRevision.source.name)",
            "value": self.value,
            "unit": "\(self.unit)"
            ] as [String : Any]
        
        return hkObservation
    }
    
    func createHKPatient(_ hkData: HKQuantitySample) -> FHIRJSON {
        
        let familyName = user["familyName"]
        var givenName = [String]()
        givenName.append(user["givenName"]!)
        var name: [String: Any] = ["family": familyName!, "given": givenName]
        var names = [Any]()
        names.append(name)
        let tel = user["telecom"]!
        let gender = user["gender"]!
        let birthDate = user["birthDate"]!
        let telecom = [ "system": "phone", "value": tel, "use": "mobile"]
        var telecoms = [Any]()
        telecoms.append(telecom)
        let address = ["city": "인천", "country": "대한민국"]
        var addresses = [Any]()
        addresses.append(address)
        let hkPatient = [
            "metaData": "nil",
            "name": names,
            "telecom": telecoms,
            "gender": gender,
            "birthDate": birthDate,
            "address": addresses
            ] as [String : Any]
        
        return hkPatient
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Alert
    func setAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

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
            dataValText = "\(Int(hk_data.quantity.doubleValue(for: bpmUnit)))"
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            dataTypeText = "Weight"
            dataValText = "\(Int(hk_data.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))))"
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
        startActivityIndicator()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

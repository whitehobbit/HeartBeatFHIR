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
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 a h:m"
        return formatter
    }()
    var deviceName: String = ""
    var sourceName: String = ""
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceName = heartRate?.device?.name != nil ?
        "\((heartRate?.device?.name)!)" : ""
        
        sourceName = heartRate?.sourceRevision.source.name != nil ? "\((heartRate?.sourceRevision.source.name)!)" : ""
        heartRateLabel?.text = "\(Int((heartRate?.quantity.doubleValue(for: bpmUnit))!))bpm"
        
        dateLabel?.text = "\(dateFormatter.string(from: (heartRate?.startDate)!))"
        sourceLabel?.text = sourceName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func makeJsonFhirObservation(_ heartrate: HKQuantitySample?) -> Observation? {
        let heartRate2Int: Int = Int((heartRate?.quantity.doubleValue(for: bpmUnit))!)
        let device: String = deviceName
        //        let source: String = (heartRate?.sourceRevision.source.name)!
        let date: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS:SZ"
            return dateFormatter.string(from: (heartRate?.startDate)!)
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
            "code" : "bpm"
            ])
        obs?.text = Narrative(div: "<div>Heart Rate, \(heartRate2Int) bpm</div>", status: "generated")
        obs?.meta = Meta(json: nil)
        obs?.meta?.versionId = "1"
        obs?.meta?.lastUpdated = Instant(date: FHIRDate.today, time: FHIRTime.now, timeZone: TimeZone.current)
        obs?.effectiveDateTime = DateTime(string: date)
        
        return obs
    }
    
    @IBAction func clickUpload(_ sender: AnyObject) {
        let obs = self.makeJsonFhirObservation(heartRate)
        obs?.create(fhirServer as! FHIRServer) { error in
            if (error != nil) {
                print("\n\(error)")
                let alert = UIAlertController(title: "Error", message: "Create Failed", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Success", message: "Create Succeed", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        FhirJsonManager.printJsonPretty((obs?.asJSON())!)
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

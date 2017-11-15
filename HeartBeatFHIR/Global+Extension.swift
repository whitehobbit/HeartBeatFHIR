//
//  Global+Extension.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 3. 29..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//

import Foundation
import FHIR
import SwiftyJSON
import HealthKit

// MARK: Global Var
// uesrInfo
let user = [ "id" : "test@test.com",
             "password" : "test",
             "patientId" : "7",
             "familyName": "홍", "givenName" : "길동",
             "telecom" : "82+ 10-7769-1093",
             "gender" : "남",
             "birthDate" : "1990-01-14" ]
var prefs = UserDefaults.standard
var currentVersion = "0.0.1"
var isLogined: Bool = false
// HealthKit
var bpmUnit = HKUnit(from: "count/min")

var heartRates = [HKQuantitySample]()
var weight = [HKQuantitySample]()
var healthKitManager: HealthKitManager? = HealthKitManager()
// FHIR
let baseUrl = "http://hitlab.gachon.ac.kr:8888/gachon-fhir-server/baseDstu2"
let fhirServer = FHIROpenServer(baseURL: URL(string: baseUrl)!)
//let fhirServer: Server = Server(baseURL: URL(string: baseUrl)!)
// HPA
var connectHPA: Bool = false

// MARK: - Global Method
func deleteSpace(_ toStr: String) -> String {
    return toStr.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
}

func makeErrorMsg(name: String, msg: String) -> JSON {
    let errorTime = { () -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }()
    let dic = ["error": ["time": "\(errorTime)", "name": "\(name)", "message": "\(msg)"]]
    let json = JSON(dic)
    return json
}

// MARK: Extension
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension HKSample {
    func toJSON() -> JSON? {
        var json: JSON?
        let tmp = ["class": "\(type(of: self))", "uuid": "\(self.uuid)", "metaData": "\(self.metadata)", "sourceRevision": "\(self.sourceRevision.source.name)", "device": "\(self.device?.name ?? nil)", "type": "\(self.sampleType.identifier)", "startDate": "\(self.startDate)", "endDate": "\(self.endDate)"]
        json = JSON(tmp)
        
        return json
    }
}

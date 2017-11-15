//
//  CCRManager.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 2. 16..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//

import Foundation
import HealthKit

open class CCRManager {

    func convertCCR(hkDatas: [HKQuantitySample]) -> CCRData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let ccrDocumentObjectId = CCRDocumentObjectID("HEALTHKIT.1.\(dateFormatter.string(from: Date())).1.01")
        let lang = CCRLanguage(CCRText("Korean"))
        let ver = CCRVersion("Korean")
        let dateTime = CCRDateTime(type: CCRType("Korean"), exactDateTime: CCRExactDateTime("1.01"), age: CCRAge(), approximateDateTime: CCRApproximateDateTime(), dateTimeRange: CCRDateTimeRange())
        let pat = CCRPatient(CCRActorID("1.\(dateFormatter.string(from: Date()))"))
        let from = CCRFrom(CCRActorLink(actorId: CCRActorID(), actorRole: CCRActorRole()))
        var results = [CCRResult]()

        for hkData in hkDatas {
//            let val = "\(Int(hkData.quantity.doubleValue(for: bpmUnit)))"
//            let date = hkData.startDate
//            results.append(createResultTag(date: date, value: val))
            let result = createResultTag(hkData)
            results.append(result)
        }
        let body = CCRBody(CCRVitalSigns(results))

        return CCRData(ccrDocumentObjectId: ccrDocumentObjectId, language: lang, version: ver, dateTime: dateTime, patient: pat, from: from, body: body)
    }

    func createCCR(date: Date, values: [String]) -> CCRData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let ccrDocumentObjectId = CCRDocumentObjectID("HEALTHKIT.1.\(dateFormatter.string(from: date)).1.01")
        let lang = CCRLanguage(CCRText("Korean"))
        let ver = CCRVersion("Korean")
        let dateTime = CCRDateTime(type: CCRType("Korean"), exactDateTime: CCRExactDateTime("1.01"), age: CCRAge(), approximateDateTime: CCRApproximateDateTime(), dateTimeRange: CCRDateTimeRange())
        let pat = CCRPatient(CCRActorID("1.\(dateFormatter.string(from: date))"))
        let from = CCRFrom(CCRActorLink(actorId: CCRActorID(), actorRole: CCRActorRole()))
        var results = [CCRResult]()
        for value in values {
            let result = createResultTag(date: date, value: value)
            results.append(result)
        }
        let body = CCRBody(CCRVitalSigns(results))
        
        print("\n\n\n\(dateTime.asString())\n\n\n")
        
        return CCRData(ccrDocumentObjectId: ccrDocumentObjectId, language: lang, version: ver, dateTime: dateTime, patient: pat, from: from, body: body)
    }
    
    func createCCR(date: Date, values: String ...) -> CCRData {
        return createCCR(date: date, values: values)
    }
    
    func createResultTag(date: Date, value: String) -> CCRResult {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let dateTime = CCRDateTime(type: CCRType("측정일시"), exactDateTime: CCRExactDateTime(date))
        let result = CCRResult(dataObjectId: CCRDataObjectID("vitalsigns.\(dateFormatter.string(from: date))"), dateTime: dateTime, type: CCRType("심박"), description: CCRDescription(CCRText("심박")), test: createTestTag(date: date, value: value))
        return result
    }
    
    func createResultTag(_ healthKitData: HKQuantitySample) -> CCRResult {
        
        var description: CCRDescription
        var value: String
        var unit: String
        
        if HKQuantityTypeIdentifier.heartRate.rawValue == healthKitData.quantityType.identifier {
            description = CCRDescription(CCRText("심박"))
            value = "\(Int(healthKitData.quantity.doubleValue(for: bpmUnit)))"
            unit = "bpm"
        } else {
            description = CCRDescription(CCRText("체중"))
            value = "\(Int(healthKitData.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))))"
            unit = "Kg"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let date = healthKitData.startDate
//        let value = "\(Int(healthKitData.quantity.doubleValue(for: bpmUnit)))"
        let device = healthKitData.device?.name ?? healthKitData.sourceRevision.source.name

        let dateTime = CCRDateTime(type: CCRType("측정일시"), exactDateTime: CCRExactDateTime(date))
        let result = CCRResult(dataObjectId: CCRDataObjectID("vitalsigns.\(dateFormatter.string(from: date))"), dateTime: dateTime, type: CCRType("\(device)"), description: description, test: createTestTag(date: date, value: value, unit: unit))
        return result
    }
    
    func createTestTag(date: Date, value: String, unit: String = "bpm") -> CCRTest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let ccrDataObjectId = CCRDataObjectID("test.\(dateFormatter.string(from: date))")
        let source = CCRSource(CCRActor(actorId: CCRActorID("2014.\(dateFormatter.string(from: date))"), actorRole: CCRActorRole(CCRText("Apple HealthKit"))))
        let testResult = CCRTestResult(value: CCRValue("\(value)"), units: CCRUnits(CCRUnit(unit)))
        return CCRTest(ccrDataObjectId: ccrDataObjectId, source: source, testResult: testResult)
    }
}

enum HKIdentifier {
    case heartrate, weight, none
    
    init(_ rawValue: HKQuantityTypeIdentifier) {
        switch rawValue {
        case HKQuantityTypeIdentifier.heartRate:
            self = .heartrate
        case HKQuantityTypeIdentifier.bodyMass:
            self = .weight
        default:
            self = .none
        }
    }
    
    func rawData() -> String {
        var tmp: String
        switch self {
        case .heartrate:
            tmp = "heartrate"
        case .weight:
            tmp = "weight"
        default:
            tmp = ""
        }
        return tmp
    }
    
    func toString() -> String {
        var tmp: String
        switch self {
        case .heartrate:
            tmp = "Heart Rate"
        case .weight:
            tmp = "Weight"
        default:
            tmp = ""
        }
        return tmp
    }
}

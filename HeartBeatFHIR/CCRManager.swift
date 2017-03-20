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
//    open static func createHeartRateCCR(value: String, date: Date = Date()) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYYMMddHHmmss"
//        var strDate = dateFormatter.string(from: date)
//        let dateFormat = DateFormatter()
//        dateFormat.dateFormat = "YYYY-MM-dd"
//        
//        var ccrForm =
//        "<ccr:ContinuityOfCareRecord xmlns:ccr='urn:astm-org:CCR' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation=''>" +
//            "<ccr:CCRDocumentObjectID>HEALTHKIT.1.\(strDate).1.01</ccr:CCRDocumentObjectID>" + //
//            "<ccr:Language>" +
//                "<ccr:Text>Korean</ccr:Text>" +
//            "</ccr:Language>" +
//            "<ccr:Version>Korean</ccr:Version>" +
//            "<ccr:DateTime>" +
//                "<ccr:Type>" +
//                    "<ccr:Text>Korean</ccr:Text>" +
//                "</ccr:Type>"
//                "<ccr:ExactDateTime>1.01</ccr:ExactDateTime>" + //
//                "<ccr:Age>" +
//                    "<ccr:Value/>" +
//                "</ccr:Age>" +
//                "<ccr:ApproximateDateTime>" +
//                    "<ccr:Text/>" +
//                "</ccr:ApproximateDateTime>" +
//                "<ccr:DateTimeRange>" +
//                    "<ccr:BeginRange>" +
//                        "<ccr:ExactDateTime/>" +
//                    "</ccr:BeginRange>" +
//                    "<ccr:EndRange>"
//                        "<ccr:ExactDateTime/>" +
//                    "</ccr:EndRange>" +
//                "</ccr:DateTimeRange>" +
//            "</ccr:DateTime>" +
//            "<ccr:Patient>" +
//                "<ccr:ActorID>1.\(strDate)</ccr:ActorID>" + //
//            "</ccr:Patient>" +
//            "<ccr:From>" +
//                "<ccr:ActorLink>" +
//                    "<ccr:ActorID></ccr:ActorID>" +
//                    "<ccr:ActorRole></ccr:ActorRole>" +
//                "</ccr:ActorLink>" +
//            "</ccr:From>" +
//            "<ccr:Body>" +
//                "<ccr:VitalSigns>" +
//                    "<ccr:Result>" +
//                        "<ccr:CCRDataObjectID>vitalsigns.\(strDate)</ccr:CCRDataObjectID>" + //
//                        "<ccr:DateTime>" +
//                            "<ccr:Type>" +
//                                "<ccr:Text>측정일시</ccr:Text>" +
//                            "</ccr:Type>" +
//                            "<ccr:ExactDateTime>\(dateFormat.string(from: date))</ccr:ExactDateTime>" + //
//                            "<ccr:Age>" +
//                                "<ccr:Value/>" +
//                            "</ccr:Age>" +
//                            "<ccr:ApproximateDateTime>" +
//                                "<ccr:Text/>" +
//                            "</ccr:ApproximateDateTime>" +
//                            "<ccr:DateTimeRange>" +
//                                "<ccr:BeginRange>" +
//                                    "<ccr:ExactDateTime/>" +
//                                "</ccr:BeginRange>" +
//                                "<ccr:EndRange>" +
//                                    "<ccr:ExactDateTime/>" +
//                                "</ccr:EndRange>" +
//                            "</ccr:DateTimeRange>" +
//                        "</ccr:DateTime>" +
//                        "<ccr:Type>" +
//                            "<ccr:Text>심박</ccr:Text>" +
//                        "</ccr:Type>" +
//                        "<ccr:Description>" +
//                            "<ccr:Text>심박</ccr:Text>" +
//                        "</ccr:Description>" +
//                        "<ccr:Source/>" +
//                        "<ccr:Test>" +
//                            "<ccr:CCRDataObjectID>test.20170209000001</ccr:CCRDataObjectID>" +
//                            "<ccr:Source>" +
//                                "<ccr:Actor>" +
//                                    "<ccr:ActorID>2014.\(strDate)</ccr:ActorID>" +
//                                    "<ccr:ActorRole>" +
//                                        "<ccr:Text>Apple HealthKit</ccr:Text>" +
//                                    "</ccr:ActorRole>" +
//                                "</ccr:Actor>" +
//                            "</ccr:Source>" +
//                            "<ccr:TestResult>" +
//                                "<ccr:Value>\(value)</ccr:Value>" +
//                                "<ccr:Units>" +
//                                    "<ccr:Unit>bpm</ccr:Unit>" +
//                                "</ccr:Units>" +
//                            "</ccr:TestResult>" +
//                        "</ccr:Test>" +
//                    "</ccr:Result>" +
//                "</ccr:VitalSigns>" +
//            "</ccr:Body>" +
//        "</ccr:ContinuityOfCareRecord>"
//        
//        return ccrForm
//    }
//    
//    open static func createVitalSigns(results: String ...) -> String {
//        var vitalsign = ""
//        
//        results.reduce(0) { (result, str) in
//            vitalsign = vitalsign + str
//            return result
//        }
//        
//        return vitalsign
//    }
    
    func convertCCR(hkDatas: [HKQuantitySample]) -> CCRData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddhhmmss"
        let ccrDocumentObjectId = CCRDocumentObjectID("HEALTHKIT.1.\(dateFormatter.string(from: Date())).1.01")
        let lang = CCRLanguage(CCRText("Korean"))
        let ver = CCRVersion("Korean")
        let dateTime = CCRDateTime(type: CCRType("Korean"), exactDateTime: CCRExactDateTime("1.01"), age: CCRAge(), approximateDateTime: CCRApproximateDateTime(), dateTimeRange: CCRDateTimeRange())
        let pat = CCRPatient(CCRActorID("1.\(dateFormatter.string(from: Date()))"))
        let from = CCRFrom(CCRActorLink(actorId: CCRActorID(), actorRole: CCRActorRole()))
        var results = [CCRResult]()

        for hkData in hkDatas {
            let val = "\(Int(hkData.quantity.doubleValue(for: bpmUnit)))"
            let date = hkData.startDate
            results.append(createResultTag(date: date, value: val))
        }
        let body = CCRBody(CCRVitalSigns(results))

        return CCRData(ccrDocumentObjectId: ccrDocumentObjectId, language: lang, version: ver, dateTime: dateTime, patient: pat, from: from, body: body)
    }

    func createCCR(date: Date, values: [String]) -> CCRData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddhhmmss"
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
        dateFormatter.dateFormat = "YYYYMMddhhmmss"
        let dateTime = CCRDateTime(type: CCRType("측정일시"), exactDateTime: CCRExactDateTime(date))
        let result = CCRResult(dataObjectId: CCRDataObjectID("vitalsigns.\(dateFormatter.string(from: date))"), dateTime: dateTime, type: CCRType("심박"), description: CCRDescription(CCRText("심박")), test: createTestTag(date: date, value: value))
        return result
    }
    
    func createTestTag(date: Date, value: String) -> CCRTest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddhhmmss"
        let ccrDataObjectId = CCRDataObjectID("test.\(dateFormatter.string(from: date))")
        let source = CCRSource(CCRActor(actorId: CCRActorID("2014.\(dateFormatter.string(from: date))"), actorRole: CCRActorRole(CCRText("Apple HealthKit"))))
        let testResult = CCRTestResult(value: CCRValue("\(value)"), units: CCRUnits(CCRUnit("bpm")))
        return CCRTest(ccrDataObjectId: ccrDataObjectId, source: source, testResult: testResult)
    }
}

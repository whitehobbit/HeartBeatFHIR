//
//  CCRTags.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 2. 27..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//
import Foundation

open class CCRTagAbstractBase: CustomStringConvertible {
    
    open class var tagType: String {
        get { return "ccr:CCRTagAbstractBase" }
    }
    
    open var description: String {
        return "<\(type(of: self).tagType)>"
    }
    
    open func asString() -> String {
        let str = "<\(type(of: self).tagType)></\(type(of: self).tagType)>"
        return str
    }
    
    open func prettyPrint() -> String {
        return self.asString()
    }
}

open class CCRTagBase: CCRTagAbstractBase {
    
    open override class var tagType: String {
        get { return "ccr:CCRTagBase" }
    }
    
    var value: String
    
    override init() {
        self.value = ""
    }
    
    init(_ value: String) {
        self.value = value
    }
    
    override open func asString() -> String {
//        guard value != "" else {
//            let str = "<\(type(of: self).tagType)/>"
//            return str
//        }
        let str = "<\(type(of: self).tagType)>\(self.value)</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        return self.asString()
    }
}

open class CCRText: CCRTagBase {
    
    open override class var tagType: String {
        get { return "ccr:Text" }
    }
}

open class CCRUnit: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:Unit" }
    }
}

open class CCRDocumentObjectID: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:CCRDocumentObjectID" }
    }
}

open class CCRDataObjectID: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:CCRDataObjectID" }
    }
}

open class CCRActorID: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:ActorID" }
    }
}

open class CCRVersion: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:Version" }
    }
}

open class CCRExactDateTime: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:ExactDateTime" }
    }
    
    override init() {
        super.init()
        self.value = ""
    }
    
    init(_ date: Date = Date()) {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.value = "\(dateFormatter.string(from: date))"
    }
    override init(_ value: String = "") {
        super.init()
        self.value = value
    }
}

open class CCRValue: CCRTagBase {
    
    override open class var tagType: String {
        get { return "ccr:Value" }
    }
}

open class CCRVitalSigns: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:VitalSigns" }
    }
    
    var resultTags: [CCRResult]
    
    override init() {
        resultTags = [CCRResult]()
    }
    
    init(_ results: CCRResult ...) {
        resultTags = results
    }
    
    init(_ results: [CCRResult]) {
        resultTags = results
    }
    
    override open func asString() -> String {
        var str =  "<\(type(of: self).tagType)>"
        for result in resultTags {
            str = str + result.asString()
        }
        str = str + "</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        var str =  "<\(type(of: self).tagType)>\n"
        for result in resultTags {
            str = str + result.prettyPrint() + "\n"
        }
        str = str + "</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRPatient: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Patient" }
    }
    
    var actorIDTag: CCRActorID
    
    init(_ actorId: CCRActorID = CCRActorID()) {
        actorIDTag = actorId
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(actorIDTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(actorIDTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRFrom: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:From" }
    }
    
    var actorLinkTag: CCRActorLink
    
    init(_ actorLink: CCRActorLink = CCRActorLink()) {
        actorLinkTag = actorLink
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(actorLinkTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(actorLinkTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRActorLink: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:ActorLink" }
    }
    
    var actorIDTag: CCRActorID
    var actorRoleTag: CCRActorRole
    
    init(actorId: CCRActorID = CCRActorID(), actorRole: CCRActorRole = CCRActorRole()) {
        actorIDTag = actorId
        actorRoleTag = actorRole
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(actorIDTag.asString())\(actorRoleTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(actorIDTag.prettyPrint())\n\(actorRoleTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str    }
}

open class CCRBody: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Body" }
    }
    
    var vitalSignsTag: CCRVitalSigns
    
    init(_ vitalSigns: CCRVitalSigns = CCRVitalSigns()) {
        vitalSignsTag = vitalSigns
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(vitalSignsTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(vitalSignsTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRResult: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Result" }
    }
    
    var dataObjectIDTag: CCRDataObjectID
    var dateTimeTag: CCRDateTime
    var typeTag: CCRType
    var descriptionTag: CCRDescription
    var sourceTag: CCRSource
    var testTag: CCRTest
    
    init(dataObjectId: CCRDataObjectID = CCRDataObjectID(),
         dateTime: CCRDateTime = CCRDateTime(),
         type: CCRType = CCRType(),
         description: CCRDescription = CCRDescription(),
         source: CCRSource = CCRSource(),
         test: CCRTest = CCRTest()) {
        dataObjectIDTag = dataObjectId
        dateTimeTag = dateTime
        typeTag = type
        descriptionTag = description
        sourceTag = source
        testTag = test
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(dataObjectIDTag.asString())\(dateTimeTag.asString())\(typeTag.asString())\(descriptionTag.asString())\(sourceTag.asString())\(testTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(dataObjectIDTag.prettyPrint())\n\(dateTimeTag.prettyPrint())\n\(typeTag.prettyPrint())\n\(descriptionTag.prettyPrint())\n\(sourceTag.prettyPrint())\n\(testTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRSource: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Source" }
    }
    
    var actorTag: CCRActor
    
    init(_ actor: CCRActor = CCRActor()) {
        actorTag = actor
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(actorTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(actorTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRActor: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Actor" }
    }
    
    var actorIDTag: CCRActorID
    var actorRoleTag: CCRActorRole
    
    init(actorId: CCRActorID = CCRActorID(), actorRole: CCRActorRole = CCRActorRole()) {
        actorIDTag = actorId
        actorRoleTag = actorRole
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(actorIDTag.asString())\(actorRoleTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(actorIDTag.prettyPrint())\n\(actorRoleTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRActorRole: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:ActorRole" }
    }
    
    var textTag: CCRText
    
    init(_ text: CCRText = CCRText()) {
        textTag = text
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(textTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(textTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRDateTime: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:DateTime" }
    }
    
    var typeTag: CCRType
    var exactDateTimeTag: CCRExactDateTime
    var ageTag: CCRAge
    var approximateDateTimeTag: CCRApproximateDateTime
    var dateTimeRangeTag: CCRDateTimeRange
    
    init(type: CCRType = CCRType(), exactDateTime: CCRExactDateTime = CCRExactDateTime(),
         age: CCRAge = CCRAge(), approximateDateTime: CCRApproximateDateTime = CCRApproximateDateTime(),
         dateTimeRange: CCRDateTimeRange = CCRDateTimeRange()) {
        typeTag = type
        exactDateTimeTag = exactDateTime
        ageTag = age
        approximateDateTimeTag = approximateDateTime
        dateTimeRangeTag = dateTimeRange
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(typeTag.asString())\(exactDateTimeTag.asString())\(ageTag.asString())\(approximateDateTimeTag.asString())\(dateTimeRangeTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(typeTag.prettyPrint())\n\(exactDateTimeTag.prettyPrint())\n\(ageTag.prettyPrint())\n\(approximateDateTimeTag.prettyPrint())\n\(dateTimeRangeTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRApproximateDateTime: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:ApproximateDateTime" }
    }
    
    var textTag: CCRText
    
    init(_ text: CCRText = CCRText()) {
        textTag = text
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(textTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(textTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRDateTimeRange: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:DateTimeRange" }
    }
    
    var beginRangeTag: CCRBeginRange
    var endRangeTag: CCREndRange
    
    init(beginRange: CCRBeginRange = CCRBeginRange(), endRange: CCREndRange = CCREndRange()) {
        beginRangeTag = beginRange
        endRangeTag = endRange
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(beginRangeTag.asString())\(endRangeTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(beginRangeTag.prettyPrint())\n\(endRangeTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRBeginRange: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:BeginRange" }
    }
    
    var exactDateTimeTag: CCRExactDateTime
    
    init(_ exactDateTime: CCRExactDateTime = CCRExactDateTime()) {
        exactDateTimeTag = exactDateTime
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(exactDateTimeTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(exactDateTimeTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCREndRange: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:EndRange" }
    }
    
    var exactDateTimeTag: CCRExactDateTime
    
    init(_ exactDateTime: CCRExactDateTime = CCRExactDateTime()) {
        exactDateTimeTag = exactDateTime
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(exactDateTimeTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(exactDateTimeTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRAge: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Age" }
    }
    
    var valueTage: CCRValue
    
    init(_ value: CCRValue = CCRValue()) {
        valueTage = value
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(valueTage.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(valueTage.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRType: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Type" }
    }
    
    var textTag: CCRText
    
    init(_ text: CCRText = CCRText()) {
        textTag = text
    }
    
    init(_ value: String) {
        textTag = CCRText(value)
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(textTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(textTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRUnits: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Units" }
    }
    
    var unitTag: [CCRUnit]
    
    override init() {
        unitTag = [CCRUnit]()
    }
    
    init(_ unit: CCRUnit ...) {
        unitTag = unit
    }
    
    override open func asString() -> String {
        var str = "<\(type(of: self).tagType)>"
        for unit in unitTag {
            str = str + unit.asString()
        }
        str = str + "</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        var str = "<\(type(of: self).tagType)>"
        for unit in unitTag {
            str = str + "\n" + unit.prettyPrint()
        }
        str = str + "\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRDescription: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Description" }
    }
    
    var textTag: CCRText
    
    init(_ text: CCRText = CCRText()) {
        textTag = text
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(textTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(textTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
        
    }
}

open class CCRTest: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Test" }
    }
    
    var ccrDataObjectIDTag: CCRDataObjectID
    var sourceTag: CCRSource
    var testResultTag: CCRTestResult
    
    init(ccrDataObjectId: CCRDataObjectID = CCRDataObjectID(), source: CCRSource = CCRSource(), testResult: CCRTestResult = CCRTestResult()) {
        ccrDataObjectIDTag = ccrDataObjectId
        sourceTag = source
        testResultTag = testResult
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(ccrDataObjectIDTag.asString())\(sourceTag.asString())\(testResultTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(ccrDataObjectIDTag.prettyPrint())\n\(sourceTag.prettyPrint())\n\(testResultTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRTestResult: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:TestResult" }
    }
    
    var valueTag: CCRValue
    var unitsTag: CCRUnits
    
    init(value: CCRValue = CCRValue(), units: CCRUnits = CCRUnits()) {
        valueTag = value
        unitsTag = units
    }
    
    override open func asString() -> String {
        let str = "<\(type(of: self).tagType)>\(valueTag.asString())\(unitsTag.asString())</\(type(of: self).tagType)>"
        return str
    }
    
    override open func prettyPrint() -> String {
        let str = "<\(type(of: self).tagType)>\n\(valueTag.prettyPrint())\n\(unitsTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return str
    }
}

open class CCRLanguage: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:Language" }
    }
    
    var textTag: CCRText
    
    override init() {
        self.textTag = CCRText()
    }
    
    init(_ text: CCRText = CCRText()) {
        textTag = text
    }
    
    init(_ value: String) {
        self.textTag = CCRText(value)
    }
    
    override open func asString() -> String {
        let ccr = "<\(type(of: self).tagType)>\(textTag.asString())</\(type(of: self).tagType)>"
        return ccr
    }
    
    override open func prettyPrint() -> String {
        let ccr = "<\(type(of: self).tagType)>\n\(textTag.prettyPrint())\n</\(type(of: self).tagType)>"
        return ccr
    }
}

open class CCRData: CCRTagAbstractBase {
    
    override open class var tagType: String {
        get { return "ccr:ContinuityOfCareRecord" }
    }
    
    var ccrDocumentObjectIDTag: CCRDocumentObjectID
    var languageTag: CCRLanguage
    var versionTag: CCRVersion
    var dateTimeTag: CCRDateTime
    var patientTag: CCRPatient
    var fromTag: CCRFrom
    var bodyTag: CCRBody
    
    init(ccrDocumentObjectId: CCRDocumentObjectID = CCRDocumentObjectID(), language: CCRLanguage = CCRLanguage(),
         version: CCRVersion = CCRVersion(), dateTime: CCRDateTime = CCRDateTime(),
         patient: CCRPatient = CCRPatient(), from: CCRFrom = CCRFrom(), body: CCRBody = CCRBody()) {
        ccrDocumentObjectIDTag = ccrDocumentObjectId
        languageTag = language
        versionTag = version
        dateTimeTag = dateTime
        patientTag = patient
        fromTag = from
        bodyTag = body
    }
    
    override open func asString() -> String {
        let str =
            "<?xml version='1.0' encoding='UTF-8'?><\(type(of: self).tagType) xmlns:ccr='urn:astm-org:CCR' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation=''>" +
                ccrDocumentObjectIDTag.asString() +
                languageTag.asString() +
                versionTag.asString() +
                dateTimeTag.asString() +
                patientTag.asString() +
                fromTag.asString() +
                bodyTag.asString() +
        "</\(type(of: self).tagType)>"
        
        return str
    }
    
    override open func prettyPrint() -> String {
        let str =
            "<\(type(of: self).tagType) xmlns:ccr='urn:astm-org:CCR' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation=''>" + "\n" +
                ccrDocumentObjectIDTag.prettyPrint() + "\n" +
                languageTag.prettyPrint() + "\n" +
                versionTag.prettyPrint() + "\n" +
                dateTimeTag.prettyPrint() + "\n" +
                patientTag.prettyPrint() + "\n" +
                fromTag.prettyPrint() + "\n" +
                bodyTag.prettyPrint() + "\n" +
        "</\(type(of: self).tagType)>"
        
        return str
    }
}

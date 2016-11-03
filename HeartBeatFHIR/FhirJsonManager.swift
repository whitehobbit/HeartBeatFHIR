//
//  JSON.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 26..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import Foundation
import FHIR

class FhirJsonManager {
    
    public static func printJsonPretty(_ json: FHIRJSON) {
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print(error)
        }
    }
    
    public static func fhirObservationFromUrl(_ urlPath: String) -> Observation? {
        var data: Data
        var json: FHIRJSON?
        do {
            data = try Data(contentsOf: URL(string: urlPath)!)
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? FHIRJSON
        } catch {
            print(error)
        }
        return Observation(json: json)
    }
    
    public static func getFhirJson(url: URL) -> FHIRJSON? {
        var json: FHIRJSON?
        var data: Data
        do {
            data = try Data(contentsOf: url)
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? FHIRJSON
        } catch {
            print(error)
        }
        return json
    }
    
    public static func getFhirJson(path: String) -> FHIRJSON? {
        var json: FHIRJSON?
        var data: Data
        do {
            data = try Data(contentsOf: URL(string: path)!)
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? FHIRJSON
        } catch {
            print(error)
        }
        return json
    }
}

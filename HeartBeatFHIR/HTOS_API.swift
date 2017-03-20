//
//  HTOS_API.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 2. 9..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import WebKit

class HTOS_API {
    static let hpaToken = HPA_TOKEN()
    static let fhirToken = FHIR_TOKEN()
    fileprivate static let hpadaptorBaseUrl = "https://ict.idles.co.kr:8445/htos-api/hpadaptor"
    fileprivate static let fhirBaseUrl = "https://ict.idles.co.kr:8445/htos-fhir/fhir"
    
    static func registerHpaToken(user: String?, completion: @escaping (_ data: JSON?, _ flag: Bool) -> ()) {
        guard let user = user else {
            return
        }
        guard let url = URL(string: "\(hpadaptorBaseUrl)/register/\(user)") else {
            return
        }
        var flag = false
        let headers: HTTPHeaders = [
            "Authorization": "\(hpaToken.token_type) \(hpaToken.access_token)",
//            "Host": "ict.idles.co.kr:8445",
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
        ]

        Alamofire.request(url, method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
//                let statusCode = (response.response?.statusCode)!
//                switch statusCode {
//                case 201:
//                    debugPrint("401: \(json)")
//                case 202:
//                    debugPrint("402: \(json)")
//                default:
//                    debugPrint("default: \(json)")
//                }
                print(json)
                completion(json, true)
            case .failure(let error):
                print(error)
                completion(nil, false)
            }
        }
    }
    
    static func connectRepository(user: String?, repository: String = "dropbox", completion: @escaping (_ data: String?) -> ()) {
        guard let user = user else {
            return
        }
        guard let url = URL(string: "\(hpadaptorBaseUrl)/auth/v2/\(user)/approve/url?repository=\(repository)") else {
            return
        }
        let headers: HTTPHeaders = [
            "Host": "ict.idles.co.kr:8445",
            "Authorization": "\(HTOS_API.hpaToken.token_type) \(HTOS_API.hpaToken.access_token)"
        ]
        Alamofire.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json["callback"].string)
            case .failure(let error):
                completion("\(error)")
            }
        }
    }
    
    static func uploadHPA(name: String, user: String?, ccr: CCRData, completion: @escaping (_ data: JSON?) -> ()) {
        guard let user = user else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        
        guard let date = ccr.bodyTag.vitalSignsTag.resultTags.first?.dateTimeTag.exactDateTimeTag.value else {
            completion("\"error\":\"date error\"")
            return
        }
        
        let url: URL = URL(string: "\(hpadaptorBaseUrl)/repository/\(user)/documents")!
        let headers: HTTPHeaders = [
            "Authorization": "\(HTOS_API.hpaToken.token_type) \(HTOS_API.hpaToken.access_token)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters = [
            "encoding": "[\"utf-8\"]",
            "sid": "hk1011",
            "basefilter": "{\"name\":\"\(name) hk.\(dateFormatter.string(from: Date()))\",\"mode\":\"overwrite\",\"format\":\"xml\",\"uid\":\"\(user)\", \"provider\":\"hk\", \"type\":\"ccr\", \"taglist\":[ \"HealthKit\",\"healthcare\", \"만성질환관리\", \"심박\", \"heart rate\" ], \"datetime\":{\"datetimernage\":{\"begin\": \"\(date) 00:00:00\", \"end\": \"\(date) 23:59:59\"}, \"exctdatetime\":\"\(date) 12:00:00\" } }",
            "document": "\(ccr.asString())"
        ]
        
//        print(parameters)
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { response in
//            print(String(data: (response.request?.httpBody)!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
//                print(json)
                completion(json)
            case .failure(let error):
                completion("\"error\":\"response error\"")
            }
        }
    }
    
    static func getHPAData(user: String?, completion: @escaping (_ datas: JSON?) -> ()) {
        guard let user = user else {
            return
        }
        getHPAHandle(user: user) { datas in
            guard let json = datas else {
                let res = JSON("Error: callback == nil")
                completion(res)
                return
            }
            
            let date = { () -> String in 
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
                return dateFormatter.string(from: Date())
            }()
            
            let handles = deleteSpace(json.rawString()!)
            
            guard let providerHandles = datas?["handles"] else {
                let res = JSON("Error: handles not exist")
                completion(res)
                return
            }
            guard let url = URL(string: "\(hpadaptorBaseUrl)/repository/\(user)/ccr/values") else {
                let res = JSON("Error: URL Error")
                completion(res)
                return
            }
            
            //let url: URL! = URL(string: "https://ict.idles.co.kr:8445/htos-api/hpadaptor/repository/ict.demo.hongil4@gmail.com/ccr/values")
            let headers: HTTPHeaders = [
                "Authorization": "\(HTOS_API.hpaToken.token_type) \(HTOS_API.hpaToken.access_token)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            let params = [
                "handle": handles,
                "search":"{\"period\":{\"from\":\"2014-03-01 12:11:32\",\"to\":\"\(date)\" },\"category\":[\"vitalsigns\"]}",
                "encoding":"[\"utf-8\"]"
            ]
            
            Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json)
                case .failure(let error):
                    completion(JSON(error))
                }
            }
        }
    }
    
    static func getHPAHandle(user: String?, completion: @escaping (_ datas: JSON?) -> ()) {
        
        print("Info: getHPAHandle")
        guard let user = user else {
            print("Error: user == nil")
            return
        }
        
        let url = URL(string: "\(hpadaptorBaseUrl)/repository/\(user)/handles")!
        
        let headers: HTTPHeaders = [
            "Authorization": "\(HTOS_API.hpaToken.token_type) \(HTOS_API.hpaToken.access_token)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let param = [
            "filter": "(&(xdt>=201401010000+0900)(htype=ccr))",
            "base": "huid=\(user),dc=htos",
            "verbose": "false"
        ]
        
        Alamofire.request(url, method: .post, parameters: param, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                completion(nil)
            }
        }
    }
    
    static func getHPADataWithFHIR(user: String?, completion: @escaping (_ datas: JSON?) -> ()) {
        guard let user = user else {
            completion(nil)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let headers: HTTPHeaders = [
            "Authorization": "\(HTOS_API.fhirToken.token_type) \(HTOS_API.fhirToken.access_token)",
            "Content-Type": "application/xml+fhir;charset=UTF-8"
        ]
        print(headers["Authorization"])
//        let url = URL(string: "https://ict.idles.co.kr:8445/htos-fhir/fhir/Observation?identifier=\(user)&date=>=2009-01-01&date=<\(dateFormatter.string(from: Date()))")!
        let url = URL(string: "\(fhirBaseUrl)/Observation?")!
        let param = [
            "identifier": "ict.demo.hongil4@gmail.com",
            "date": ">=2009-01-01date:<2017-03-07"
        ]
        print(url.absoluteString)
        Alamofire.request(url, method: .get, parameters: param, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                completion(nil)
            }
        }
    }
    
    
}

struct HPA_TOKEN {
    let access_token = "ab693ee6-c064-4f53-913e-0b92f8dc2a2e"
    let token_type = "bearer"
    let refresh_token = "be782012-3819-40e5-abbc-18bbc96496b2"
    let expires_in = 31103999
    let scope = " write read"
}

struct FHIR_TOKEN {
    let access_token = "ba872c9f-466c-4e25-8e70-def28581ca57"
    let token_type = "bearer"
    let refresh_token = "5b23a56d-073d-4d3e-84f9-035de1ebaaf5"
    let expires_in = 31103999
    let scope = " write read"
}

class InAppDropBoxConnectorController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var cancelButton: UIBarButtonItem?
    
    var startURL: URL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && isViewLoaded {
                loadURL(startURL!)
            }
        }
    }
    var endURL: URL?
    var successHandler: ((_ isSucceed: Bool) -> Void) = {_ in false}
    var onSuccess: ((_ isSucceed: Bool) -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(URL: Foundation.URL, successHandler: @escaping ((_ isSucceed: Bool) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.startURL = URL
        
        self.successHandler = successHandler
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dropbox 연결"
        self.webView = WKWebView(frame: self.view.bounds)
        
        indicator.center = view.center
        self.webView.addSubview(indicator)
        indicator.startAnimating()
        
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self
        
        self.view.backgroundColor = UIColor.white
        
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InAppDropBoxConnectorController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            if nil != startURL {
                loadURL(startURL!)
            } else {
                webView.loadHTMLString("There is no 'startURL'", baseURL: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        debugPrint(webView.url?.host)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        self.endURL = url
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = self.endURL else {
            return
        }
//        debugPrint("didReceive: url: \(url)")
        let jsString = "" + "document.getElementsByTagName('PRE')[0].innerHTML;"
        webView.evaluateJavaScript(jsString) { (result, error) in
            if error == nil {
                let json = JSON(result)
                let err = json["error"]
                
                if err != nil {
                    debugPrint(JSON(err))
                } else {
                    webView.stopLoading()
                    self.successHandler(true)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                debugPrint(json)
            } else {
                debugPrint("didReceive: \n    error: \(error)")
                self.dismiss(true, animated: true)
            }
        }
    }
    
    func cancel(_ sender: AnyObject?) {
        dismiss(true, animated: (sender != nil))
    }
    
    func dismiss(_ asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        successHandler(false)
        presentingViewController?.dismiss(animated: animated, completion: nil)
    }
    
    func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
}

func deleteSpace(_ toStr: String) -> String {
    return toStr.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
}

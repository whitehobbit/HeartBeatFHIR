//
//  LoginVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 22..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import FHIR
import SwiftyJSON

class LoginVC: UIViewController {

    var userLoginInfo = [String: Any]()
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.

    }
    
    @IBAction func clickedlogin(_ sender: AnyObject) {
//        isLogined = true;
        isLogined = checkLogin()
        if isLogined {
            self.performSegue(withIdentifier: "toTabbarVC", sender: self)
        }
    }
    
    func checkLogin() -> Bool {
        idTextField?.text = "test@test.com"; passwordTextField?.text = "test"
        
        guard (idTextField?.text == user["id"] && passwordTextField?.text == user["password"]) else {
            return false
        }
        
        var userLoginInfo = [String: Any]()
        self.userLoginInfo["id"] = idTextField?.text
        self.userLoginInfo["password"] = passwordTextField?.text
        self.userLoginInfo["pId"] = "7"
        self.userLoginInfo["autoLogin"] = true
        self.userLoginInfo["name"] = "이진기"
//        prefs.setValue(self.userLoginInfo, forKey: "userLoginInfo")
        
        prefs.set("7", forKey: "patientId")
        prefs.set("이진기", forKey: "name")
        prefs.set(false, forKey: "autoLogin")
        prefs.set(idTextField?.text, forKey: "id")
        prefs.set(passwordTextField?.text, forKey: "password")
        prefs.set(false, forKey: "connectHpa")
        
//        prefs.set(self.userLoginInfo, forKey: "userLoginInfo")
//        print(prefs.dictionary(forKey: "userLoginInfo"))
        return true
    }
    
    func getFhirPatient() -> (id: String, pId: String, name: String, gender: String, birthDate: String, phone: String)? {
        
        print("========= getFhirPatient =========")
        var pat: Patient?
        var userInfo: (id: String, pId: String, name: String, gender: String, birthDate: String, phone: String)?
        print(user)
        
        guard let pId = self.userLoginInfo["pid"] as! String?, let id = self.userLoginInfo["id"] as! String? else {
            return nil
        }
        
        Patient.read(pId, server: fhirServer) { resource, error in
            if error != nil {
                dump(error)
            }
            else {
                pat = resource as! Patient?
//                dump(pat)
                let dateformatter: DateFormatter = DateFormatter()
                dateformatter.dateFormat = "yyyy. MM. dd."
                
                let family: String = pat?.name?.first?.family?.first != nil ? (pat?.name?.first?.family?.first)! : ""
                let given: String = pat?.name?.first?.given?.first != nil ? (pat?.name?.first?.given?.first)! : ""
                userInfo?.name = family + given
                userInfo?.gender = pat?.gender != nil ? (pat?.gender)! : ""
                userInfo?.birthDate = dateformatter.string(from: (pat?.birthDate?.nsDate)!)
                userInfo?.phone = pat?.telecom?.first?.value != nil ? (pat?.telecom?.first?.value)! : ""

                self.userLoginInfo["name"] = userInfo?.name
                prefs.setValue(self.userLoginInfo, forKey: "userLoginInfo")
                print("getFhir()")
                print(prefs.dictionary(forKey: "userLoginInfo"))
                
                print("\(pId)")
                print("userInfo: \(userInfo)")
                
            }
        }
        return userInfo
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        dump(segue.destination.description)
        if segue.identifier == "toTabbarVC" {
            let nextVC = segue.destination as! UITabBarController
//            let myInfoVC = nextVC.viewControllers?.first?.childViewControllers.first as? MyInfoVC
//            myInfoVC?.userInfo = getFhirPatient()
        } else if segue.identifier == "toJoinVC" {

        }
    }
 

}

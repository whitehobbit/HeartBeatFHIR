//
//  LoginVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 22..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import FHIR

class LoginVC: UIViewController {

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
        isLogined = true;
        if checkLogin() {
            self.performSegue(withIdentifier: "loginToTabBar", sender: self)
        }
    }
    
    func checkLogin() -> Bool {
        idTextField?.text = "test"; passwordTextField?.text = "test"
        if (idTextField?.text == user["id"] && passwordTextField?.text == user["password"]) {
            var userLoginInfo = [String: Any]()
            userLoginInfo["id"] = idTextField?.text
            userLoginInfo["password"] = passwordTextField?.text
            userLoginInfo["patientId"] = "7"
            userLoginInfo["autoLogin"] = false
            prefs.setValue(userLoginInfo, forKey: "userLoginInfo")
            isLogined = true
        } else {
            isLogined = false
        }
        return isLogined
    }
    
    func getFhirPatient() -> (id: String, pId: String, name: String, gender: String, birthDate: String, phone: String)? {
        
        print("========= getFhirPatient =========")
        var pat: Patient?
        let userLoginInfo = prefs.dictionary(forKey: "userLoginInfo")
        var userInfo: (id: String, pId: String, name: String, gender: String, birthDate: String, phone: String)?
        dump(userLoginInfo?["patientId"]!)
        Patient.read(userLoginInfo?["patientId"] as! String, server: fhirServer) { resource, error in
            if error != nil {
                dump(error)
            }
            else {
                pat = resource as! Patient?
//                dump(pat)
                let dateformatter: DateFormatter = DateFormatter()
                dateformatter.dateFormat = "yyyy. MM. dd."
                
                let id = userLoginInfo?["id"] as! String
                let pId = pat?.id != nil ? (pat?.id)! : ""
                let family: String = pat?.name?.first?.family?.first != nil ? (pat?.name?.first?.family?.first)! : ""
                let given: String = pat?.name?.first?.given?.first != nil ? (pat?.name?.first?.given?.first)! : ""
                userInfo?.name = family + given
                userInfo?.gender = pat?.gender != nil ? (pat?.gender)! : ""
                userInfo?.birthDate = dateformatter.string(from: (pat?.birthDate?.nsDate)!)
                userInfo?.phone = pat?.telecom?.first?.value != nil ? (pat?.telecom?.first?.value)! : ""
                
                print("\(userLoginInfo?["id"] as! String)")
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
        let nextVC = segue.destination as! UITabBarController
        let myInfoVC = nextVC.viewControllers?.first?.childViewControllers.first as? MyInfoVC
        myInfoVC?.userInfo = getFhirPatient()

        print("myInfoVC: ");dump(myInfoVC?.userInfo)
    }
 

}

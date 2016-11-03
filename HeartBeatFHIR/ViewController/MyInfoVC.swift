//
//  MyInfoVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 9. 22..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit
import FHIR

class MyInfoVC: UIViewController {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var patientIdLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var userInfo: (id: String, pId: String, name: String, gender: String, birthDate: String, phone: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("=========== MyInfoVC ===========")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLabel()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLabel() {
        self.idLabel?.text = userInfo?.id
        self.patientIdLabel?.text = userInfo?.pId
        self.nameLabel?.text = userInfo?.name
        self.genderLabel?.text = userInfo?.gender
        self.birthdateLabel?.text = userInfo?.birthDate
        self.phoneNumberLabel?.text = userInfo?.phone
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

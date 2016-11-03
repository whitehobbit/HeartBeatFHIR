//
//  JoinVC.swift
//  HeartBeat
//
//  Created by White Hobbit on 2016. 10. 13..
//  Copyright © 2016년 HITLab. All rights reserved.
//

import UIKit

class JoinVC: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pw1TextField: UITextField!
    @IBOutlet weak var pw2TextField: UITextField!
    @IBOutlet weak var familyTextField: UITextField!
    @IBOutlet weak var givenTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var telecomeTextField: UITextField!
    @IBOutlet weak var joinBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: - DB와의 연동을 통해 데이터 저장이 필요
    @IBAction func clickJoinBtn(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toLoginVC", sender: self)
    }
    
    @IBAction func clickCancelBtn(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toLoginVC", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

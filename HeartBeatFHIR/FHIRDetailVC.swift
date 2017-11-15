//
//  FHIRDetailVC.swift
//  HeartBeatFHIR
//
//  Created by White Hobbit on 2017. 2. 1..
//  Copyright © 2017년 WhiteHobbit. All rights reserved.
//

import UIKit
import FHIR

class FHIRDetailVC: UIViewController {
    
    var obs: Observation?

    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let heartRate = (self.obs?.valueQuantity?.value)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일 a h:m"
        let obsDate = (self.obs?.effectiveDateTime?.nsDate)!
        let source: String = obs?.device?.display ?? "-"
//
        self.heartRateLabel.text = "\(Int(heartRate))bpm"
        self.dateLabel.text = dateFormatter.string(from: obsDate)
        self.sourceLabel.text = source

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

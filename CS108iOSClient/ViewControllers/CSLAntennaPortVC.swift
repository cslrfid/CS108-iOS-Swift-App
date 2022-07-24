//
//  CSLAntennaPortVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 2019-11-01.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

import Foundation
import UIKit
import CSL_CS108

class CSLAntennaPortVC: UIViewController {
    
    @IBOutlet weak var btnAntennaPorts: UIButton!
    @IBOutlet var swAntennaPort: [UISwitch]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        navigationItem.title = "Antenna Ports"

        btnAntennaPorts.layer.borderWidth = 1.0
        btnAntennaPorts.layer.borderColor = UIColor.lightGray.cgColor
        btnAntennaPorts.layer.cornerRadius = 5.0

        var count = 0
        for sw in swAntennaPort {
            print("Switch \(count): \(Bool(truncating: CSLRfidAppEngine.shared().settings.isPortEnabled[count] as! NSNumber) ? "ON" : "OFF")")
            sw.isOn = Bool(truncating: CSLRfidAppEngine.shared().settings.isPortEnabled[count] as! NSNumber)
            count += 1
        }
    }

    @IBAction func btnAntennaPortsPressed(_ sender: Any) {

        var count = 0

        CSLRfidAppEngine.shared().settings.isPortEnabled = NSMutableArray()


        for sw in swAntennaPort {
            (CSLRfidAppEngine.shared().settings.isPortEnabled as NSMutableArray).add(NSNumber(value: sw.isOn))
            count += 1
        }

        CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

    }
}

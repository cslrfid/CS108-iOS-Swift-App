	//
//  CSLPostfilterVC.swift
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-12-28.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

import UIKit

class CSLPostfilterVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var txtMask: UITextField!
    @IBOutlet weak var txtOffset: UITextField!
    @IBOutlet weak var swNotMatchMask: UISwitch!
    @IBOutlet weak var swFilterEnabled: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btnSave.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {

        tabBarController?.title = "Post-filter"
        txtMask.delegate = self
        txtOffset.delegate = self
        view.isUserInteractionEnabled = true

        //reload previously stored settings
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        //refresh UI with stored values
        swFilterEnabled.isOn = CSLRfidAppEngine.shared().settings.postfilterIsEnabled
        swNotMatchMask.isOn = CSLRfidAppEngine.shared().settings.postfilterIsNotMatchMaskEnabled
        txtMask.text = "\(String(CSLRfidAppEngine.shared().settings.postfilterMask))"
        txtOffset.text = "\(CSLRfidAppEngine.shared().settings.postfilterOffset)"

    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        CSLRfidAppEngine.shared().settings.postfilterMask = txtMask.text
        CSLRfidAppEngine.shared().settings.postfilterOffset = Int32(txtOffset.text!)!
        CSLRfidAppEngine.shared().settings.postfilterIsNotMatchMaskEnabled = swNotMatchMask.isOn
        CSLRfidAppEngine.shared().settings.postfilterIsEnabled = swFilterEnabled.isOn

        CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

    }

    @IBAction func txtOffsetChanged(_ sender: Any) {
        //data validatiion
        
        if (Int(txtOffset.text!) != nil) && (Int(txtOffset.text ?? "") ?? -1) >= 0 && (Int(txtOffset.text ?? "") ?? -1) <= 255 {
            print("Postfilter offset entered: OK")
        }
        else {
            txtOffset.text = "\(CSLRfidAppEngine.shared().settings.postfilterOffset)"
        }
    }

    @IBAction func txtMaskChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        
        if ((txtMask.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) {
            txtMask.text = CSLRfidAppEngine.shared().settings.postfilterMask
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = Int32(battPct)
    }


}

//
//  CSLPrefilterVC.swift
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2021-12-28.
//  Copyright © 2021 Convergence Systems Limited. All rights reserved.
//

import UIKit

class CSLPrefilterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtMask: UITextField!
    @IBOutlet weak var btnBank: UIButton!
    @IBOutlet weak var txtOffset: UITextField!
    @IBOutlet weak var swFilterEnabled: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnBank.layer.borderWidth = 1.0
        btnBank.layer.borderColor = UIColor.lightGray.cgColor
        btnBank.layer.cornerRadius = 5.0
        btnSave.layer.cornerRadius = 5.0
    }

    override func viewWillAppear(_ animated: Bool) {

        tabBarController?.title = "Pre-filter"
        txtMask.delegate = self
        txtOffset.delegate = self
        view.isUserInteractionEnabled = true

        //reload previously stored settings
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        //refresh UI with stored values
        swFilterEnabled.isOn = CSLRfidAppEngine.shared().settings.prefilterIsEnabled
        switch CSLRfidAppEngine.shared().settings.prefilterBank {
        case MEMORYBANK.RESERVED:
            btnBank.setTitle("RESERVED", for: .normal)
        case MEMORYBANK.EPC:
            btnBank.setTitle("EPC", for: .normal)
        case MEMORYBANK.TID:
            btnBank.setTitle("TID", for: .normal)
        case MEMORYBANK.USER:
            btnBank.setTitle("USER", for: .normal)
        default:
            break
        }
        txtMask.text = "\(String(CSLRfidAppEngine.shared().settings.prefilterMask))"
        txtOffset.text = "\(CSLRfidAppEngine.shared().settings.prefilterOffset)"

    }

    @IBAction func btnSavePressed(_ sender: Any) {
        CSLRfidAppEngine.shared().settings.prefilterMask = txtMask.text
        CSLRfidAppEngine.shared().settings.prefilterOffset = Int32(txtOffset.text!)!
        if btnBank.titleLabel?.text?.compare("RESERVED") == .orderedSame {
            CSLRfidAppEngine.shared().settings.prefilterBank = MEMORYBANK.RESERVED
        }
        if btnBank.titleLabel?.text?.compare("EPC") == .orderedSame {
            CSLRfidAppEngine.shared().settings.prefilterBank = MEMORYBANK.EPC
        }
        if btnBank.titleLabel?.text?.compare("TID") == .orderedSame {
            CSLRfidAppEngine.shared().settings.prefilterBank = MEMORYBANK.TID
        }
        if btnBank.titleLabel?.text?.compare("USER") == .orderedSame {
            CSLRfidAppEngine.shared().settings.prefilterBank = MEMORYBANK.USER
        }
        CSLRfidAppEngine.shared().settings.prefilterIsEnabled = swFilterEnabled.isOn

        CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    @IBAction func txtOffsetChanged(_ sender: Any) {
        //data validatiion
        if (Int(txtOffset.text!) != nil) && (Int(txtOffset.text ?? "") ?? -1) >= 0 && (Int(txtOffset.text ?? "") ?? -1) <= 255 {
            print("Prefilter offset entered: OK")
        }
        else {
            txtOffset.text = "\(CSLRfidAppEngine.shared().settings.prefilterOffset)"
        }
    }

    @IBAction func txtMaskChanged(_ sender: Any) {

        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtMask.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) {
            txtMask.text = CSLRfidAppEngine.shared().settings.prefilterMask
        }
    }

    @IBAction func btnBankPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Pre-filter",
            message: "Please select bank",
            preferredStyle: .actionSheet)
        let reserved = UIAlertAction(title: "RESERVED", style: .default, handler: { [self] action in
            btnBank.setTitle("RESERVED", for: .normal)
        }) // RESERVED
        let epc = UIAlertAction(title: "EPC", style: .default, handler: { [self] action in
            btnBank.setTitle("EPC", for: .normal)
        }) // EPC
        let tid = UIAlertAction(title: "TID", style: .default, handler: { [self] action in
            btnBank.setTitle("TID", for: .normal)
        }) // TID
        let user = UIAlertAction(title: "USER", style: .default, handler: { [self] action in
            btnBank.setTitle("USER", for: .normal)
        }) // USER

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(reserved)
        alert.addAction(epc)
        alert.addAction(tid)
        alert.addAction(user)
        alert.addAction(cancel)

        present(alert, animated: true)

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = Int32(battPct)
    }

    
}

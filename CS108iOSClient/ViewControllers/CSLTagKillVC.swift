//
//  CSLTagKillVC.swift
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2022-01-07.
//  Copyright © 2022 Convergence Systems Limited. All rights reserved.
//

import UIKit

@objcMembers class CSLTagKillVC: UIViewController, CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate {

    @IBOutlet weak var txtSelectedEPC: UITextField!
    @IBOutlet weak var txtKillPwd: UITextField!
    @IBOutlet weak var btnKillTag: UIButton!
    
    var killCommandAccepted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnKillTag.layer.borderColor = UIColor.clear.cgColor
        btnKillTag.layer.cornerRadius = 5.0
    }
    

    @IBAction func txtSelectedEPCEdited(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if (txtSelectedEPC.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound {
            txtSelectedEPC.text = ""
        }
    }

    @IBAction func txtKillPwdEditied(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtKillPwd.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) || txtKillPwd.text!.count != 8 {
            txtKillPwd.text = "00000000"
        }
    }

    @IBAction func btnKillTagPressed(_ sender: Any) {

        if txtSelectedEPC.text == "" {
            let alert = UIAlertController(title: "Tag Kill", message: "No EPC Selected", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
            return
        }

        var result = true
        var alert: UIAlertController?
        var ok: UIAlertAction?

        killCommandAccepted = false

        //get kill password
        var killPwd: UInt32 = 0
        killPwd = UInt32(txtKillPwd.text ?? "00000000")!

        CSLRfidAppEngine.shared().reader.setPowerMode(false)
        result = CSLRfidAppEngine.shared().reader.startTagMemoryKill(killPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text?.count ?? 0) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text ?? "0"))

        for _ in 0..<COMMAND_TIMEOUT_5S {
            //receive data or time out in 5 seconds
            if result && killCommandAccepted {
                break
            }
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
        }

        if result && killCommandAccepted {
            alert = UIAlertController(title: "Tag Kill", message: "ACCEPTED", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Tag Kill", message: "FAILED", preferredStyle: .alert)
        }

        CSLRfidAppEngine.shared().reader.setPowerMode(true)

        ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        if let ok = ok {
            alert?.addAction(ok)
        }
        if let alert = alert {
            present(alert, animated: true)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CSLRfidAppEngine.shared().tagSelected != "" {
            txtSelectedEPC.text = CSLRfidAppEngine.shared().tagSelected
        }

        txtSelectedEPC.delegate = self
        txtKillPwd.delegate = self

        CSLRfidAppEngine.shared().reader.delegate = self
        CSLRfidAppEngine.shared().reader.readerDelegate = self

    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {

    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {

    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
        let backScatterError = tag?.backScatterError
        let accessError = tag?.accessError
        let crcError = tag?.crcError
        let ackTimeout = tag?.ackTimeout
        if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
            killCommandAccepted = true
        }
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader!, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = Int32(battPct)
    }

    func didTriggerKeyChangedState(_ sender: CSLBleReader?, keyState state: Bool) {

    }

    func didReceiveBarcodeData(_ sender: CSLBleReader?, scannedBarcode barcode: CSLReaderBarcode?) {

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }


}

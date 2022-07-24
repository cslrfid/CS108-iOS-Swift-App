//
//  CSLTagLockVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 30/12/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import Foundation
import UIKit
import CSL_CS108

class CSLTagLockVC: UIViewController, CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate {
    private var securityCommandAccepted = false

    @IBOutlet weak var txtSelectedEPC: UITextField!
    @IBOutlet weak var txtAccessPwd: UITextField!
    @IBOutlet weak var btnEPCSecurity: UIButton!
    @IBOutlet weak var btnAccPwdSecurity: UIButton!
    @IBOutlet weak var btnKillPwdSecurity: UIButton!
    @IBOutlet weak var btnTidSecurity: UIButton!
    @IBOutlet weak var btnUserSecurity: UIButton!
    @IBOutlet weak var btnApplySecurity: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btnEPCSecurity.layer.borderWidth = 1.0
        btnEPCSecurity.layer.borderColor = UIColor.lightGray.cgColor
        btnEPCSecurity.layer.cornerRadius = 5.0
        btnAccPwdSecurity.layer.borderWidth = 1.0
        btnAccPwdSecurity.layer.borderColor = UIColor.lightGray.cgColor
        btnAccPwdSecurity.layer.cornerRadius = 5.0
        btnKillPwdSecurity.layer.borderWidth = 1.0
        btnKillPwdSecurity.layer.borderColor = UIColor.lightGray.cgColor
        btnKillPwdSecurity.layer.cornerRadius = 5.0
        btnTidSecurity.layer.borderWidth = 1.0
        btnTidSecurity.layer.borderColor = UIColor.lightGray.cgColor
        btnTidSecurity.layer.cornerRadius = 5.0
        btnUserSecurity.layer.borderWidth = 1.0
        btnUserSecurity.layer.borderColor = UIColor.lightGray.cgColor
        btnUserSecurity.layer.cornerRadius = 5.0
        btnApplySecurity.layer.borderWidth = 1.0
        btnApplySecurity.layer.borderColor = UIColor.clear.cgColor
        btnApplySecurity.layer.cornerRadius = 5.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(CSLRfidAppEngine.shared().tagSelected == "") {
            txtSelectedEPC.text = CSLRfidAppEngine.shared().tagSelected
        }

        txtSelectedEPC.delegate = self
        txtAccessPwd.delegate = self

        CSLRfidAppEngine.shared().reader.delegate = self
        CSLRfidAppEngine.shared().reader.readerDelegate = self

    }

    @IBAction func btnApplySecurityPressed(_ sender: Any) {
        autoreleasepool {

            if (txtSelectedEPC.text == "") {
                let alert = UIAlertController(title: "Tag Security", message: "No EPC Selected", preferredStyle: .alert)

                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true)
                return
            }

            var result = true
            var validationMsg = ""
            var alert: UIAlertController?
            var ok: UIAlertAction?
            var lockCommandConfigBits: UInt32

            securityCommandAccepted = false

            //input validation
            if ((txtSelectedEPC.text?.count ?? 0) % 4) != 0 {
                validationMsg = validationMsg + ("SelectedEPC ")
            }
            if txtAccessPwd.text?.count ?? 0 != 8 && (txtSelectedEPC.text?.count ?? 0 != 0) {
                validationMsg = validationMsg + ("AccessPWD ")
            }

            if !(validationMsg == "") {
                alert = UIAlertController(title: "Tag Write", message: "Invalid Input: " + (validationMsg), preferredStyle: .alert)
                ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                if let ok = ok {
                    alert?.addAction(ok)
                }
                if let alert = alert {
                    present(alert, animated: true)
                }
                return
            }

            //get access password
            var accPwd: UInt32 = 0
            accPwd = UInt32(txtAccessPwd.text ?? "0", radix: 16)!

            //compose the 20bit security
            lockCommandConfigBits = 0
            if (btnKillPwdSecurity.currentTitle == "UNLOCK") {
                lockCommandConfigBits |= 0xc0000 //b'11000000000000000000
            } else if (btnKillPwdSecurity.currentTitle == "PERM_UNLOCK") {
                lockCommandConfigBits |= 0xc0100 //b'11000000000100000000
            } else if (btnKillPwdSecurity.currentTitle == "LOCK") {
                lockCommandConfigBits |= 0xc0200 //b'11000000001000000000
            } else if (btnKillPwdSecurity.currentTitle == "PERM_LOCK") {
                lockCommandConfigBits |= 0xc0300 //b'11000000001100000000
            }

            if (btnAccPwdSecurity.currentTitle == "UNLOCK") {
                lockCommandConfigBits |= 0x30000 //b'00110000000000000000
            } else if (btnAccPwdSecurity.currentTitle == "PERM_UNLOCK") {
                lockCommandConfigBits |= 0x30040 //b'00110000000001000000
            } else if (btnAccPwdSecurity.currentTitle == "LOCK") {
                lockCommandConfigBits |= 0x30080 //b'00110000000010000000
            } else if (btnAccPwdSecurity.currentTitle == "PERM_LOCK") {
                lockCommandConfigBits |= 0x030c0 //b'00110000000011000000
            }

            if (btnEPCSecurity.currentTitle == "UNLOCK") {
                lockCommandConfigBits |= 0x0c000 //b'00001100000000000000
            } else if (btnEPCSecurity.currentTitle == "PERM_UNLOCK") {
                lockCommandConfigBits |= 0x0c010 //b'00001100000000010000
            } else if (btnEPCSecurity.currentTitle == "LOCK") {
                lockCommandConfigBits |= 0x0c020 //b'00001100000000100000
            } else if (btnEPCSecurity.currentTitle == "PERM_LOCK") {
                lockCommandConfigBits |= 0x0c030 //b'00001100000000110000
            }

            if (btnTidSecurity.currentTitle == "UNLOCK") {
                lockCommandConfigBits |= 0x03000 //b'00000011000000000000
            } else if (btnTidSecurity.currentTitle == "PERM_UNLOCK") {
                lockCommandConfigBits |= 0x03004 //b'00000011000000000100
            } else if (btnTidSecurity.currentTitle == "LOCK") {
                lockCommandConfigBits |= 0x03008 //b'00000011000000001000
            } else if (btnTidSecurity.currentTitle == "PERM_LOCK") {
                lockCommandConfigBits |= 0x0300c //b'00000011000000001100
            }

            if (btnUserSecurity.currentTitle == "UNLOCK") {
                lockCommandConfigBits |= 0x00c00 //b'00000000110000000000
            } else if (btnUserSecurity.currentTitle == "PERM_UNLOCK") {
                lockCommandConfigBits |= 0x00c01 //b'00000000110000000001
            } else if (btnUserSecurity.currentTitle == "LOCK") {
                lockCommandConfigBits |= 0x00c02 //b'00000000110000000010
            } else if (btnUserSecurity.currentTitle == "PERM_LOCK") {
                lockCommandConfigBits |= 0x00c03 //b'00000000110000000011
            }

            CSLRfidAppEngine.shared().reader.setPowerMode(false)
            result = CSLRfidAppEngine.shared().reader.startTagMemoryLock(lockCommandConfigBits, accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text?.count ?? 0) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text ?? "0"))

            for _ in 0..<COMMAND_TIMEOUT_5S {
                //receive data or time out in 5 seconds
                if result && securityCommandAccepted {
                    break
                }
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
            }

            if result && securityCommandAccepted {
                alert = UIAlertController(title: "Tag Security", message: "ACCEPTED", preferredStyle: .alert)
            } else {
                alert = UIAlertController(title: "Tag Security", message: "FAILED", preferredStyle: .alert)
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

    }

    @IBAction func btnEPCSecurityPressed(_ sender: Any) {

        let alert = UIAlertController(title: "EPC", message: "Please select action", preferredStyle: .actionSheet)
        let unlock = UIAlertAction(title: "UNLOCK", style: .default, handler: { action in
                self.btnEPCSecurity.setTitle("UNLOCK", for: .normal)
            }) // UNLOCK
        let perm_unlock = UIAlertAction(title: "PERM_UNLOCK", style: .default, handler: { action in
                self.btnEPCSecurity.setTitle("PERM_UNLOCK", for: .normal)
            }) // PERM_UNLOCK
        let lock = UIAlertAction(title: "LOCK", style: .default, handler: { action in
                self.btnEPCSecurity.setTitle("LOCK", for: .normal)
            }) // LOCK
        let perm_lock = UIAlertAction(title: "PERM_LOCK", style: .default, handler: { action in
                self.btnEPCSecurity.setTitle("PERM_LOCK", for: .normal)
            }) // PERM_LOCK
        let unchanged = UIAlertAction(title: "UNCHANGED", style: .default, handler: { action in
                self.btnEPCSecurity.setTitle("UNCHANGED", for: .normal)
            }) // UNCHANGED
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(unlock)
        alert.addAction(perm_unlock)
        alert.addAction(lock)
        alert.addAction(perm_lock)
        alert.addAction(unchanged)

        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func btnAccPwdSecurityPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Access Password", message: "Please select action", preferredStyle: .actionSheet)
        let unlock = UIAlertAction(title: "UNLOCK", style: .default, handler: { action in
                self.btnAccPwdSecurity.setTitle("UNLOCK", for: .normal)
            }) // UNLOCK
        let perm_unlock = UIAlertAction(title: "PERM_UNLOCK", style: .default, handler: { action in
                self.btnAccPwdSecurity.setTitle("PERM_UNLOCK", for: .normal)
            }) // PERM_UNLOCK
        let lock = UIAlertAction(title: "LOCK", style: .default, handler: { action in
                self.btnAccPwdSecurity.setTitle("LOCK", for: .normal)
            }) // LOCK
        let perm_lock = UIAlertAction(title: "PERM_LOCK", style: .default, handler: { action in
                self.btnAccPwdSecurity.setTitle("PERM_LOCK", for: .normal)
            }) // PERM_LOCK
        let unchanged = UIAlertAction(title: "UNCHANGED", style: .default, handler: { action in
                self.btnAccPwdSecurity.setTitle("UNCHANGED", for: .normal)
            }) // UNCHANGED
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(unlock)
        alert.addAction(perm_unlock)
        alert.addAction(lock)
        alert.addAction(perm_lock)
        alert.addAction(unchanged)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnKillPwdSecurityPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Kill Password", message: "Please select action", preferredStyle: .actionSheet)
        let unlock = UIAlertAction(title: "UNLOCK", style: .default, handler: { action in
                self.btnKillPwdSecurity.setTitle("UNLOCK", for: .normal)
            }) // UNLOCK
        let perm_unlock = UIAlertAction(title: "PERM_UNLOCK", style: .default, handler: { action in
                self.btnKillPwdSecurity.setTitle("PERM_UNLOCK", for: .normal)
            }) // PERM_UNLOCK
        let lock = UIAlertAction(title: "LOCK", style: .default, handler: { action in
                self.btnKillPwdSecurity.setTitle("LOCK", for: .normal)
            }) // LOCK
        let perm_lock = UIAlertAction(title: "PERM_LOCK", style: .default, handler: { action in
                self.btnKillPwdSecurity.setTitle("PERM_LOCK", for: .normal)
            }) // PERM_LOCK
        let unchanged = UIAlertAction(title: "UNCHANGED", style: .default, handler: { action in
                self.btnKillPwdSecurity.setTitle("UNCHANGED", for: .normal)
            }) // UNCHANGED
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(unlock)
        alert.addAction(perm_unlock)
        alert.addAction(lock)
        alert.addAction(perm_lock)
        alert.addAction(unchanged)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnTidSecurityPressed(_ sender: Any) {
        let alert = UIAlertController(title: "TID", message: "Please select action", preferredStyle: .actionSheet)
        let unlock = UIAlertAction(title: "UNLOCK", style: .default, handler: { action in
                self.btnTidSecurity.setTitle("UNLOCK", for: .normal)
            }) // UNLOCK
        let perm_unlock = UIAlertAction(title: "PERM_UNLOCK", style: .default, handler: { action in
                self.btnTidSecurity.setTitle("PERM_UNLOCK", for: .normal)
            }) // PERM_UNLOCK
        let lock = UIAlertAction(title: "LOCK", style: .default, handler: { action in
                self.btnTidSecurity.setTitle("LOCK", for: .normal)
            }) // LOCK
        let perm_lock = UIAlertAction(title: "PERM_LOCK", style: .default, handler: { action in
                self.btnTidSecurity.setTitle("PERM_LOCK", for: .normal)
            }) // PERM_LOCK
        let unchanged = UIAlertAction(title: "UNCHANGED", style: .default, handler: { action in
                self.btnTidSecurity.setTitle("UNCHANGED", for: .normal)
            }) // UNCHANGED
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(unlock)
        alert.addAction(perm_unlock)
        alert.addAction(lock)
        alert.addAction(perm_lock)
        alert.addAction(unchanged)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnUserSecurityPressed(_ sender: Any) {
        let alert = UIAlertController(title: "USER", message: "Please select action", preferredStyle: .actionSheet)
        let unlock = UIAlertAction(title: "UNLOCK", style: .default, handler: { action in
                self.btnUserSecurity.setTitle("UNLOCK", for: .normal)
            }) // UNLOCK
        let perm_unlock = UIAlertAction(title: "PERM_UNLOCK", style: .default, handler: { action in
                self.btnUserSecurity.setTitle("PERM_UNLOCK", for: .normal)
            }) // PERM_UNLOCK
        let lock = UIAlertAction(title: "LOCK", style: .default, handler: { action in
                self.btnUserSecurity.setTitle("LOCK", for: .normal)
            }) // LOCK
        let perm_lock = UIAlertAction(title: "PERM_LOCK", style: .default, handler: { action in
                self.btnUserSecurity.setTitle("PERM_LOCK", for: .normal)
            }) // PERM_LOCK
        let unchanged = UIAlertAction(title: "UNCHANGED", style: .default, handler: { action in
                self.btnUserSecurity.setTitle("UNCHANGED", for: .normal)
            }) // UNCHANGED
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(unlock)
        alert.addAction(perm_unlock)
        alert.addAction(lock)
        alert.addAction(perm_lock)
        alert.addAction(unchanged)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {
    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
         DispatchQueue.main.async(execute: {
            if (tag?.accessError == 0xff) && (!(tag?.crcError ?? true)) && tag?.backScatterError == 0xff && (!(tag?.ackTimeout ?? true)) {
                self.securityCommandAccepted = true
            }
        })
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = battPct
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

//
//  CSLTagAccessController.swift
//  CS108iOSClient
//
//  Created by Carlson Lam 16/10/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import Foundation
import UIKit
import CSL_CS108

class CSLTagAccessVC: UIViewController, CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate {
    
    func UIColorFromRGB(_ rgbValue: UInt32) -> UIColor {
        UIColor(red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(rgbValue & 0xff)) / 255.0), alpha: 1.0)
    }

    
    enum MEMORYITEM : UInt8 {
        case mKILLPWD
        case mACCPWD
        case mPC
        case mEPC
        case mTID
        case mUSER
    }

    var bankSelected: MEMORYBANK?
    var memItem: MEMORYITEM!
    
    @IBOutlet weak var txtSelectedEPC: UITextField!
    @IBOutlet weak var txtAccessPwd: UITextField!
    @IBOutlet weak var txtPC: UITextField!
    @IBOutlet weak var txtEPC: UITextField!
    @IBOutlet weak var txtAccPwd: UITextField!
    @IBOutlet weak var txtKillPwd: UITextField!
    @IBOutlet weak var txtTidUid: UITextField!
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var swPC: UISwitch!
    @IBOutlet weak var swEPC: UISwitch!
    @IBOutlet weak var swAccPwd: UISwitch!
    @IBOutlet weak var swKillPwd: UISwitch!
    @IBOutlet weak var swTidUid: UISwitch!
    @IBOutlet weak var swUser: UISwitch!
    @IBOutlet weak var btnTidUidOffset: UIButton!
    @IBOutlet weak var btnTidUidWord: UIButton!
    @IBOutlet weak var btnUserOffset: UIButton!
    @IBOutlet weak var btnUserWord: UIButton!
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var btnWrite: UIButton!
    @IBOutlet weak var btnSecurity: UIButton!
    @IBOutlet weak var txtPower: UITextField!
    @IBOutlet weak var lbPort: UILabel!
    @IBOutlet weak var txtPort: UITextField!
    @IBOutlet weak var actTagAccessSpinner: UIActivityIndicatorView!
    @IBOutlet weak var btnKill: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btnRead.layer.borderWidth = 1.0
        btnRead.layer.borderColor = UIColor.clear.cgColor
        btnRead.layer.cornerRadius = 5.0
        btnWrite.layer.borderWidth = 1.0
        btnWrite.layer.borderColor = UIColor.clear.cgColor
        btnWrite.layer.cornerRadius = 5.0
        btnSecurity.layer.borderWidth = 1.0
        btnSecurity.layer.borderColor = UIColor.clear.cgColor
        btnSecurity.layer.cornerRadius = 5.0
        btnKill.layer.borderColor = UIColor.clear.cgColor
        btnKill.layer.cornerRadius = 5.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.title = "Access Control"

        actTagAccessSpinner.stopAnimating()
        view.isUserInteractionEnabled = true

        if !(CSLRfidAppEngine.shared().tagSelected == "") {
            txtSelectedEPC.text = CSLRfidAppEngine.shared().tagSelected
            txtEPC.text = CSLRfidAppEngine.shared().tagSelected
        }

        CSLRfidAppEngine.shared().reader.delegate = self
        CSLRfidAppEngine.shared().reader.readerDelegate = self

        txtSelectedEPC.delegate = self
        txtAccessPwd.delegate = self
        txtPC.delegate = self
        txtEPC.delegate = self
        txtAccPwd.delegate = self
        txtKillPwd.delegate = self
        txtTidUid.delegate = self
        txtUser.delegate = self
        txtPower.delegate = self

        //hide port selection on CS108
        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
            lbPort.isHidden = true
            txtPort.isHidden = true
        } else {
            lbPort.isHidden = false
            txtPort.isHidden = false
        }

        txtPower.text = "\(CSLRfidAppEngine.shared().settings.power)"

        // Do any additional setup after loading the view.
        //(tabBarController as? CSLTabVC)?.setAntennaPortsAndPowerForTagAccess()
        //(tabBarController as? CSLTabVC)?.setConfigurationsForTags()
        CSLReaderConfigurations.setAntennaPortsAndPowerForTagAccess(false)
        CSLReaderConfigurations.setConfigurationsForTags()
    }

    override func viewWillDisappear(_ animated: Bool) {
        CSLRfidAppEngine.shared().reader.delegate = nil
        CSLRfidAppEngine.shared().reader.readerDelegate = nil
    }

    @IBAction func swPCPressed(_ sender: Any) {
    }

    @IBAction func swEPCPressed(_ sender: Any) {
    }

    @IBAction func swAccPwdPressed(_ sender: Any) {
    }

    @IBAction func swKillPwdPressed(_ sender: Any) {
    }

    @IBAction func swTidUidPressed(_ sender: Any) {
    }

    @IBAction func swUserPressed(_ sender: Any) {
    }

    @IBAction func btnTidUidOffsetPressed(_ sender: Any) {

        let alert = UIAlertController(title: "TID-UID", message: "Offset", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Offset"
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .numberPad
            textField.text = (self.btnTidUidOffset.titleLabel?.text as NSString?)?.substring(from: 7)
        })

        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                let textField = alert.textFields?.first
                if (Int(textField?.text ?? "") ?? -1 >= 0 && Int(textField?.text ?? "") ?? -1 <= 8) && !(textField?.text == "") {
                    textField?.text = "\(Int(textField?.text ?? "") ?? 0)"
                    self.btnTidUidOffset.setTitle("Offset=\(textField?.text ?? "")", for: .normal)
                }
            })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel


        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    @IBAction func btnTidUidWordPressed(_ sender: Any) {
        let alert = UIAlertController(title: "TID-UID", message: "Word Count", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Word Count"
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .numberPad
            textField.text = (self.btnTidUidWord.titleLabel?.text as NSString?)?.substring(from: 5)
        })

        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                let textField = alert.textFields?.first
                if (Int(textField?.text ?? "") ?? 0 > 0 && Int(textField?.text ?? "") ?? 0 <= 8) && !(textField?.text == "") {
                    textField?.text = "\(Int(textField?.text ?? "") ?? 0)"
                    self.btnTidUidWord.setTitle("Word=\(textField?.text ?? "")", for: .normal)
                }
            })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel


        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    @IBAction func btnUserOffsetPressed(_ sender: Any) {
        let alert = UIAlertController(title: "USER", message: "Offset", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Offset"
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .numberPad
            textField.text = (self.btnUserOffset.titleLabel?.text as NSString?)?.substring(from: 7)
        })

        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                let textField = alert.textFields?.first
                if (Int(textField?.text ?? "") ?? -1 >= 0 && Int(textField?.text ?? "") ?? -1 <= 32) && !(textField?.text == "") {
                    textField?.text = "\(Int(textField?.text ?? "") ?? 0)"
                    self.btnUserOffset.setTitle("Offset=\(textField?.text ?? "")", for: .normal)
                }
            })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel


        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)


    }

    @IBAction func btnUserWordPressed(_ sender: Any) {
        let alert = UIAlertController(title: "USER", message: "Word Count", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Word Count"
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .numberPad
            textField.text = (self.btnUserWord.titleLabel?.text as NSString?)?.substring(from: 5)
        })

        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                let textField = alert.textFields?.first
                if (Int(textField?.text ?? "") ?? 0 > 0 && Int(textField?.text ?? "") ?? 0 <= 32) && !(textField?.text == "") {
                    textField?.text = "\(Int(textField?.text ?? "") ?? 0)"
                    self.btnUserWord.setTitle("Word=\(textField?.text ?? "")", for: .normal)
                }
            })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel


        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)

    }

    @IBAction func btnReadPressed(_ sender: Any) {

        autoreleasepool {
            btnWrite.isEnabled = false
            btnSecurity.isEnabled = false

            let tidWordCount = Int(((btnTidUidWord.titleLabel?.text as NSString?)?.substring(from: 5) ?? "")) ?? 0
            let tidOffset = Int(((btnTidUidOffset.titleLabel?.text as NSString?)?.substring(from: 7) ?? "")) ?? 0
            let userWordCount = Int(((btnUserWord.titleLabel?.text as NSString?)?.substring(from: 5) ?? "")) ?? 0
            let userOffset = Int(((btnUserOffset.titleLabel?.text as NSString?)?.substring(from: 7) ?? "")) ?? 0
            let EPCWordCount = UInt8(txtSelectedEPC.text!.count) / UInt8(4)

            //clear UI
            //if ([self.swTidUid isOn])
            txtTidUid.text = ""
            //if ([self.swUser isOn])
            txtUser.text = ""
            //if ([self.swEPC isOn])
            txtEPC.text = ""
            //if ([self.swPC isOn])
            txtPC.text = ""
            //if ([self.swAccPwd isOn])
            txtAccPwd.text = ""
            //if ([self.swKillPwd isOn])
            txtKillPwd.text = ""

            txtTidUid.backgroundColor = UIColorFromRGB(0xffffff)
            txtUser.backgroundColor = UIColorFromRGB(0xffffff)
            txtEPC.backgroundColor = UIColorFromRGB(0xffffff)
            txtPC.backgroundColor = UIColorFromRGB(0xffffff)
            txtAccPwd.backgroundColor = UIColorFromRGB(0xffffff)
            txtKillPwd.backgroundColor = UIColorFromRGB(0xffffff)
            //refresh UI
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))

            //get access password
            var accPwd: UInt32 = 0
            accPwd = UInt32(txtAccessPwd.text ?? "00000000")!


            //read PC+EPC if TID is not needed.  Otherwise, read PC+EPC+TID all in one shot
            if swEPC.isOn || swPC.isOn || swTidUid.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.TID
                if swTidUid.isOn {
                    CSLRfidAppEngine.shared().reader.startTagMemoryRead(MEMORYBANK.TID, dataOffset: UInt16(tidOffset), dataCount: UInt16(tidWordCount), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))
                } else if swEPC.isOn || swPC.isOn {
                    CSLRfidAppEngine.shared().reader.startTagMemoryRead(MEMORYBANK.EPC, dataOffset: 2, dataCount: UInt16(EPCWordCount), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))
                }

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtEPC.text!.count != 0 || txtPC.text!.count != 0 || txtTidUid.text!.count != 0 {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                if txtEPC.text!.count == 0 && swEPC.isOn {
                    txtEPC.backgroundColor = UIColorFromRGB(0xffb3b3)
                } else if txtEPC.text!.count != 0 && swEPC.isOn {
                    txtEPC.backgroundColor = UIColorFromRGB(0xd1f2eb)
                }
                if txtPC.text!.count == 0 && swPC.isOn {
                    txtPC.backgroundColor = UIColorFromRGB(0xffb3b3)
                } else if txtPC.text!.count != 0 && swPC.isOn {
                    txtPC.backgroundColor = UIColorFromRGB(0xd1f2eb)
                }
                if txtTidUid.text!.count == 0 && swTidUid.isOn {
                    txtTidUid.backgroundColor = UIColorFromRGB(0xffb3b3)
                } else if txtTidUid.text!.count != 0 && swTidUid.isOn {
                    txtTidUid.backgroundColor = UIColorFromRGB(0xd1f2eb)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }

            //read access password and kill password
            if swAccPwd.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.RESERVED
                memItem = MEMORYITEM.mACCPWD
                CSLRfidAppEngine.shared().reader.startTagMemoryRead(MEMORYBANK.RESERVED, dataOffset: 2, dataCount: 2, accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtAccPwd.text!.count != 0 {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                if txtAccPwd.text!.count == 0 && swAccPwd.isOn {
                    txtAccPwd.backgroundColor = UIColorFromRGB(0xffb3b3)
                } else if txtAccPwd.text!.count != 0 && swAccPwd.isOn {
                    txtAccPwd.backgroundColor = UIColorFromRGB(0xd1f2eb)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }
            if swKillPwd.isOn {
                bankSelected = MEMORYBANK.RESERVED
                memItem = MEMORYITEM.mKILLPWD
                CSLRfidAppEngine.shared().reader.startTagMemoryRead(MEMORYBANK.RESERVED, dataOffset: 0, dataCount: 2, accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtKillPwd.text!.count != 0 {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                if txtKillPwd.text!.count == 0 && swKillPwd.isOn {
                    txtKillPwd.backgroundColor = UIColorFromRGB(0xffb3b3)
                } else if txtKillPwd.text!.count != 0 && swKillPwd.isOn {
                    txtKillPwd.backgroundColor = UIColorFromRGB(0xd1f2eb)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
            }

            //read USER
            if swUser.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.USER
                CSLRfidAppEngine.shared().reader.startTagMemoryRead(MEMORYBANK.USER, dataOffset: UInt16(userOffset), dataCount: UInt16(userWordCount), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtUser.text!.count != 0 {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                if txtUser.text!.count == 0 && swUser.isOn {
                    txtUser.backgroundColor = UIColorFromRGB(0xffb3b3)
                } else if txtUser.text!.count != 0 && swUser.isOn {
                    txtUser.backgroundColor = UIColorFromRGB(0xd1f2eb)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true);
            }

            let alert = UIAlertController(title: "Tag Read", message: "Completed", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)

            btnWrite.isEnabled = true
            btnSecurity.isEnabled = true

        }
    }

    @IBAction func btnWritePressed(_ sender: Any) {
        autoreleasepool {
            btnRead.isEnabled = false
            btnSecurity.isEnabled = false

            let userWordCount = Int(((btnUserWord.titleLabel?.text as NSString?)?.substring(from: 5) ?? "")) ?? 0
            let userOffset = Int(((btnUserOffset.titleLabel?.text as NSString?)?.substring(from: 7) ?? "")) ?? 0
            let tidWordCount = Int(((btnTidUidWord.titleLabel?.text as NSString?)?.substring(from: 5) ?? "")) ?? 0
            let tidOffset = Int(((btnTidUidWord.titleLabel?.text as NSString?)?.substring(from: 7) ?? "")) ?? 0
            var validationMsg = ""
            var alert: UIAlertController?
            var ok: UIAlertAction?

            //input validation
            if swPC.isOn && txtPC.text!.count != 4 {
                validationMsg = validationMsg + ("PC ")
            }
            if swEPC.isOn && (((txtEPC.text!.count % 4) != 0) || (txtEPC.text!.count == 0)) {
                validationMsg = validationMsg + ("EPC ")
            }
            if swUser.isOn && (txtUser.text!.count != (Int(userWordCount) * 4) || (txtUser.text!.count == 0)) {
                validationMsg = validationMsg + ("USER ")
            }
            if swTidUid.isOn && (txtTidUid.text!.count != (Int(tidWordCount) * 4) || (txtTidUid.text!.count == 0) || (tidOffset < 2)) {
                validationMsg = validationMsg + ("TID-UID ")
            }
            if swAccPwd.isOn && txtAccPwd.text!.count != 8 {
                validationMsg = validationMsg + ("AccPWD ")
            }
            if swKillPwd.isOn && txtKillPwd.text!.count != 8 {
                validationMsg = validationMsg + ("KillPWD ")
            }
            if (txtSelectedEPC.text!.count % 4) != 0 {
                validationMsg = validationMsg + ("SelectedEPC ")
            }
            if txtAccessPwd.text!.count != 8 && (txtSelectedEPC.text!.count != 0) {
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

            //clear UI
            txtTidUid.backgroundColor = UIColorFromRGB(0xffffff)
            txtUser.backgroundColor = UIColorFromRGB(0xffffff)
            txtEPC.backgroundColor = UIColorFromRGB(0xffffff)
            txtPC.backgroundColor = UIColorFromRGB(0xffffff)
            txtAccPwd.backgroundColor = UIColorFromRGB(0xffffff)
            txtKillPwd.backgroundColor = UIColorFromRGB(0xffffff)
            //refresh UI
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))

            //get access password
            var accPwd: UInt32 = 0
            accPwd = UInt32(txtAccessPwd.text ?? "00000000")!

            //write PC if it is enabled
            if swPC.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.EPC
                memItem = MEMORYITEM.mPC
                CSLRfidAppEngine.shared().reader.startTagMemoryWrite(MEMORYBANK.EPC, dataOffset: 1, dataCount: (UInt16(UInt32(txtPC.text!.count) / 4)), write: CSLBleReader.convertHexString(toData: txtPC.text!), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if (txtPC.backgroundColor) != UIColorFromRGB(0xffffff) {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                //set UI color to red if no tag access reponse returned
                if txtPC.backgroundColor == UIColorFromRGB(0xffffff) {
                    txtPC.backgroundColor = UIColorFromRGB(0xffb3b3)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }

            //write EPC if it is enabled
            if swEPC.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.EPC
                memItem = MEMORYITEM.mEPC
                CSLRfidAppEngine.shared().reader.startTagMemoryWrite(MEMORYBANK.EPC, dataOffset: 2, dataCount: (UInt16(UInt32(txtEPC.text!.count) / 4)), write: CSLBleReader.convertHexString(toData: txtEPC.text!), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtEPC.backgroundColor != UIColorFromRGB(0xffffff) {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                //set UI color to red if no tag access reponse returned
                if txtEPC.backgroundColor == UIColorFromRGB(0xffffff) {
                    txtEPC.backgroundColor = UIColorFromRGB(0xffb3b3)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }

            //write access password
            if swAccPwd.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.RESERVED
                memItem = MEMORYITEM.mACCPWD
                CSLRfidAppEngine.shared().reader.startTagMemoryWrite(MEMORYBANK.RESERVED, dataOffset: 2, dataCount: 2, write: CSLBleReader.convertHexString(toData: txtAccPwd.text!), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtAccPwd.backgroundColor != UIColorFromRGB(0xffffff) {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                //set UI color to red if no tag access reponse returned
                if txtAccPwd.backgroundColor == UIColorFromRGB(0xffffff) {
                    txtAccPwd.backgroundColor = UIColorFromRGB(0xffb3b3)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }

            //write kill password
            if swKillPwd.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.RESERVED
                memItem = MEMORYITEM.mKILLPWD
                CSLRfidAppEngine.shared().reader.startTagMemoryWrite(MEMORYBANK.RESERVED, dataOffset: 0, dataCount: 2, write: CSLBleReader.convertHexString(toData: txtKillPwd.text!), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtKillPwd.backgroundColor != UIColorFromRGB(0xffffff) {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                //set UI color to red if no tag access reponse returned
                if txtKillPwd.backgroundColor == UIColorFromRGB(0xffffff) {
                    txtKillPwd.backgroundColor = UIColorFromRGB(0xffb3b3)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }

            //write TID (bank2)
            if swTidUid.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.TID
                memItem = MEMORYITEM.mTID
                CSLRfidAppEngine.shared().reader.startTagMemoryWrite(MEMORYBANK.TID, dataOffset: UInt16(tidOffset), dataCount: UInt16(tidWordCount), write: CSLBleReader.convertHexString(toData: txtTidUid.text!), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if !(txtTidUid.backgroundColor == UIColorFromRGB(0xffffff)) {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                //set UI color to red if no tag access reponse returned
                if txtTidUid.backgroundColor == UIColorFromRGB(0xffffff) {
                    txtTidUid.backgroundColor = UIColorFromRGB(0xffb3b3)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }
            
            //write USER
            if swUser.isOn {
                CSLRfidAppEngine.shared().reader.setPowerMode(false)
                bankSelected = MEMORYBANK.USER
                memItem = MEMORYITEM.mUSER
                CSLRfidAppEngine.shared().reader.startTagMemoryWrite(MEMORYBANK.USER, dataOffset: UInt16(userOffset), dataCount: UInt16(userWordCount), write: CSLBleReader.convertHexString(toData: txtUser.text!), accpwd: accPwd, maskBank: MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtSelectedEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtSelectedEPC.text!))

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if txtUser.backgroundColor != UIColorFromRGB(0xffffff) {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
                }
                //set UI color to red if no tag access reponse returned
                if txtUser.backgroundColor == UIColorFromRGB(0xffffff) {
                    txtUser.backgroundColor = UIColorFromRGB(0xffb3b3)
                }
                //refresh UI
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.0))
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            }

            alert = UIAlertController(title: "Tag Write", message: "Completed", preferredStyle: .alert)
            ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            if let ok = ok {
                alert?.addAction(ok)
            }
            if let alert = alert {
                present(alert, animated: true)
            }

            btnRead.isEnabled = true
            btnSecurity.isEnabled = true
        }

    }

    @IBAction func btnSecurityPressed(_ sender: Any) {

        var tagLockVC: CSLTagLockVC?
        tagLockVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_TagLockVC") as? CSLTagLockVC

        if tagLockVC != nil {
            if let tagLockVC = tagLockVC {
                navigationController?.pushViewController(tagLockVC, animated: true)
            }
        }

    }

    @IBAction func txtSelectedEPCChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtSelectedEPC.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) {
            txtSelectedEPC.text = ""
        }
    }

    @IBAction func btnKillPressed(_ sender: Any) {

        var tagKillVC: CSLTagKillVC?
        tagKillVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_TagKillVC") as? CSLTagKillVC

        if let tagKillVC = tagKillVC {
            navigationController?.pushViewController(tagKillVC, animated: true)
        }
    }
    
    @IBAction func txtAccessPwdChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtAccessPwd.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) || txtAccessPwd.text!.count != 8 {
            txtAccessPwd.text = "00000000"
        }

    }

    @IBAction func txtPCChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtPC.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) || txtPC.text!.count != 4 {
            txtPC.text = ""
        }
    }

    @IBAction func txtEPCChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtEPC.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) {
            txtEPC.text = ""
        }

    }

    @IBAction func txtAccPwdChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtAccPwd.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) || txtAccPwd.text!.count != 8 {
            txtAccPwd.text = "00000000"
        }

    }

    @IBAction func txtKillPwdChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtKillPwd.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) || txtKillPwd.text!.count != 8 {
            txtKillPwd.text = "00000000"
        }
    }

    @IBAction func txtTidUidChanged(_ sender: Any) {
    }

    @IBAction func txtUserChanged(_ sender: Any) {
        //Validate if input is hex value
        let chars = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
        if ((txtUser.text!.uppercased() as NSString).rangeOfCharacter(from: chars).location != NSNotFound) {
            txtUser.text = ""
        }
    }

    @IBAction func txtPowerChanged(_ sender: Any) {
        if Int(txtPower.text!)! >= 0 && Int(txtPower.text!)! <= 320 {
            print("Power value entered: OK")
            CSLRfidAppEngine.shared().settings.power = Int32(txtPower.text!)!
            CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

            //set power and port
            if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
                CSLRfidAppEngine.shared().reader.selectAntennaPort(0)
            } else {
                CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(CSLRfidAppEngine.shared().settings!.tagAccessPort))
            }
            CSLRfidAppEngine.shared().reader.setPower(Double(CSLRfidAppEngine.shared().settings.power / 10))
        } else {
            txtPower.text = "\(CSLRfidAppEngine.shared().settings.power)"
        }

    }

    @IBAction func txtPortChanged(_ sender: Any) {
        if Int(txtPort.text!)! >= 1 && Int(txtPort.text!)! <= 4 {
            print("Port value entered: OK")
            CSLRfidAppEngine.shared().settings.tagAccessPort = Int32(txtPort.text!)! - 1
            CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

            //set power and port
            if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
                CSLRfidAppEngine.shared().reader.selectAntennaPort(0)
            } else {
                CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(CSLRfidAppEngine.shared().settings!.tagAccessPort))
            }
            CSLRfidAppEngine.shared().reader.setPower(Double(CSLRfidAppEngine.shared().settings.power / 10))
        }
        else {
            txtPort.text = "\(CSLRfidAppEngine.shared().settings.tagAccessPort + 1)"
        }
    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {
    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
        DispatchQueue.main.async(execute: {
            if tag?.accessCommand == ACCESSCMD.READ {
                //read command
                if self.bankSelected == MEMORYBANK.TID {
                    if self.swEPC.isOn {
                        self.txtEPC.text = tag?.epc
                    }
                    if self.swPC.isOn {
                        if let PC = tag?.pc {
                            self.txtPC.text = String(format: "%04X", PC)
                        }
                    }
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) && self.swTidUid.isOn {
                        self.txtTidUid.text = tag?.data.copy() as? String
                    }
                } else if self.bankSelected == MEMORYBANK.USER {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) && self.swUser.isOn {
                        self.txtUser.text! = tag?.data.copy() as! String
                    }
                } else if self.bankSelected == MEMORYBANK.RESERVED && self.memItem == MEMORYITEM.mACCPWD {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    let cnt = tag?.data?.count ?? 0
                    if cnt == 8 && (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        if self.swAccPwd.isOn {
                            self.txtAccPwd.text! = tag?.data.copy() as! String
                        }
                    }
                } else if self.bankSelected == MEMORYBANK.RESERVED && self.memItem == MEMORYITEM.mKILLPWD {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    let cnt = tag?.data?.count ?? 0
                    if cnt == 8 && (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        if self.swKillPwd.isOn {
                            self.txtKillPwd.text! = tag?.data.copy() as! String
                        }
                    }
                }
            } else if tag?.accessCommand == ACCESSCMD.WRITE {
                //write command
                if self.bankSelected == MEMORYBANK.EPC && self.memItem == MEMORYITEM.mEPC {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        self.txtEPC.backgroundColor = self.UIColorFromRGB(0xd1f2eb)
                    }
                } else if self.bankSelected == MEMORYBANK.EPC && self.memItem == MEMORYITEM.mPC {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        self.txtPC.backgroundColor = self.UIColorFromRGB(0xd1f2eb)
                    }
                } else if self.bankSelected == MEMORYBANK.RESERVED && self.memItem == MEMORYITEM.mACCPWD {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        self.txtAccPwd.backgroundColor = self.UIColorFromRGB(0xd1f2eb)
                    }
                } else if self.bankSelected == MEMORYBANK.RESERVED && self.memItem == MEMORYITEM.mKILLPWD {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        self.txtKillPwd.backgroundColor = self.UIColorFromRGB(0xd1f2eb)
                    }
                } else if self.bankSelected == MEMORYBANK.USER && self.memItem == MEMORYITEM.mUSER {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        self.txtUser.backgroundColor = self.UIColorFromRGB(0xd1f2eb)
                    }
                } else if self.bankSelected == MEMORYBANK.TID && self.memItem == MEMORYITEM.mTID {
                    let accessError = tag?.accessError
                    let crcError = tag?.crcError
                    let backScatterError = tag?.backScatterError
                    let ackTimeout = tag?.ackTimeout
                    if (accessError == 0xff) && (!crcError!) && (backScatterError == 0xff) && (!ackTimeout!) {
                        self.txtTidUid.backgroundColor = self.UIColorFromRGB(0xd1f2eb)
                    }
                }
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

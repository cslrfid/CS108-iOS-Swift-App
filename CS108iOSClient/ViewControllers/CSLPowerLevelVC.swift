//
//  CSLPowerLevelVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 2019-10-31.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLPowerLevelVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnSetPowerLevel: UIButton!
    @IBOutlet weak var txtPower1: UITextField!
    @IBOutlet weak var txtPower2: UITextField!
    @IBOutlet weak var txtPower3: UITextField!
    @IBOutlet weak var txtPower4: UITextField!
    @IBOutlet weak var txtPower5: UITextField!
    @IBOutlet weak var txtPower6: UITextField!
    @IBOutlet weak var txtPower7: UITextField!
    @IBOutlet weak var txtPower8: UITextField!
    @IBOutlet weak var txtPower9: UITextField!
    @IBOutlet weak var txtPower10: UITextField!
    @IBOutlet weak var txtPower11: UITextField!
    @IBOutlet weak var txtPower12: UITextField!
    @IBOutlet weak var txtPower13: UITextField!
    @IBOutlet weak var txtPower14: UITextField!
    @IBOutlet weak var txtPower15: UITextField!
    @IBOutlet weak var txtPower16: UITextField!
    @IBOutlet weak var txtDwell1: UITextField!
    @IBOutlet weak var txtDwell2: UITextField!
    @IBOutlet weak var txtDwell3: UITextField!
    @IBOutlet weak var txtDwell4: UITextField!
    @IBOutlet weak var txtDwell5: UITextField!
    @IBOutlet weak var txtDwell6: UITextField!
    @IBOutlet weak var txtDwell7: UITextField!
    @IBOutlet weak var txtDwell8: UITextField!
    @IBOutlet weak var txtDwell9: UITextField!
    @IBOutlet weak var txtDwell10: UITextField!
    @IBOutlet weak var txtDwell11: UITextField!
    @IBOutlet weak var txtDwell12: UITextField!
    @IBOutlet weak var txtDwell13: UITextField!
    @IBOutlet weak var txtDwell14: UITextField!
    @IBOutlet weak var txtDwell15: UITextField!
    @IBOutlet weak var txtDwell16: UITextField!
    @IBOutlet weak var txtNumberOfPowerLevel: UITextField!
    @IBOutlet var svPowerLevel: [UIStackView]!
    @IBOutlet weak var svNumberOfPowerLevel: UIStackView!
    @IBOutlet var lbPort1To4: [UILabel]!


    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Power Level"
        // Do any additional setup after loading the view.
        txtNumberOfPowerLevel.delegate = self
        var count = 1
        for sv in svPowerLevel {
            (sv.viewWithTag(10 * count + 1) as? UITextField)?.delegate = self
            (sv.viewWithTag(10 * count + 2) as? UITextField)?.delegate = self
            count += 1
        }
        btnSetPowerLevel.layer.borderWidth = 1.0
        btnSetPowerLevel.layer.borderColor = UIColor.lightGray.cgColor
        btnSetPowerLevel.layer.cornerRadius = 5.0


        //load settings from users defaults
        count = 1
        for sv in svPowerLevel {
            (sv.viewWithTag(10 * count + 1) as? UITextField)?.text = CSLRfidAppEngine.shared().settings.powerLevel[count - 1] as? String
            (sv.viewWithTag(10 * count + 2) as? UITextField)?.text = CSLRfidAppEngine.shared().settings.dwellTime[count - 1] as? String
            count += 1
        }

        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS463 {
            //set # power number level to 4
            txtNumberOfPowerLevel.text = "4"
            //Hide the power level input
            for view in svNumberOfPowerLevel.subviews {
                view.isHidden = true
            }
            //set the text power to port
            for label in lbPort1To4 {
                label.text = label.text?.replacingOccurrences(of: "Power", with: "Port")
            }

            for i in 0...3 {
                for view in (svPowerLevel[i]).subviews {
                    view.isHidden = false
                }
            }
            for i in 4...15 {
                for view in (svPowerLevel[i]).subviews {
                    view.isHidden = true
                }
            }
        } else {
            //set # power number level to what's in the users defaults
            txtNumberOfPowerLevel.text = "\(CSLRfidAppEngine.shared().settings.numberOfPowerLevel)"
            //Unhide the power level input
            for view in svNumberOfPowerLevel.subviews {
                view.isHidden = false
            }
            //set the text power to port
            for label in lbPort1To4 {
                label.text = label.text?.replacingOccurrences(of: "Port", with: "Power")
            }
            //Unhide and hide the correct level
            for i in CSLRfidAppEngine.shared().settings.numberOfPowerLevel...15 {
                for view in (svPowerLevel![Int(i)]).subviews {
                    view.isHidden = true
                }
            }
        }


    }

    @IBAction func txtPowerPressed(_ sender: Any) {

        let power = (sender as? UITextField)?.text ?? "-1"
        if Int(power)! < 0 || Int(power)! > 300 {
            //invalid input
            (sender as? UITextField)?.text =
                (CSLRfidAppEngine.shared().settings.powerLevel as NSMutableArray)[Int(((sender as! UITextField).tag / 10) - 1)] as? String
        }

    }

    @IBAction func txtDwellPressed(_ sender: Any) {
        
        let dwell = (sender as? UITextField)?.text ?? "-1"
        if Int(dwell)! < 0 || Int(dwell)! > 65535 {
            //invalid input
            (sender as? UITextField)?.text =
                (CSLRfidAppEngine.shared().settings.dwellTime as NSMutableArray)[Int(((sender as! UITextField).tag / 10) - 1)] as? String
        }
    }

    @IBAction func txtNumberOfPowerLevelPressed(_ sender: Any) {
        let powerLevel = Int(txtNumberOfPowerLevel.text ?? "-1")
        if powerLevel! < 0 || powerLevel! > 16 {
            txtNumberOfPowerLevel.text = "\(CSLRfidAppEngine.shared().settings.numberOfPowerLevel)"
            return
        }

        var count = 1
        for sv in svPowerLevel {
            if powerLevel! >= count {
                for view in sv.subviews {
                    view.isHidden = false
                }
            } else {
                for view in sv.subviews {
                    view.isHidden = true
                }
            }
            count += 1
        }
    }

    @IBAction func btnSetPowerLevelPressed(_ sender: Any) {
        var count = 1

        //store the UI input to the settings object on appEng
        CSLRfidAppEngine.shared().settings.numberOfPowerLevel = Int32(txtNumberOfPowerLevel.text ?? "-1")!

        CSLRfidAppEngine.shared().settings.powerLevel = NSMutableArray()
        CSLRfidAppEngine.shared().settings.powerLevel = []
        CSLRfidAppEngine.shared().settings.dwellTime = NSMutableArray()
        CSLRfidAppEngine.shared().settings.dwellTime = []

        for sv in svPowerLevel {
            (CSLRfidAppEngine.shared().settings.powerLevel as NSMutableArray).add(((sv.viewWithTag(10 * count + 1) as? UITextField)?.text ?? ""))
            (CSLRfidAppEngine.shared().settings.dwellTime as NSMutableArray).add(((sv.viewWithTag(10 * count + 2) as? UITextField)?.text ?? ""))
            count += 1
        }

        CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}

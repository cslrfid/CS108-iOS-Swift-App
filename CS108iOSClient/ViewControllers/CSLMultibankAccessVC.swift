//
//  CSLMultibankAccessVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 20/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLMultibankAccessVC: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var swEnableMultibank1: UISwitch!
    @IBOutlet weak var btnMultibank1Select: UIButton!
    @IBOutlet weak var txtMultibank1Offset: UITextField!
    @IBOutlet weak var txtMultibank1Size: UITextField!
    @IBOutlet weak var swEnableMultibank2: UISwitch!
    @IBOutlet weak var btnMultibank2Select: UIButton!
    @IBOutlet weak var txtMultibank2Offset: UITextField!
    @IBOutlet weak var txtMultibank2Size: UITextField!
    @IBOutlet weak var btnMultibankSave: UIButton!
    @IBOutlet weak var lbBank: UILabel!
    @IBOutlet weak var lbOffset: UILabel!
    @IBOutlet weak var lbSize: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btnMultibank1Select.layer.borderWidth = 1.0
        btnMultibank1Select.layer.borderColor = UIColor.lightGray.cgColor
        btnMultibank1Select.layer.cornerRadius = 5.0
        btnMultibank2Select.layer.borderWidth = 1.0
        btnMultibank2Select.layer.borderColor = UIColor.lightGray.cgColor
        btnMultibank2Select.layer.cornerRadius = 5.0
        btnMultibankSave.layer.borderWidth = 1.0
        btnMultibankSave.layer.borderColor = UIColor.clear.cgColor
        btnMultibankSave.layer.cornerRadius = 5.0

        txtMultibank1Offset.delegate = self
        txtMultibank1Size.delegate = self
        txtMultibank2Offset.delegate = self
        txtMultibank2Size.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {

        //reload previously stored settings
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        //refresh UI with stored values
        swEnableMultibank1.isOn = CSLRfidAppEngine.shared().settings.isMultibank1Enabled
        switch CSLRfidAppEngine.shared().settings.multibank1 {
        case MEMORYBANK.RESERVED:
                btnMultibank1Select.setTitle("RESERVED", for: .normal)
        case MEMORYBANK.EPC:
                btnMultibank1Select.setTitle("EPC", for: .normal)
        case MEMORYBANK.TID:
                btnMultibank1Select.setTitle("TID", for: .normal)
        case MEMORYBANK.USER:
                btnMultibank1Select.setTitle("USER", for: .normal)
            default:
                break
        }
        txtMultibank1Offset.text = "\(CSLRfidAppEngine.shared().settings.multibank1Offset)"
        txtMultibank1Size.text = "\(CSLRfidAppEngine.shared().settings.multibank1Length)"
        swEnableMultibank2.isOn = CSLRfidAppEngine.shared().settings.isMultibank2Enabled
        switch CSLRfidAppEngine.shared().settings.multibank2 {
        case MEMORYBANK.RESERVED:
                btnMultibank2Select.setTitle("RESERVED", for: .normal)
        case MEMORYBANK.EPC:
                btnMultibank2Select.setTitle("EPC", for: .normal)
        case MEMORYBANK.TID:
                btnMultibank2Select.setTitle("TID", for: .normal)
        case MEMORYBANK.USER:
                btnMultibank2Select.setTitle("USER", for: .normal)
            default:
                break
        }
        txtMultibank2Offset.text = "\(CSLRfidAppEngine.shared().settings.multibank2Offset)"
        txtMultibank2Size.text = "\(CSLRfidAppEngine.shared().settings.multibank2Length)"

        if !swEnableMultibank1.isOn {
            btnMultibank1Select.isEnabled = false
            txtMultibank1Offset.isEnabled = false
            txtMultibank1Size.isEnabled = false
            swEnableMultibank2.isHidden = true
            btnMultibank2Select.isHidden = true
            txtMultibank2Offset.isHidden = true
            txtMultibank2Size.isHidden = true
            lbBank.isHidden = true
            lbOffset.isHidden = true
            lbSize.isHidden = true
        } else {
            btnMultibank1Select.isEnabled = true
            txtMultibank1Offset.isEnabled = true
            txtMultibank1Size.isEnabled = true
            swEnableMultibank2.isHidden = false
            btnMultibank2Select.isHidden = false
            txtMultibank2Offset.isHidden = false
            txtMultibank2Size.isHidden = false
            lbBank.isHidden = false
            lbOffset.isHidden = false
            lbSize.isHidden = false
        }
        if !swEnableMultibank2.isOn {
            btnMultibank2Select.isEnabled = false
            txtMultibank2Offset.isEnabled = false
            txtMultibank2Size.isEnabled = false
        } else {
            btnMultibank2Select.isEnabled = true
            txtMultibank2Offset.isEnabled = true
            txtMultibank2Size.isEnabled = true
        }
    }

    /*
    #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func swEnableMultibank1Pressed(_ sender: Any) {
        if !swEnableMultibank1.isOn {
            btnMultibank1Select.isEnabled = false
            txtMultibank1Offset.isEnabled = false
            txtMultibank1Size.isEnabled = false
            swEnableMultibank2.isHidden = true
            btnMultibank2Select.isHidden = true
            txtMultibank2Offset.isHidden = true
            txtMultibank2Size.isHidden = true
            lbBank.isHidden = true
            lbOffset.isHidden = true
            lbSize.isHidden = true
        } else {
            btnMultibank1Select.isEnabled = true
            txtMultibank1Offset.isEnabled = true
            txtMultibank1Size.isEnabled = true
            swEnableMultibank2.isHidden = false
            btnMultibank2Select.isHidden = false
            txtMultibank2Offset.isHidden = false
            txtMultibank2Size.isHidden = false
            lbBank.isHidden = false
            lbOffset.isHidden = false
            lbSize.isHidden = false
        }
    }

    @IBAction func btnMultibank1SelectPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Multibank 1", message: "Please select bank", preferredStyle: .actionSheet)
        let reserved = UIAlertAction(title: "RESERVED", style: .default, handler: { action in
                self.btnMultibank1Select.setTitle("RESERVED", for: .normal)
            }) // RESERVED
        let epc = UIAlertAction(title: "EPC", style: .default, handler: { action in
                self.btnMultibank1Select.setTitle("EPC", for: .normal)
            }) // EPC
        let tid = UIAlertAction(title: "TID", style: .default, handler: { action in
                self.btnMultibank1Select.setTitle("TID", for: .normal)
            }) // TID
        let user = UIAlertAction(title: "USER", style: .default, handler: { action in
                self.btnMultibank1Select.setTitle("USER", for: .normal)
            }) // USER

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(reserved)
        alert.addAction(epc)
        alert.addAction(tid)
        alert.addAction(user)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func txtMultibank1OffsetPressed(_ sender: Any) {
        if (Int(txtMultibank1Offset.text ?? "-1") ?? -1) >= 0 && (Int(txtMultibank1Offset.text ?? "-1") ?? -1) <= 32 {
            print("Bank1 offset value entered: OK")
        } else {
            txtMultibank1Offset.text = "\(CSLRfidAppEngine.shared().settings.multibank1Offset)"
        }
    }

    @IBAction func txtMultibank1SizePressed(_ sender: Any) {
        if (Int(txtMultibank1Size.text ?? "-1") ?? -1) >= 0 && (Int(txtMultibank1Size.text ?? "-1") ?? -1) <= 32 {
            print("Bank1 size value entered: OK")
        } else {
            txtMultibank1Size.text = "\(CSLRfidAppEngine.shared().settings.multibank1Length)"
        }
    }

    @IBAction func swEnableMultibank2Pressed(_ sender: Any) {
        if !swEnableMultibank2.isOn {
            btnMultibank2Select.isEnabled = false
            txtMultibank2Offset.isEnabled = false
            txtMultibank2Size.isEnabled = false
        } else {
            btnMultibank2Select.isEnabled = true
            txtMultibank2Offset.isEnabled = true
            txtMultibank2Size.isEnabled = true
        }
    }

    @IBAction func btnMultibank2SelectPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Multibank 2", message: "Please select bank", preferredStyle: .actionSheet)
        let reserved = UIAlertAction(title: "RESERVED", style: .default, handler: { action in
                self.btnMultibank2Select.setTitle("RESERVED", for: .normal)
            }) // RESERVED
        let epc = UIAlertAction(title: "EPC", style: .default, handler: { action in
                self.btnMultibank2Select.setTitle("EPC", for: .normal)
            }) // EPC
        let tid = UIAlertAction(title: "TID", style: .default, handler: { action in
                self.btnMultibank2Select.setTitle("TID", for: .normal)
            }) // TID
        let user = UIAlertAction(title: "USER", style: .default, handler: { action in
                self.btnMultibank2Select.setTitle("USER", for: .normal)
            }) // USER

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(reserved)
        alert.addAction(epc)
        alert.addAction(tid)
        alert.addAction(user)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func txtMultibank2OffsetPressed(_ sender: Any) {
        if (Int(txtMultibank2Offset.text ?? "-1") ?? -1) >= 0 && (Int(txtMultibank2Offset.text ?? "-1") ?? -1) <= 32 {
            print("Bank2 offset value entered: OK")
        } else {
            txtMultibank2Offset.text = "\(CSLRfidAppEngine.shared().settings.multibank2Offset)"
        }
    }

    @IBAction func txtMultibank2SizePressed(_ sender: Any) {
        if (Int(txtMultibank2Size.text ?? "-1") ?? -1) >= 0 && (Int(txtMultibank2Size.text ?? "-1") ?? -1) <= 32 {
            print("Bank2 size value entered: OK")
        } else {
            txtMultibank2Size.text = "\(CSLRfidAppEngine.shared().settings.multibank2Length)"
        }
    }

    @IBAction func btnMultibankSavePressed(_ sender: Any) {
        //store the UI input to the settings object on appEng
        CSLRfidAppEngine.shared().settings.isMultibank1Enabled = swEnableMultibank1.isOn
        if btnMultibank1Select.titleLabel?.text?.compare("RESERVED") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank1 = MEMORYBANK.RESERVED
        }
        if btnMultibank1Select.titleLabel?.text?.compare("EPC") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank1 = MEMORYBANK.EPC
        }
        if btnMultibank1Select.titleLabel?.text?.compare("TID") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank1 = MEMORYBANK.TID
        }
        if btnMultibank1Select.titleLabel?.text?.compare("USER") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank1 = MEMORYBANK.USER
        }
        CSLRfidAppEngine.shared().settings.multibank1Offset = UInt8(txtMultibank1Offset.text!) ?? 0
        CSLRfidAppEngine.shared().settings.multibank1Length = UInt8(txtMultibank1Size.text!) ?? 0
        CSLRfidAppEngine.shared().settings.isMultibank2Enabled = swEnableMultibank2.isOn
        if btnMultibank2Select.titleLabel?.text?.compare("RESERVED") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.RESERVED
        }
        if btnMultibank2Select.titleLabel?.text?.compare("EPC") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.EPC
        }
        if btnMultibank2Select.titleLabel?.text?.compare("TID") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.TID
        }
        if btnMultibank2Select.titleLabel?.text?.compare("USER") == .orderedSame {
            CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.USER
        }
        CSLRfidAppEngine.shared().settings.multibank2Offset = UInt8(txtMultibank2Offset.text!) ?? 0
        CSLRfidAppEngine.shared().settings.multibank2Length = UInt8(txtMultibank2Size.text!) ?? 0
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

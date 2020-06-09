//
//  CSLSettingsVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLSettingsVC: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var btnSaveConfig: UIButton!
    @IBOutlet weak var btnSession: UIButton!
    @IBOutlet weak var btnAlgorithm: UIButton!
    @IBOutlet weak var btnLinkProfile: UIButton!
    @IBOutlet weak var btnTarget: UIButton!
    @IBOutlet weak var btnQOverride: UISwitch!
    @IBOutlet weak var txtQValue: UITextField!
    @IBOutlet weak var txtTagPopulation: UITextField!
    @IBOutlet weak var txtPower: UITextField!
    @IBOutlet weak var swSound: UISwitch!
    @IBOutlet weak var btnPowerLevel: UIButton!
    @IBOutlet weak var btnAntennaSettings: UIButton!
    @IBOutlet weak var btnRfLna: UIButton!
    @IBOutlet weak var btnIfLna: UIButton!
    @IBOutlet weak var btnAgcGain: UIButton!
    @IBOutlet weak var swLnaHighComp: UISwitch!
    @IBOutlet weak var swTagFocus: UISwitch!
    @IBOutlet weak var btnRegion: UIButton!
    @IBOutlet weak var btnFrequencyChannel: UIButton!
    @IBOutlet weak var btnFrequencyOrder: UIButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        navigationItem.title = "Settings"


        btnSaveConfig.layer.borderWidth = 1.0
        btnSaveConfig.layer.borderColor = UIColor.clear.cgColor
        btnSaveConfig.layer.cornerRadius = 5.0


        btnSession.layer.borderWidth = 1.0
        btnSession.layer.borderColor = UIColor.lightGray.cgColor
        btnSession.layer.cornerRadius = 5.0

        btnAlgorithm.layer.borderWidth = 1.0
        btnAlgorithm.layer.borderColor = UIColor.lightGray.cgColor
        btnAlgorithm.layer.cornerRadius = 5.0

        btnLinkProfile.layer.borderWidth = 1.0
        btnLinkProfile.layer.borderColor = UIColor.lightGray.cgColor
        btnLinkProfile.layer.cornerRadius = 5.0

        btnTarget.layer.borderWidth = 1.0
        btnTarget.layer.borderColor = UIColor.lightGray.cgColor
        btnTarget.layer.cornerRadius = 5.0

        btnPowerLevel.layer.borderWidth = 1.0
        btnPowerLevel.layer.borderColor = UIColor.lightGray.cgColor
        btnPowerLevel.layer.cornerRadius = 5.0

        btnAntennaSettings.layer.borderWidth = 1.0
        btnAntennaSettings.layer.borderColor = UIColor.lightGray.cgColor
        btnAntennaSettings.layer.cornerRadius = 5.0

        btnRfLna.layer.borderWidth = 1.0
        btnRfLna.layer.borderColor = UIColor.lightGray.cgColor
        btnRfLna.layer.cornerRadius = 5.0

        btnIfLna.layer.borderWidth = 1.0
        btnIfLna.layer.borderColor = UIColor.lightGray.cgColor
        btnIfLna.layer.cornerRadius = 5.0

        btnAgcGain.layer.borderWidth = 1.0
        btnAgcGain.layer.borderColor = UIColor.lightGray.cgColor
        btnAgcGain.layer.cornerRadius = 5.0

        btnRegion.layer.borderWidth = 1.0
        btnRegion.layer.borderColor = UIColor.lightGray.cgColor
        btnRegion.layer.cornerRadius = 5.0

        btnFrequencyChannel.layer.borderWidth = 1.0
        btnFrequencyChannel.layer.borderColor = UIColor.lightGray.cgColor
        btnFrequencyChannel.layer.cornerRadius = 5.0

        btnFrequencyOrder.layer.borderWidth = 1.0
        btnFrequencyOrder.layer.borderColor = UIColor.lightGray.cgColor
        btnFrequencyOrder.layer.cornerRadius = 5.0
   
        txtQValue.delegate = self
        txtTagPopulation.delegate = self
        txtPower.delegate = self

        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS463 {
            btnAntennaSettings.isHidden = false
        } else {
            btnAntennaSettings.isHidden = true
        }
        
        //pre-populate the region and frequency info
        let channel = Int(CSLRfidAppEngine.shared().settings.channel)!
        let region = CSLRfidAppEngine.shared().settings.region!
        btnRegion.setTitle(CSLRfidAppEngine.shared().settings.region, for: .normal)
        btnFrequencyChannel.setTitle(
            (CSLRfidAppEngine.shared().readerRegionFrequency.tableOfFrequencies[region] as! NSArray)[channel] as? String,
            for: .normal)
        if CSLRfidAppEngine.shared().readerRegionFrequency.isFixed != 0 {
            btnFrequencyOrder.setTitle("Fixed", for: .normal)
            btnFrequencyChannel.isEnabled = true
        } else {
            btnFrequencyOrder.setTitle("Hopping", for: .normal)
            btnFrequencyChannel.isEnabled = false
        }

        if CSLRfidAppEngine.shared().readerRegionFrequency.freqModFlag != 0 {
            btnRegion.isEnabled = false
        } else {
            btnRegion.isEnabled = true
        }


    }

    override func viewWillAppear(_ animated: Bool) {

        //reload previously stored settings
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        //refresh UI with stored values
        txtPower.text = "\(CSLRfidAppEngine.shared().settings.power)"
        txtTagPopulation.text = "\(CSLRfidAppEngine.shared().settings.tagPopulation)"
        btnQOverride.isOn = CSLRfidAppEngine.shared().settings.isQOverride
        txtQValue.text = "\(CSLRfidAppEngine.shared().settings.qValue)"
        swSound.isOn = CSLRfidAppEngine.shared().settings.enableSound

        switch CSLRfidAppEngine.shared().settings.target {
            case TARGET.A:
                btnTarget.setTitle("A", for: .normal)
            case TARGET.B:
                btnTarget.setTitle("B", for: .normal)
            case TARGET.ToggleAB:
                btnTarget.setTitle("Toggle A/B", for: .normal)
            default:
                break
        }
        switch CSLRfidAppEngine.shared().settings.session {
            case SESSION.S0:
                btnSession.setTitle("S0", for: .normal)
            case SESSION.S1:
                btnSession.setTitle("S1", for: .normal)
            case SESSION.S2:
                btnSession.setTitle("S2", for: .normal)
            case SESSION.S3:
                btnSession.setTitle("S3", for: .normal)
            default:
                break
        }
        switch CSLRfidAppEngine.shared().settings.algorithm {
            case QUERYALGORITHM.FIXEDQ:
                btnAlgorithm.setTitle("FixedQ", for: .normal)
            case QUERYALGORITHM.DYNAMICQ:
                btnAlgorithm.setTitle("DynamicQ", for: .normal)
            default:
                break
        }
        switch CSLRfidAppEngine.shared().settings.linkProfile {
            case LINKPROFILE.MULTIPATH_INTERFERENCE_RESISTANCE:
                btnLinkProfile.setTitle("0. Multipath Interference Resistance", for: .normal)
            case LINKPROFILE.RANGE_DRM:
                btnLinkProfile.setTitle("1. Range/Dense Reader", for: .normal)
            case LINKPROFILE.RANGE_THROUGHPUT_DRM:
                btnLinkProfile.setTitle("2. Range/Throughput/Dense Reader", for: .normal)
            case LINKPROFILE.MAX_THROUGHPUT:
                btnLinkProfile.setTitle("3. Max Throughput", for: .normal)
            default:
                break
        }

        if CSLRfidAppEngine.shared().settings.tagFocus != 0 {
            swTagFocus.isOn = true
        } else {
            swTagFocus.isOn = false
        }
        if CSLRfidAppEngine.shared().settings.rfLnaHighComp != 0 {
            swLnaHighComp.isOn = true
        } else {
            swLnaHighComp.isOn = false
        }

        switch CSLRfidAppEngine.shared().settings.rfLna {
            case 0:
                btnRfLna.setTitle("1 dB", for: .normal)
            case 2:
                btnRfLna.setTitle("7 dB", for: .normal)
            case 3:
                btnRfLna.setTitle("13 dB", for: .normal)
            default:
                break
        }
        switch CSLRfidAppEngine.shared().settings.ifLna {
            case 0:
                btnIfLna.setTitle("24 dB", for: .normal)
            case 1:
                btnIfLna.setTitle("18 dB", for: .normal)
            case 3:
                btnIfLna.setTitle("12 dB", for: .normal)
            case 7:
                btnIfLna.setTitle("6 dB", for: .normal)
            default:
                break
        }
        switch CSLRfidAppEngine.shared().settings.ifAgc {
            case 0:
                btnAgcGain.setTitle("-12 dB", for: .normal)
            case 4:
                btnAgcGain.setTitle("-6 dB", for: .normal)
            case 6:
                btnAgcGain.setTitle("0 dB", for: .normal)
            case 7:
                btnAgcGain.setTitle("6 dB", for: .normal)
            default:
                break
        }


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnSessionPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Session", message: "Please select session", preferredStyle: .actionSheet)
        let s0 = UIAlertAction(title: "S0", style: .default, handler: { action in
                self.btnSession.setTitle("S0", for: .normal)
            }) // S0
        let s1 = UIAlertAction(title: "S1", style: .default, handler: { action in
                self.btnSession.setTitle("S1", for: .normal)
            }) // S1
        let s2 = UIAlertAction(title: "S2", style: .default, handler: { action in
                self.btnSession.setTitle("S2", for: .normal)
            }) // S2
        let s3 = UIAlertAction(title: "S3", style: .default, handler: { action in
                self.btnSession.setTitle("S3", for: .normal)
            }) // S3

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(s0)
        alert.addAction(s1)
        alert.addAction(s2)
        alert.addAction(s3)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func btnAlgorithmPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Query Algorithm", message: "Please select algorithm", preferredStyle: .actionSheet)
        let fixedQ = UIAlertAction(title: "FixedQ", style: .default, handler: { action in
                self.btnAlgorithm.setTitle("FixedQ", for: .normal)
            }) // FixedQ
        let dynamicQ = UIAlertAction(title: "DynamicQ", style: .default, handler: { action in
                self.btnAlgorithm.setTitle("DynamicQ", for: .normal)
            }) // DynamicQ

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(fixedQ)
        alert.addAction(dynamicQ)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnLinkProfilePressed(_ sender: Any) {

        let alert = UIAlertController(title: "Link Profile", message: "Please select profile", preferredStyle: .actionSheet)
        let profile0 = UIAlertAction(title: "0. Multipath Interference Resistance", style: .default, handler: { action in
                self.btnLinkProfile.setTitle("0. Multipath Interference Resistance", for: .normal)
            }) // 0
        let profile1 = UIAlertAction(title: "1. Range/Dense Reader", style: .default, handler: { action in
                self.btnLinkProfile.setTitle("1. Range/Dense Reader", for: .normal)
            }) // 1
        let profile2 = UIAlertAction(title: "2. Range/Throughput/Dense Reader", style: .default, handler: { action in
                self.btnLinkProfile.setTitle("2. Range/Throughput/Dense Reader", for: .normal)
            }) // 2
        let profile3 = UIAlertAction(title: "3. Max Throughput", style: .default, handler: { action in
                self.btnLinkProfile.setTitle("3. Max Throughput", for: .normal)
            }) // 3

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(profile0)
        alert.addAction(profile1)
        alert.addAction(profile2)
        alert.addAction(profile3)
        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnTargetPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Target", message: "Please select target", preferredStyle: .actionSheet)
        let A = UIAlertAction(title: "A", style: .default, handler: { action in
                self.btnTarget.setTitle("A", for: .normal)
            }) // A
        let B = UIAlertAction(title: "B", style: .default, handler: { action in
                self.btnTarget.setTitle("B", for: .normal)
            }) // B
        let ToggleAB = UIAlertAction(title: "Toggle A/B", style: .default, handler: { action in
                self.btnTarget.setTitle("Toggle A/B", for: .normal)
            }) // Toggle A/B

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(A)
        alert.addAction(B)
        alert.addAction(ToggleAB)

        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func btnQOverridePressed(_ sender: Any) {

        if btnQOverride.isOn {
            txtQValue.isEnabled = true
        } else {
            //recalucate Q value based on tag populatioin
            txtQValue.text = "\(Int(log2(Double(Int(txtTagPopulation.text!)! * 2)) + 1))"
            txtQValue.isEnabled = false
        }

    }

    @IBAction func txtQValueChanged(_ sender: Any) {
        if (Int(txtQValue.text!) != nil) && (Int(txtQValue.text ?? "") ?? -1) >= 0 && (Int(txtQValue.text ?? "") ?? -1) <= 15 {
            print("Q value entered: OK")
        } else {
            txtQValue.text = "\(CSLRfidAppEngine.shared().settings.qValue)"
        }

    }

    @IBAction func txtTagPopulationChanged(_ sender: Any) {

        if (Int(txtTagPopulation.text!) != nil) && (Int(txtTagPopulation.text ?? "") ?? -1) >= 1 && (Int(txtTagPopulation.text ?? "") ?? -1) <= 8192 {
            print("Tag population entered: OK")
            //recalucate Q value based on tag populatioin if q override is disabled
            if !btnQOverride.isOn {
                txtQValue.text = "\(Int(log2(Double(Int(txtTagPopulation.text!)! * 2)) + 1))"
            }
        } else {
            txtTagPopulation.text = "\(CSLRfidAppEngine.shared().settings.tagPopulation)"
        }

    }

    @IBAction func txtPowerChanged(_ sender: Any) {
        if (Int(txtPower.text!) != nil) && (Int(txtPower.text ?? "") ?? -1) >= 0 && (Int(txtPower.text ?? "") ?? -1) <= 300 {
            print("Power value entered: OK")
        } else {
            txtPower.text = "\(CSLRfidAppEngine.shared().settings.power)"
        }

    }

    @IBAction func btnSaveConfigPressed(_ sender: Any) {

        //store the UI input to the settings object on appEng
        CSLRfidAppEngine.shared().settings.power = Int32(txtPower.text!)!
        CSLRfidAppEngine.shared().settings.tagPopulation = Int32(txtTagPopulation.text!)!
        CSLRfidAppEngine.shared().settings.isQOverride = btnQOverride.isOn
        CSLRfidAppEngine.shared().settings.qValue = Int32(txtQValue.text!)!
        if btnTarget.titleLabel?.text?.compare("A") == .orderedSame {
            CSLRfidAppEngine.shared().settings.target = TARGET.A
        }
        if btnTarget.titleLabel?.text?.compare("B") == .orderedSame {
            CSLRfidAppEngine.shared().settings.target = TARGET.B
        }
        if btnTarget.titleLabel?.text?.compare("Toggle A/B") == .orderedSame {
            CSLRfidAppEngine.shared().settings.target = TARGET.ToggleAB
        }
        if btnSession.titleLabel?.text?.compare("S0") == .orderedSame {
            CSLRfidAppEngine.shared().settings.session = SESSION.S0
        }
        if btnSession.titleLabel?.text?.compare("S1") == .orderedSame {
            CSLRfidAppEngine.shared().settings.session = SESSION.S1
        }
        if btnSession.titleLabel?.text?.compare("S2") == .orderedSame {
            CSLRfidAppEngine.shared().settings.session = SESSION.S2
        }
        if btnSession.titleLabel?.text?.compare("S3") == .orderedSame {
            CSLRfidAppEngine.shared().settings.session = SESSION.S3
        }
        if btnAlgorithm.titleLabel?.text?.compare("FixedQ") == .orderedSame {
            CSLRfidAppEngine.shared().settings.algorithm = QUERYALGORITHM.FIXEDQ
        }
        if btnAlgorithm.titleLabel?.text?.compare("DynamicQ") == .orderedSame {
            CSLRfidAppEngine.shared().settings.algorithm = QUERYALGORITHM.DYNAMICQ
        }
        if btnLinkProfile.titleLabel?.text?.compare("0. Multipath Interference Resistance") == .orderedSame {
            CSLRfidAppEngine.shared().settings.linkProfile = LINKPROFILE.MULTIPATH_INTERFERENCE_RESISTANCE
        }
        if btnLinkProfile.titleLabel?.text?.compare("1. Range/Dense Reader") == .orderedSame {
            CSLRfidAppEngine.shared().settings.linkProfile = LINKPROFILE.RANGE_DRM
        }
        if btnLinkProfile.titleLabel?.text?.compare("2. Range/Throughput/Dense Reader") == .orderedSame {
            CSLRfidAppEngine.shared().settings.linkProfile = LINKPROFILE.RANGE_THROUGHPUT_DRM
        }
        if btnLinkProfile.titleLabel?.text?.compare("3. Max Throughput") == .orderedSame {
            CSLRfidAppEngine.shared().settings.linkProfile = LINKPROFILE.MAX_THROUGHPUT
        }
        CSLRfidAppEngine.shared().settings.enableSound = swSound.isOn

        if swTagFocus.isOn {
            CSLRfidAppEngine.shared().settings.tagFocus = 1
        } else {
            CSLRfidAppEngine.shared().settings.tagFocus = 0
        }

        if swLnaHighComp.isOn {
            CSLRfidAppEngine.shared().settings.rfLnaHighComp = 1
        } else {
            CSLRfidAppEngine.shared().settings.rfLnaHighComp = 0
        }

        if btnRfLna.titleLabel?.text?.compare("1 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.rfLna = 0
        }
        if btnRfLna.titleLabel?.text?.compare("7 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.rfLna = 2
        }
        if btnRfLna.titleLabel?.text?.compare("13 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.rfLna = 3
        }

        if btnIfLna.titleLabel?.text?.compare("24 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifLna = 0
        }
        if btnIfLna.titleLabel?.text?.compare("18 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifLna = 1
        }
        if btnIfLna.titleLabel?.text?.compare("12 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifLna = 3
        }
        if btnIfLna.titleLabel?.text?.compare("6 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifLna = 7
        }

        if btnAgcGain.titleLabel?.text?.compare("-12 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifAgc = 0
        }
        if btnAgcGain.titleLabel?.text?.compare("-6 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifAgc = 4
        }
        if btnAgcGain.titleLabel?.text?.compare("0 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifAgc = 6
        }
        if btnAgcGain.titleLabel?.text?.compare("6 dB") == .orderedSame {
            CSLRfidAppEngine.shared().settings.ifAgc = 7
        }

        let channel = btnFrequencyChannel.titleLabel?.text
        let region = btnRegion.titleLabel?.text

        CSLRfidAppEngine.shared().settings.region = region
        for i in 0..<((CSLRfidAppEngine.shared().readerRegionFrequency.tableOfFrequencies[region!] as? NSArray)?.count ?? 0) {
            if (((CSLRfidAppEngine.shared().readerRegionFrequency.tableOfFrequencies[region!] as! NSArray)[i] as? String) == channel) {
                CSLRfidAppEngine.shared().settings.channel = "\(i)"
            }
        }

        
        CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

    }

    @IBAction func swTagFocusChanged(_ sender: Any) {
        if swTagFocus.isOn {
            btnSession.setTitle("S1", for: .normal)
            btnSession.isEnabled = false

            btnTarget.setTitle("A", for: .normal)
            btnTarget.isEnabled = false
        } else {
            btnSession.isEnabled = true
            btnTarget.isEnabled = true
        }
    }

    @IBAction func btnFrequencyOrderPressed(_ sender: Any) {
        //do nothing
    }

    @IBAction func btnFrequencyChannelPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Channel",
            message: "Please select",
            preferredStyle: .actionSheet)

        for channel in (CSLRfidAppEngine.shared().readerRegionFrequency.tableOfFrequencies[btnRegion.titleLabel?.text ?? ""] as! NSArray) {
            guard let channel = channel as? String else {
                continue
            }
            let listItem = UIAlertAction(title: channel, style: .default, handler: { action in
                self.btnFrequencyChannel.setTitle(channel, for: .normal)
            })
            alert.addAction(listItem)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func btnRegionPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Region",
            message: "Please select",
            preferredStyle: .actionSheet)

        for region in CSLRfidAppEngine.shared().readerRegionFrequency.regionList {
            let listItem = UIAlertAction(title: (region as! String), style: .default, handler: { action in
                self.btnRegion.setTitle((region as! String), for: .normal)
                self.btnFrequencyChannel.setTitle(
                    (CSLRfidAppEngine.shared().readerRegionFrequency.tableOfFrequencies[region] as? NSArray)![0] as? String,
                    for: .normal)
            })
            alert.addAction(listItem)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func btnAgcGainPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "IF-AGC",
            message: "Please select",
            preferredStyle: .actionSheet)
        let dBm12 = UIAlertAction(title: "-12 dB", style: .default, handler: { action in
            self.btnAgcGain.setTitle("-12 dB", for: .normal)
        }) // -12 dB
        let dBm6 = UIAlertAction(title: "-6 dB", style: .default, handler: { action in
            self.btnAgcGain.setTitle("-6 dB", for: .normal)
        }) // -6 dB
        let dB0 = UIAlertAction(title: "0 dB", style: .default, handler: { action in
            self.btnAgcGain.setTitle("0 dB", for: .normal)
        }) // 0 dB
        let dB6 = UIAlertAction(title: "6 dB", style: .default, handler: { action in
            self.btnAgcGain.setTitle("6 dB", for: .normal)
        }) // 6 dB

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(dBm12)
        alert.addAction(dBm6)
        alert.addAction(dB0)
        alert.addAction(dB6)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnIfLnaPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "IF-LNA",
            message: "Please select",
            preferredStyle: .actionSheet)
        let dB24 = UIAlertAction(title: "24 dB", style: .default, handler: { action in
            self.btnIfLna.setTitle("24 dB", for: .normal)
        }) // 24 dB
        let dB18 = UIAlertAction(title: "18 dB", style: .default, handler: { action in
            self.btnIfLna.setTitle("18 dB", for: .normal)
        }) // 18 dB
        let dB12 = UIAlertAction(title: "12 dB", style: .default, handler: { action in
            self.btnIfLna.setTitle("12 dB", for: .normal)
        }) // 12 dB
        let dB6 = UIAlertAction(title: "6 dB", style: .default, handler: { action in
            self.btnIfLna.setTitle("6 dB", for: .normal)
        }) // 6 dB

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(dB24)
        alert.addAction(dB18)
        alert.addAction(dB12)
        alert.addAction(dB6)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnRfLnaPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "RF-LNA",
            message: "Please select",
            preferredStyle: .actionSheet)
        let dB1 = UIAlertAction(title: "1 dB", style: .default, handler: { action in
            self.btnRfLna.setTitle("1 dB", for: .normal)
        }) // 1 dB
        let dB7 = UIAlertAction(title: "7 dB", style: .default, handler: { action in
            self.btnRfLna.setTitle("7 dB", for: .normal)
        }) // 7 dB
        let dB13 = UIAlertAction(title: "13 dB", style: .default, handler: { action in
            self.btnRfLna.setTitle("13 dB", for: .normal)
        }) // 13 dB

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(dB1)
        alert.addAction(dB7)
        alert.addAction(dB13)

        alert.addAction(cancel)

        present(alert, animated: true)

    }

    
    @IBAction func btnPowerLevelPressed(_ sender: Any) {

        var powerLevelVC: CSLPowerLevelVC?
        powerLevelVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_PowerLevelVC") as? CSLPowerLevelVC

        if powerLevelVC != nil {
            if let powerLevelVC = powerLevelVC {
                navigationController!.pushViewController(powerLevelVC, animated: true)
            }
        }


    }

    @IBAction func btnAntennaSettingsPressed(_ sender: Any) {

        var antennaPortVC: CSLAntennaPortVC?
        antennaPortVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_AntennaPortVC") as? CSLAntennaPortVC

        if antennaPortVC != nil {
            if let antennaPortVC = antennaPortVC {
                navigationController!.pushViewController(antennaPortVC, animated: true)
            }
        }

    }

    @IBAction func btnRadioSettingsPressed(_ sender: Any) {
    }

    @IBAction func btnMQTTClientPressed(_ sender: Any) {
        var mqttSettings: CSLMQTTClientSettings?
        mqttSettings = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_MQTTSettingsVC") as? CSLMQTTClientSettings

        if mqttSettings != nil {
            if let mqttSettings = mqttSettings {
                navigationController!.pushViewController(mqttSettings, animated: true)
            }
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}

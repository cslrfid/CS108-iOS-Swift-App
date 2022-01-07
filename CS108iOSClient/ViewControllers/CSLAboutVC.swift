//
//  CSLAboutVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 23/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLAboutVC: UIViewController {
    
    @IBOutlet weak var lbAppVersion: UILabel!
    @IBOutlet weak var lbBtFirmwareVersion: UILabel!
    @IBOutlet weak var lbRfidFirmwareVersion: UILabel!
    @IBOutlet weak var lbSiLabIcFirmwareVersion: UILabel!
    @IBOutlet weak var lbSerialNumber: UILabel!
    @IBOutlet weak var lbBoardVersion: UILabel!
    @IBOutlet weak var btnPrivacyStatement: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnPrivacyStatement.layer.borderWidth = 1.0
        btnPrivacyStatement.layer.borderColor = UIColor.clear.cgColor
        btnPrivacyStatement.layer.cornerRadius = 5.0
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "About"

        lbBtFirmwareVersion.text = CSLRfidAppEngine.shared().readerInfo.btFirmwareVersion
        lbAppVersion.text = CSLRfidAppEngine.shared().readerInfo.appVersion
        lbRfidFirmwareVersion.text = CSLRfidAppEngine.shared().readerInfo.rfidFirmwareVersion
        lbSiLabIcFirmwareVersion.text = CSLRfidAppEngine.shared().readerInfo.siLabICFirmwareVersion
        lbSerialNumber.text = CSLRfidAppEngine.shared().readerInfo.deviceSerialNumber
        lbBoardVersion.text = CSLRfidAppEngine.shared().readerInfo.pcbBoardVersion
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPrivacyStatementPressed(_ sender: Any) {

        let url = URL(string: "https://www.convergence.com.hk/apps-privacy-policy/")

        if let url = url {
            UIApplication.shared.open(url, options: [:])
        }
    }

}

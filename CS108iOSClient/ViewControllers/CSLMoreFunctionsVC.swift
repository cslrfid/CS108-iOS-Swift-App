//
//  CSLMoreFunctionsVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 19/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//


@objcMembers class CSLMoreFunctionsVC: UIViewController {
    
    let CSL_VC_RFIDTAB_PREFILTER_VC_IDX = 0
    let CSL_VC_RFIDTAB_PREFILTER_IDX = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        view.isUserInteractionEnabled = true

    }
    
    @IBAction func btnMultibankPressed(_ sender: Any) {
        var multibank: CSLMultibankAccessVC?
        multibank = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_MultibankVC") as? CSLMultibankAccessVC

        if multibank != nil {
            if let multibank = multibank {
                navigationController?.pushViewController(multibank, animated: true)
            }
        }

    }

    @IBAction func btnFiltersPressed(_ sender: Any) {

        let tabVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_FilterTabVC") as? CSLFilterTabVC

        tabVC?.setActiveView(CSL_VC_RFIDTAB_PREFILTER_VC_IDX)
        view.isUserInteractionEnabled = false
        if let tabVC = tabVC {
            navigationController?.pushViewController(tabVC, animated: true)
        }

    }

    @IBAction func btnMQTTPressed(_ sender: Any) {
        var mqttSettings: CSLMQTTClientSettings?
        mqttSettings = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_MQTTSettingsVC") as? CSLMQTTClientSettings

        if mqttSettings != nil {
            if let mqttSettings = mqttSettings {
                navigationController?.pushViewController(mqttSettings, animated: true)
            }
        }

    }
}

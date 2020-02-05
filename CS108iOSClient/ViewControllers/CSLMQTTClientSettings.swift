//
//  CSLMQTTClientSettings.swift
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 7/1/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLMQTTClientSettings: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtBrokerAddress: UITextField!
    @IBOutlet weak var txtBrokerPort: UITextField!
    @IBOutlet weak var txtClientID: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var swEnableTLS: UISwitch!
    @IBOutlet weak var txtQoS: UITextField!
    @IBOutlet weak var swRetained: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var swMQTTEnabled: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btnSave.layer.borderWidth = 1.0
        btnSave.layer.borderColor = UIColor.clear.cgColor
        btnSave.layer.cornerRadius = 5.0

        navigationItem.title = "MQTT Settings"
    }

    override func viewWillAppear(_ animated: Bool) {

        //reload previously stored settings
        CSLRfidAppEngine.shared().reloadMQTTSettingsFromUserDefaults()

        //refresh UI with stored values
        swMQTTEnabled.isOn = CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled
        txtBrokerAddress.text = CSLRfidAppEngine.shared().mqttSettings.brokerAddress
        txtBrokerPort.text = "\(CSLRfidAppEngine.shared().mqttSettings.brokerPort)"
        txtClientID.text = CSLRfidAppEngine.shared().mqttSettings.clientId
        txtUserName.text = CSLRfidAppEngine.shared().mqttSettings.userName
        txtPassword.text = CSLRfidAppEngine.shared().mqttSettings.password
        swEnableTLS.isOn = CSLRfidAppEngine.shared().mqttSettings.isTLSEnabled
        txtQoS.text = "\(CSLRfidAppEngine.shared().mqttSettings.qoS)"
        swRetained.isOn = CSLRfidAppEngine.shared().mqttSettings.retained

        txtQoS.delegate = self
        txtClientID.delegate = self
        txtPassword.delegate = self
        txtUserName.delegate = self
        txtBrokerPort.delegate = self
        txtBrokerAddress.delegate = self
    }

    /*
    #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnSavePressed(_ sender: Any) {
        //store the UI input to the settings object on appEng
        CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled = swMQTTEnabled.isOn
        CSLRfidAppEngine.shared().mqttSettings.brokerAddress = txtBrokerAddress.text ?? ""
        CSLRfidAppEngine.shared().mqttSettings.brokerPort = Int32(txtBrokerPort.text ?? "") ?? 0
        CSLRfidAppEngine.shared().mqttSettings.clientId = txtClientID.text ?? ""
        CSLRfidAppEngine.shared().mqttSettings.userName = txtUserName.text ?? ""
        CSLRfidAppEngine.shared().mqttSettings.password = txtPassword.text ?? ""
        CSLRfidAppEngine.shared().mqttSettings.isTLSEnabled = swEnableTLS.isOn
        CSLRfidAppEngine.shared().mqttSettings.qoS = Int32(txtQoS.text ?? "") ?? 0
        CSLRfidAppEngine.shared().mqttSettings.retained = swRetained.isOn

        CSLRfidAppEngine.shared().saveMQTTSettingsToUserDefaults()

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

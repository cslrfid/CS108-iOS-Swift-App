//
//  CSLMoreFunctionsVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 19/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLMoreFunctionsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    /*
    #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
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

        let alert = UIAlertController(title: "Not Available", message: "Feature to be implemented", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

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

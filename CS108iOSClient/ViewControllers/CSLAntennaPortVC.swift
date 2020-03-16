//
//  CSLAntennaPortVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 2019-11-01.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLAntennaPortVC: UIViewController {
    
    @IBOutlet weak var btnAntennaPorts: UIButton!
    @IBOutlet var swAntennaPort: [UISwitch]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        navigationItem.title = "Antenna Ports"

        btnAntennaPorts.layer.borderWidth = 1.0
        btnAntennaPorts.layer.borderColor = UIColor.lightGray.cgColor
        btnAntennaPorts.layer.cornerRadius = 5.0

        var count = 0
        for sw in swAntennaPort {
            print("Switch \(count): \((CSLRfidAppEngine.shared().settings.isPortEnabled[count] as? NSNumber)?.boolValue ?? false ? "ON" : "OFF")")
            sw.isOn = (CSLRfidAppEngine.shared().settings.isPortEnabled[count] as? NSNumber)?.boolValue ?? false
            count += 1
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
    @IBAction func btnAntennaPortsPressed(_ sender: Any) {

        var count = 0

        CSLRfidAppEngine.shared().settings.isPortEnabled = NSMutableArray()
        CSLRfidAppEngine.shared().settings.isPortEnabled = []


        for sw in swAntennaPort {
            (CSLRfidAppEngine.shared().settings.isPortEnabled as NSMutableArray).add(NSNumber(value: sw.isOn))
            count += 1
        }

        CSLRfidAppEngine.shared().saveSettingsToUserDefaults()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

    }
}

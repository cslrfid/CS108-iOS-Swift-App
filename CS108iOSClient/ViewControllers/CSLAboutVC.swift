//
//  CSLAboutVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 23/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLAboutVC: UIViewController {
    
    @IBOutlet weak var lbAppVersion: UILabel!
    @IBOutlet weak var lbBtFirmwareVersion: UILabel!
    @IBOutlet weak var lbRfidFirmwareVersion: UILabel!
    @IBOutlet weak var lbSiLabIcFirmwareVersion: UILabel!
    @IBOutlet weak var lbSerialNumber: UILabel!
    @IBOutlet weak var lbBoardVersion: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

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
    /*
    #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

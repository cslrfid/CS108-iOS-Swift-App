//
//  CSLHomeVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import UIKit

@objcMembers class CSLHomeVC: UIViewController,  CSLBleReaderDelegate {
    
    @IBOutlet weak var btnConnectReader: UIButton!
    @IBOutlet weak var lbConnectReader: UILabel!
    @IBOutlet weak var lbReaderStatus: UILabel!
    @IBOutlet weak var actHomeSpinner: UIActivityIndicatorView!
    @IBOutlet weak var btnReadTemperature: UIButton!

    
    private var scrRefreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //timer event on updating UI

    }

    @objc func refreshBatteryInfo() {
        autoreleasepool {
            if CSLRfidAppEngine.shared().reader.connectStatus != STATUS.NOT_CONNECTED {
                if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
                    if CSLRfidAppEngine.shared().readerInfo.batteryPercentage < 0 || CSLRfidAppEngine.shared().readerInfo.batteryPercentage > 100 {
                        lbReaderStatus.text = "Battery: -"
                    } else {
                        lbReaderStatus.text = String(format: "Battery: %d%%", CSLRfidAppEngine.shared().readerInfo.batteryPercentage)
                    }
                }
            } else {
                lbReaderStatus.text = ""
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {

        actHomeSpinner.stopAnimating()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
        view.isUserInteractionEnabled = true

        //reload configurations from Users Defaults to memory
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        //check if reader is connected
        if CSLRfidAppEngine.shared().reader.connectStatus != STATUS.NOT_CONNECTED {
            lbConnectReader.text = "Connected: \(CSLRfidAppEngine.shared().reader.deviceName ?? "")"
            btnConnectReader.imageView?.image = UIImage(named: "connected")
            btnConnectReader.imageView?.setNeedsDisplay()
        } else {
            lbConnectReader.text = "Press to Connect"
            btnConnectReader.imageView?.image = UIImage(named: "disconnected")
            btnConnectReader.imageView?.setNeedsDisplay()
        }

        //remove tag buffer
        CSLRfidAppEngine.shared().reader.filteredBuffer = nil
        CSLRfidAppEngine.shared().reader.filteredBuffer = NSMutableArray.init()
        //refresh MQTT (all previosu connections will drop) and temperature tag settings
        CSLRfidAppEngine.shared().mqttSettings = CSLMQTTSettings()
        CSLRfidAppEngine.shared().reloadMQTTSettingsFromUserDefaults()
        CSLRfidAppEngine.shared().temperatureSettings = CSLTemperatureTagSettings()
        CSLRfidAppEngine.shared().reloadTemperatureTagSettingsFromUserDefaults()
        CSLRfidAppEngine.shared().settings = CSLReaderSettings()
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        CSLRfidAppEngine.shared().reader.readerDelegate = self
        scrRefreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshBatteryInfo), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        CSLRfidAppEngine.shared().reader.readerDelegate = nil
        scrRefreshTimer?.invalidate()
        scrRefreshTimer = nil
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
    @IBAction func btnInventoryPressed(_ sender: Any) {

        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let alert = UIAlertController(title: "Reader NOT connected", message: "Please connect to reader first.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            actHomeSpinner.startAnimating()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
            view.isUserInteractionEnabled = false
            showTabInterfaceActiveView(Int32(CSLTabVC.CSL_VC_RFIDTAB_INVENTORY_VC_IDX))
        }


    }

    func showTabInterfaceActiveView(_ identifier: Int32) {
        let tabVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_TabVC") as? CSLTabVC
        tabVC?.setActiveView(Int(identifier))

        if tabVC != nil {
            if let tabVC = tabVC {
                navigationController?.pushViewController(tabVC, animated: true)
            }
        }
    }

    func showTemperatureTabInterfaceActiveView(_ identifier: Int32) {
        let tabVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_TempTabVC") as? CSLTemperatureTabVC
        tabVC?.setActiveView(Int(identifier))

        if tabVC != nil {
            if let tabVC = tabVC {
                navigationController?.pushViewController(tabVC, animated: true)
            }
        }
    }

    @IBAction func btnSettingsPressed(_ sender: Any) {
        var settingsVC: CSLSettingsVC?

        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let alert = UIAlertController(title: "Reader NOT connected", message: "Please connect to reader first.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            settingsVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_SettingsVC") as? CSLSettingsVC

            if settingsVC != nil {
                if let settingsVC = settingsVC {
                    navigationController?.pushViewController(settingsVC, animated: true)
                }
            }
        }
    }

    @IBAction func btnConnectReaderPressed(_ sender: Any) {
        var deviceTV: CSLDeviceTV?

        //if device is connected, will ask user if they want to disconnect it
        if CSLRfidAppEngine.shared().reader.connectStatus != STATUS.NOT_CONNECTED && CSLRfidAppEngine.shared().reader.connectStatus != STATUS.SCANNING {

            let alert = UIAlertController(title: CSLRfidAppEngine.shared().reader.deviceName, message: "Disconnect reader?", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in

                    //stop scanning for device
                    CSLRfidAppEngine.shared().reader.barcodeReader(false)
                    CSLRfidAppEngine.shared().reader.power(onRfid: false)
                    CSLRfidAppEngine.shared().reader.disconnectDevice()
                    //connect to device selected
                    self.lbConnectReader.text = "Press to Connect"
                    self.btnConnectReader.imageView?.image = UIImage(named: "disconnected")
                    self.btnConnectReader.imageView?.setNeedsDisplay()

                })

            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    self.btnConnectReader.imageView?.image = UIImage(named: "connected")
                    self.btnConnectReader.imageView?.setNeedsDisplay()
                })

            alert.addAction(ok)
            alert.addAction(cancel)

            present(alert, animated: true)
        } else {
            deviceTV = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_DeviceTV") as? CSLDeviceTV

            if deviceTV != nil {
                if let deviceTV = deviceTV {
                    navigationController?.pushViewController(deviceTV, animated: true)
                }
            }
        }
    }

    @IBAction func btnAboutPressed(_ sender: Any) {
        var aboutVC: CSLAboutVC?

        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            let appBuildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

            let alert = UIAlertController(title: "App Version", message: "v\(appVersionString ?? "") Build \(appBuildString ?? "")", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                })
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            aboutVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_AboutVC") as? CSLAboutVC

            if aboutVC != nil {
                if let aboutVC = aboutVC {
                    navigationController?.pushViewController(aboutVC, animated: true)
                }
            }
        }

    }

    @IBAction func btnTagAccessPressed(_ sender: Any) {

        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let alert = UIAlertController(title: "Reader NOT connected", message: "Please connect to reader first.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            actHomeSpinner.startAnimating()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
            view.isUserInteractionEnabled = false
            showTabInterfaceActiveView(Int32(CSLTabVC.CSL_VC_RFIDTAB_ACCESS_VC_IDX))
        }



    }

    @IBAction func btnTagSearchPressed(_ sender: Any) {

        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let alert = UIAlertController(title: "Reader NOT connected", message: "Please connect to reader first.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            actHomeSpinner.startAnimating()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
            view.isUserInteractionEnabled = false
            showTabInterfaceActiveView(Int32(CSLTabVC.CSL_VC_RFIDTAB_SEARCH_VC_IDX))
        }



    }

    @IBAction func btnFunctionsPressed(_ sender: Any) {

        var funcVC: CSLMoreFunctionsVC?
        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let alert = UIAlertController(title: "Reader NOT connected", message: "Please connect to reader first.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            funcVC = UIStoryboard(name: "CSLRfidDemoApp", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_FuncVC") as? CSLMoreFunctionsVC

            if funcVC != nil {
                if let funcVC = funcVC {
                    navigationController?.pushViewController(funcVC, animated: true)
                }
            }
        }


    }

    @IBAction func btnReadTemperaturePressed(_ sender: Any) {
        //if no device is connected, the settings page will not be loaded
        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.NOT_CONNECTED || CSLRfidAppEngine.shared().reader.connectStatus == STATUS.SCANNING {

            let alert = UIAlertController(title: "Reader NOT connected", message: "Please connect to reader first.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            actHomeSpinner.startAnimating()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
            view.isUserInteractionEnabled = false
            showTemperatureTabInterfaceActiveView(Int32(CSLTemperatureTabVC.CSL_VC_TEMPTAB_READTEMP_VC_IDX))
        }



    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
        //define delegate method to be implemented within another class
    }

    func didTriggerKeyChangedState(_ sender: CSLBleReader?, keyState state: Bool) {
        //define delegate method to be implemented within another class
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = battPct
    }

    func didReceiveBarcodeData(_ sender: CSLBleReader?, scannedBarcode barcode: CSLReaderBarcode?) {
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }
}

//
//  CSLDeviceTV.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 18/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import QuartzCore

@objcMembers class CSLDeviceTV: UITableViewController {
    
    @IBOutlet var tblDeviceList: UITableView!
    @IBOutlet weak var actSpinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // navigationItem?.rightBarButtonItem = editButtonItem
        CSLRfidAppEngine.shared().reader.startScanDevice()

        navigationItem.title = "Search for Devices..."

        actSpinner.stopAnimating()

        //timer event on updating UI
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshDeviceList), userInfo: nil, repeats: true)


    }

    @objc func refreshDeviceList() {
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        CSLRfidAppEngine.shared().reader.stopScanDevice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CSLRfidAppEngine.shared().reader.bleDeviceList.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let deviceName = CSLRfidAppEngine.shared().reader.deviceListName[indexPath.row] as? String
        var cell = tableView.dequeueReusableCell(withIdentifier: deviceName ?? "")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: deviceName)
        }

        cell?.textLabel?.text = deviceName
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: CSLRfidAppEngine.shared().reader.deviceListName[indexPath.row] as? String, message: "Connect to reader selected?", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.actSpinner.startAnimating()
                //stop scanning for device
                CSLRfidAppEngine.shared().reader.stopScanDevice()
                //connect to device selected
            CSLRfidAppEngine.shared().reader.connectDevice(CSLRfidAppEngine.shared()?.reader.bleDeviceList[indexPath.row] as! CBPeripheral?)

            for _ in 0..<COMMAND_TIMEOUT_5S {
                    //receive data or time out in 5 seconds
                    if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.CONNECTED {
                        break
                    }
                    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
                }

            if CSLRfidAppEngine.shared().reader.connectStatus != STATUS.CONNECTED {
                    print("Failed to connect to reader.")
                } else {

                //set device name to singleton object
                CSLRfidAppEngine.shared().reader.deviceName = CSLRfidAppEngine.shared().reader.deviceListName[indexPath.row] as? String
                var btFwVersion: NSString?
                var slVersion: NSString?
                var rfidBoardSn: NSString?
                var pcbBoardVersion: NSString?
                var rfidFwVersion: NSString?
                var appVersion: String?
                    
                let btFwVersionPtr = AutoreleasingUnsafeMutablePointer<NSString?>?.init(&btFwVersion)
                let slVersionPtr = AutoreleasingUnsafeMutablePointer<NSString?>?.init(&slVersion)
                let rfidBoardSnPtr = AutoreleasingUnsafeMutablePointer<NSString?>?.init(&rfidBoardSn)
                let pcbBoardVersionPtr = AutoreleasingUnsafeMutablePointer<NSString?>?.init(&pcbBoardVersion)
                let rfidFwVersionPtr = AutoreleasingUnsafeMutablePointer<NSString?>?.init(&rfidFwVersion)
                    
                    //Configure reader
                    CSLRfidAppEngine.shared().reader.barcodeReader(true)
                    CSLRfidAppEngine.shared().reader.power(onRfid: false)
                    CSLRfidAppEngine.shared().reader.power(onRfid: true)
                    if CSLRfidAppEngine.shared().reader.getBtFirmwareVersion(btFwVersionPtr) {
                        CSLRfidAppEngine.shared().readerInfo.btFirmwareVersion = btFwVersionPtr?.pointee as String?
                    }
                    if CSLRfidAppEngine.shared().reader.getSilLabIcVersion(slVersionPtr) {
                        CSLRfidAppEngine.shared().readerInfo.siLabICFirmwareVersion = slVersionPtr?.pointee as String?
                    }
                    if CSLRfidAppEngine.shared().reader.getRfidBrdSerialNumber(rfidBoardSnPtr) {
                        CSLRfidAppEngine.shared().readerInfo.deviceSerialNumber = rfidBoardSnPtr?.pointee as String?
                    }
                    if CSLRfidAppEngine.shared().reader.getPcBBoardVersion(pcbBoardVersionPtr) {
                        CSLRfidAppEngine.shared().readerInfo.pcbBoardVersion = pcbBoardVersionPtr?.pointee as String?
                    }
        
                CSLRfidAppEngine.shared().reader.batteryInfo.setPcbVersion(pcbBoardVersionPtr?.pointee?.doubleValue ?? 0.0)

                    CSLRfidAppEngine.shared().reader.sendAbortCommand()

                    if CSLRfidAppEngine.shared().reader.getRfidFwVersionNumber(rfidFwVersionPtr) {
                        CSLRfidAppEngine.shared().readerInfo.rfidFirmwareVersion = rfidFwVersionPtr?.pointee as String?
                    }


                    if let object = Bundle.main.infoDictionary?["CFBundleShortVersionString"], let object1 = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] {
                        appVersion = "v\(object) Build \(object1)"
                    }
                    CSLRfidAppEngine.shared().readerInfo.appVersion = appVersion

                if (btFwVersionPtr?.pointee?.length ?? 0) >= 5 {
                        if (((btFwVersion as NSString?)?.substring(to: 1)) == "3") {
                            //if BT firmware version is greater than v3, it is connecting to CS463
                            CSLRfidAppEngine.shared().reader.readerModelNumber = READERTYPE.CS463
                        } else {
                            CSLRfidAppEngine.shared().reader.readerModelNumber = READERTYPE.CS108
                            CSLRfidAppEngine.shared().reader.startBatteryAutoReporting()
                        }
                    }


                    self.actSpinner.stopAnimating()
                }


            self.navigationController!.popToRootViewController(animated: true)
            })

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)

        present(alert, animated: true)

    }


}

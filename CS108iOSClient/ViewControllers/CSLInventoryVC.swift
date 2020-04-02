//
//  CSLInventoryVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import AudioToolbox

@objcMembers class CSLInventoryVC : UIViewController, CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate, MQTTSessionDelegate {

    @IBOutlet weak var lbTagCount: UILabel!
    @IBOutlet weak var lbTagRate: UILabel!
    @IBOutlet weak var lbUniqueTagRate: UILabel!
    @IBOutlet weak var btnInventory: UIButton!
    @IBOutlet weak var tblTagList: UITableView!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbClear: UIButton!
    @IBOutlet weak var lbMode: UILabel!
    @IBOutlet weak var uivSendTagData: UIView!
    @IBOutlet weak var actInventorySpinner: UIActivityIndicatorView!

    var tagRangingStartTime: Date? = nil
    private var scrRefreshTimer: Timer?
    private var swipeGestureRecognizer: UISwipeGestureRecognizer?
    private var tempImageView: UIImageView?
    private var transport: MQTTCFSocketTransport?
    private var session: MQTTSession?
    private var isMQTTConnected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBarController?.title = "Inventory"

        btnInventory.layer.borderWidth = 1.0
        btnInventory.layer.borderColor = UIColor.clear.cgColor
        btnInventory.layer.cornerRadius = 5.0

        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        swipeGestureRecognizer?.direction = .left
        swipeGestureRecognizer?.numberOfTouchesRequired = 1
        if let swipeGestureRecognizer = swipeGestureRecognizer {
            view.addGestureRecognizer(swipeGestureRecognizer)
        }

        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        swipeGestureRecognizer?.direction = .right
        swipeGestureRecognizer?.numberOfTouchesRequired = 1
        if let swipeGestureRecognizer = swipeGestureRecognizer {
            view.addGestureRecognizer(swipeGestureRecognizer)
        }

        tblTagList.estimatedRowHeight = 45.0
        tblTagList.rowHeight = UITableView.automaticDimension
    }

    @objc func handleSwipes(_ gestureRecognizer: UISwipeGestureRecognizer?) {
        autoreleasepool {

            if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.TAG_OPERATIONS {
                return
            }

            if tempImageView?.accessibilityIdentifier?.contains("tagList-bg-rfid-swipe") ?? false {
                tempImageView = UIImageView(image: UIImage(named: "tagList-bg-barcode-swipe"))
                tempImageView?.accessibilityIdentifier = "tagList-bg-barcode-swipe"
                tempImageView?.frame = tblTagList.frame
                tblTagList.backgroundView = tempImageView
                CSLRfidAppEngine.shared().soundAlert(kSystemSoundID_Vibrate)
                CSLRfidAppEngine.shared().isBarcodeMode = true
                lbMode.text = "Mode: BC"
                lbClear.sendActions(for: .touchUpInside)
            } else {
                tempImageView = UIImageView(image: UIImage(named: "tagList-bg-rfid-swipe"))
                tempImageView?.accessibilityIdentifier = "tagList-bg-rfid-swipe"
                tempImageView?.frame = tblTagList.frame
                tblTagList.backgroundView = tempImageView
                CSLRfidAppEngine.shared().soundAlert(kSystemSoundID_Vibrate)
                CSLRfidAppEngine.shared().isBarcodeMode = false
                lbMode.text = "Mode: RFID"
                lbClear.sendActions(for: .touchUpInside)
            }
        }
    }
    
    //Selector for timer event on updating UI
    @objc func refreshTagListing() {
        autoreleasepool {
            if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.TAG_OPERATIONS {
                CSLRfidAppEngine.shared().soundAlert(1005)
                //update table
                tblTagList.reloadData()

                //update inventory count
                lbTagCount.text = String(format: "%ld", tblTagList.numberOfRows(inSection: 0))

                //update tag rate
                print(String(format: "Total Tag Count: %ld, Unique Tag Coun t: %ld, time elapsed: %ld", Int(CSLRfidAppEngine.shared().reader.rangingTagCount), Int(CSLRfidAppEngine.shared().reader.uniqueTagCount), Int(tagRangingStartTime?.timeIntervalSinceReferenceDate ?? 0)))
                lbTagRate.text = String(format: "%ld", Int(CSLRfidAppEngine.shared().reader.rangingTagCount))
                lbUniqueTagRate.text = String(format: "%ld", Int(CSLRfidAppEngine.shared().reader.uniqueTagCount))
                CSLRfidAppEngine.shared().reader.rangingTagCount = 0
                CSLRfidAppEngine.shared().reader.uniqueTagCount = 0
            } else if CSLRfidAppEngine.shared().isBarcodeMode {
                //update table
                tblTagList.reloadData()
            }

            if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
                if CSLRfidAppEngine.shared().readerInfo.batteryPercentage < 0 || CSLRfidAppEngine.shared().readerInfo.batteryPercentage > 100 {
                    lbStatus.text = "Battery: -"
                } else {
                    lbStatus.text = String(format: "Battery: %d%%", CSLRfidAppEngine.shared().readerInfo.batteryPercentage)
                }
            }
            
            if CSLRfidAppEngine.shared().reader.lastMacErrorCode != 0x0000 {
                let alert = UIAlertController(title: "RFID Error", message: String(format: "Error Code: 0x%04X", CSLRfidAppEngine.shared().reader.lastMacErrorCode), preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true)
                CSLRfidAppEngine.shared().reader.lastMacErrorCode = 0x0000
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.title = "Inventory"

        //clear UI
        lbTagRate.text = "0"
        lbTagCount.text = "0"
        CSLRfidAppEngine.shared().reader.filteredBuffer.removeAllObjects()

        tblTagList.dataSource = self
        tblTagList.delegate = self
        tblTagList.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tblTagList.bounds.size.width, height: 0.01))
        tblTagList.reloadData()

        CSLRfidAppEngine.shared().reader.delegate = self
        CSLRfidAppEngine.shared().reader.readerDelegate = self

        tempImageView = UIImageView(image: UIImage(named: "tagList-bg-rfid-swipe"))
        tempImageView?.accessibilityIdentifier = "tagList-bg-rfid-swipe"
        tempImageView?.frame = tblTagList.frame
        tblTagList.backgroundView = tempImageView

        //timer event on updating UI
        scrRefreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshTagListing), userInfo: nil, repeats: true)
        if let scrRefreshTimer = scrRefreshTimer {
            RunLoop.main.add(scrRefreshTimer, forMode: .common)
        }

        if CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled {
            transport = MQTTCFSocketTransport()
            transport?.host = CSLRfidAppEngine.shared().mqttSettings.brokerAddress
            transport?.port = UInt32(CSLRfidAppEngine.shared().mqttSettings.brokerPort)
            transport?.tls = CSLRfidAppEngine.shared().mqttSettings.isTLSEnabled

            session = MQTTSession()
            session?.transport = transport
            session?.userName = CSLRfidAppEngine.shared().mqttSettings.userName
            session?.password = CSLRfidAppEngine.shared().mqttSettings.password
            session?.keepAliveInterval = 60
            session?.clientId = CSLRfidAppEngine.shared().mqttSettings.clientId
            session?.willFlag = true
            session?.willMsg = "offline".data(using: .utf8)
            session?.willTopic = "devices/\(CSLRfidAppEngine.shared().mqttSettings.clientId)/messages/events/"
            session?.willQoS = MQTTQosLevel(rawValue: UInt8(CSLRfidAppEngine.shared().mqttSettings.qoS))!
            session?.willRetainFlag = CSLRfidAppEngine.shared().mqttSettings.retained

            uivSendTagData.isHidden = false

            session?.connect(connectHandler: { error in
                if error == nil {
                    print("Connected to MQTT Broker")
                    let alert = UIAlertController(title: "MQTT broker", message: "Connected", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                    self.isMQTTConnected = true
                } else {
                    print("Fail connecting to MQTT Broker")
                    let alert = UIAlertController(title: "MQTT broker", message: "Error: \(error.debugDescription)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                    self.isMQTTConnected = false
                }
            })
        } else {
            uivSendTagData.isHidden = true
        }

        // Do any additional setup after loading the view.
        (tabBarController as? CSLTabVC)?.setAntennaPortsAndPowerForTags()
        (tabBarController as? CSLTabVC)?.setConfigurationsForTags()

    }

    override func viewWillDisappear(_ animated: Bool) {

        actInventorySpinner.stopAnimating()
        view.isUserInteractionEnabled = true

        //stop inventory if it is still running
        if btnInventory.isEnabled {
            if (btnInventory.currentTitle == "Stop") {
                btnInventory.sendActions(for: .touchUpInside)
            }
        }

        //remove delegate assignment so that trigger key will not triggered when out of this page
        CSLRfidAppEngine.shared().reader.delegate = nil
        CSLRfidAppEngine.shared().reader.readerDelegate = nil

        tblTagList.dataSource = nil
        tblTagList.delegate = nil

        scrRefreshTimer?.invalidate()
        scrRefreshTimer = nil

        CSLRfidAppEngine.shared().isBarcodeMode = false
        if let swipeGestureRecognizer = swipeGestureRecognizer {
            view.removeGestureRecognizer(swipeGestureRecognizer)
        }

        session?.disconnect()
        transport?.close()
        session = nil
        transport = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnInventoryPressed(_ sender: Any) {

        if CSLRfidAppEngine.shared().isBarcodeMode && (btnInventory.currentTitle == "Start") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnInventory.isEnabled = false

            CSLRfidAppEngine.shared().reader.startBarcodeReading()
            btnInventory.setTitle("Stop", for: .normal)
            btnInventory.isEnabled = true
        } else if CSLRfidAppEngine.shared().isBarcodeMode && (btnInventory.currentTitle == "Stop") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnInventory.isEnabled = false

            CSLRfidAppEngine.shared().reader.stopBarcodeReading()
            btnInventory.setTitle("Start", for: .normal)
            btnInventory.isEnabled = true
        } else if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.CONNECTED && (btnInventory.currentTitle == "Start") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnInventory.isEnabled = false

            //start inventory
            tagRangingStartTime = Date()
            CSLRfidAppEngine.shared().reader.startInventory()
            btnInventory.setTitle("Stop", for: .normal)
            btnInventory.isEnabled = true
        } else if (btnInventory.currentTitle == "Stop") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            if CSLRfidAppEngine.shared().reader.stopInventory() {
                btnInventory.setTitle("Start", for: .normal)
                btnInventory.isEnabled = true
            } else {
                btnInventory.setTitle("Stop", for: .normal)
                btnInventory.isEnabled = true
            }
        }


    }

    @IBAction func btnClearTable(_ sender: Any) {
        //clear UI
        lbTagRate.text = "0"
        lbTagCount.text = "0"
        CSLRfidAppEngine.shared().reader.filteredBuffer.removeAllObjects()
        tblTagList.reloadData()
    }

    @IBAction func btnSendTagData(_ sender: Any) {
        //check MQTT settings.  Connect to broker and send tag data
        //var allTagPublishedSuccess = true
        if CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled && isMQTTConnected == true {
            let alert = UIAlertController(title: "MQTT broker", message: "Send Tag Data?", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    for tag in CSLRfidAppEngine.shared().reader.filteredBuffer {
                        //build an info object and convert to json
                        let info = [
                            "messageId" : UUID().uuidString,
                            "rssi" : (tag as? CSLBleTag)?.rssi.description,
                            "EPC" : (tag as? CSLBleTag)?.epc
                        ]

                        var _: Error?
                        var jsonData: Data? = nil
                        do {
                            jsonData = try JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
                        } catch let err {
                            print("Failed serializing data: \(err.localizedDescription)")
                        }
                        let retain = CSLRfidAppEngine.shared().mqttSettings.retained
                        let level = CSLRfidAppEngine.shared().mqttSettings.qoS
                        var topic: String? = nil
                        if let clientId = self.session?.clientId {
                            topic = "devices/\(clientId)/messages/events/"
                        }

                        self.session?.publishData(jsonData, onTopic: topic, retain: retain, qos: MQTTQosLevel(rawValue: UInt8(level))!, publishHandler: { error in
                            if error != nil {
                                let epc=(tag as? CSLBleTag)?.epc
                                print("Failed sending EPC=\(String(describing: epc)) to MQTT broker. Error message: \(error.debugDescription)")
                            }
                        })
                    }
                })

            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {
    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
        //[tagListing reloadData];
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
        //no used
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = battPct
    }

    func didTriggerKeyChangedState(_ sender: CSLBleReader?, keyState state: Bool) {

        DispatchQueue.main.async(execute: {
            if self.btnInventory.isEnabled {
                if state {
                    if (self.btnInventory.currentTitle == "Start") {
                        self.btnInventory.sendActions(for: .touchUpInside)
                    }
                } else {
                    if (self.btnInventory.currentTitle == "Stop") {
                        self.btnInventory.sendActions(for: .touchUpInside)
                    }
                }
            }
        })
    }

    func didReceiveBarcodeData(_ sender: CSLBleReader?, scannedBarcode barcode: CSLReaderBarcode?) {
        CSLRfidAppEngine.shared().soundAlert(1005)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CSLRfidAppEngine.shared().reader.filteredBuffer.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: CSLTagListCell?
        //for rfid data
        if (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] is CSLBleTag) {

            let epc = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag)?.epc
            let data1 = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag)?.data1
            let data1bank = bankEnum(toString: CSLRfidAppEngine.shared().settings.multibank1)
            let data2 = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag)?.data2
            let data2bank = bankEnum(toString: CSLRfidAppEngine.shared().settings.multibank2)
            let rssi = Int((CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag)?.rssi ?? 0)
            let portNumber = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag)?.portNumber ?? 0

            cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as? CSLTagListCell
            if cell == nil {
                tableView.register(UINib(nibName: "CSLTagListCell", bundle: nil), forCellReuseIdentifier: "TagCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as? CSLTagListCell
            }

            if data1 != nil && data2 != nil {
                cell?.lbCellEPC?.text = "\(indexPath.row + 1) \u{25CF} \(epc ?? "")"
                if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS463 {
                    cell?.lbCellBank?.text = "\(data1bank ?? "")=\(data1 ?? "")\n\(data2bank ?? "")=\(data2 ?? "")\nRSSI: \(rssi) | Port: \(portNumber + 1)"
                } else {
                    cell?.lbCellBank?.text = "\(data1bank ?? "")=\(data1 ?? "")\n\(data2bank ?? "")=\(data2 ?? "")\nRSSI: \(rssi)"
                }
            } else if data1 != nil {
                cell?.lbCellEPC?.text = "\(indexPath.row + 1) \u{25CF} \(epc ?? "")"
                cell?.lbCellBank?.text = "\(data1bank ?? "")=\(data1 ?? "")\nRSSI: \(rssi)"
                if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS463 {
                    cell?.lbCellBank?.text = "\(data1bank ?? "")=\(data1 ?? "")\nRSSI: \(rssi) | Port: \(portNumber + 1)"
                } else {
                    cell?.lbCellBank?.text = "\(data1bank ?? "")=\(data1 ?? "")\nRSSI: \(rssi)"
                }
            } else {
                cell?.lbCellEPC?.text = "\(indexPath.row + 1) \u{25CF} \(epc ?? "")"
                if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS463 {
                    cell?.lbCellBank?.text = "RSSI: \(rssi) | Port: \(portNumber + 1)"
                } else {
                    cell?.lbCellBank?.text = "RSSI: \(rssi)"
                }
            }
        } else if (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] is CSLReaderBarcode) {
            let bc = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLReaderBarcode)?.barcodeValue

            cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as? CSLTagListCell
            if cell == nil {
                tableView.register(UINib(nibName: "CSLTagListCell", bundle: nil), forCellReuseIdentifier: "TagCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as? CSLTagListCell
            }

            cell?.lbCellEPC?.text = "\(indexPath.row + 1) \u{25CF} \(bc ?? "")"
            if let object = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLReaderBarcode)?.codeId {
                cell?.lbCellBank?.text = "[\(object)]"
            }
        } else {
            cell=nil
        }

        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] is CSLBleTag) {
            CSLRfidAppEngine.shared().tagSelected = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag)?.epc
        } else if (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] is CSLReaderBarcode) {
            CSLRfidAppEngine.shared().tagSelected = (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLReaderBarcode)?.barcodeValue
        } else {
            CSLRfidAppEngine.shared().tagSelected = ""
        }


        let alert = UIAlertController(title: "Tag Selected", message: CSLRfidAppEngine.shared().tagSelected, preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    func bankEnum(toString bank: MEMORYBANK) -> String? {
        var result: String? = nil

        switch bank {
        case MEMORYBANK.RESERVED:
                result = "RESERVED"
        case MEMORYBANK.EPC:
                result = "EPC"
        case MEMORYBANK.TID:
                result = "TID"
        case MEMORYBANK.USER:
                result = "USER"
            default:
                result = ""
        }

        return result
    }
}

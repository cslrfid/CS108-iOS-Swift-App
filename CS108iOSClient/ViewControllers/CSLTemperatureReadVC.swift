//
//  CSLTemperatureReadVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 28/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

import AudioToolbox

func UIColorFromRGB(_ rgbValue: UInt32) -> UIColor {
    UIColor(red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(rgbValue & 0xff)) / 255.0), alpha: 1.0)
}

func temp(_ CODE: Int, _ add_12: Int, _ add_13: Int, _ add_14: Int, _ add_15: Int) -> Double {
    let Temperature1 = add_15 & 0x07ff
    let TemperatureCode1 = add_14 & 0xffff
    let Temperature2 = add_13 & 0x07ff
    let TemperatureCode2 = add_12 & 0xffff

    let CalTemp1 = 0.1 * Double(Temperature1) - 60
    let CalTemp2 = 0.1 * Double(Temperature2) - 60
    let CalCode1 = 0.0625 * Double(TemperatureCode1)
    let CalCode2 = 0.0625 * Double(TemperatureCode2)

    let slope = (CalTemp2 - CalTemp1) / (CalCode2 - CalCode1)
    let TEMP = slope * (Double(CODE) - CalCode1) + CalTemp1

    return TEMP
}

@objcMembers class CSLTemperatureReadVC: UIViewController, CSLBleReaderDelegate, CSLBleInterfaceDelegate, UITableViewDataSource, UITableViewDelegate, MQTTSessionDelegate {
    
    @IBOutlet weak var btnInventory: UIButton!
    @IBOutlet weak var btnSelectAllTag: UIButton!
    @IBOutlet weak var btnRemoveAllTag: UIButton!
    @IBOutlet weak var lbBatteryLevel: UILabel!
    @IBOutlet weak var tblTagList: UITableView!
    @IBOutlet weak var lbTagCount: UILabel!
    @IBOutlet weak var lbInventory: UILabel!
    
    private var scrRefreshTimer: Timer?
    private var scrBeepTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (tabBarController as? CSLTemperatureTabVC)?.setAntennaPortsAndPowerForTemperatureTags()
        (tabBarController as? CSLTemperatureTabVC)?.setConfigurationsForTemperatureTags()


        //initialize averaging buffer
        CSLRfidAppEngine.shared().temperatureSettings.temperatureAveragingBuffer.removeAllObjects()
        CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer.removeAllObjects()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.title = "Read Sensors"

        if (tblTagList.dataSource == nil) && (tblTagList.delegate == nil) {
            //clear UI
            //self.lbTagCount.text=@"0";
            //[[CSLRfidAppEngine sharedAppEngine].reader.filteredBuffer removeAllObjects];

            tblTagList.dataSource = self
            tblTagList.delegate = self
            tblTagList.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tblTagList.bounds.size.width, height: 0.01))
            tblTagList.reloadData()

            CSLRfidAppEngine.shared().reader.delegate = self
            CSLRfidAppEngine.shared().reader.readerDelegate = self
        } else {
            //refresh table
            tblTagList.reloadData()
        }

        //timer event on updating UI
        scrRefreshTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(refreshTagListing), userInfo: nil, repeats: true)
        if let scrRefreshTimer = scrRefreshTimer {
            RunLoop.main.add(scrRefreshTimer, forMode: .common)
        }

        scrBeepTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playBeepDuringInventory), userInfo: nil, repeats: true)
        if let scrBeepTimer = scrBeepTimer {
            RunLoop.main.add(scrBeepTimer, forMode: .common)
        }

        tblTagList.setEditing(true, animated: true)
        tblTagList.backgroundView = nil
        tblTagList.backgroundColor = UIColor.white


    }

    override func viewDidAppear(_ animated: Bool) {
    }

    /*
    #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    //Selector for timer event on updating UI
    @objc func refreshTagListing() {
        autoreleasepool {
            if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.TAG_OPERATIONS {
                //[[CSLRfidAppEngine sharedAppEngine] soundAlert:1005];
                //update table
                tblTagList.reloadData()

                //update inventory count
                lbTagCount.text = String(format: "%ld", tblTagList.numberOfRows(inSection: 0))
            } else if CSLRfidAppEngine.shared().isBarcodeMode {
                //update table
                tblTagList.reloadData()
            }


            if CSLRfidAppEngine.shared().readerInfo.batteryPercentage < 0 || CSLRfidAppEngine.shared().readerInfo.batteryPercentage > 100 {
                lbBatteryLevel.text = "-"
            } else {
                lbBatteryLevel.text = String(format: "%d%%", CSLRfidAppEngine.shared().readerInfo.batteryPercentage)
            }

        }
    }

    //Selector for timer event on please
    @objc func playBeepDuringInventory() {
        autoreleasepool {
            if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.TAG_OPERATIONS {
                CSLRfidAppEngine.shared().soundAlert(1005)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //stop inventory if it is still running
        if btnInventory.isEnabled {
            if (lbInventory.text == "Stop") {
                btnInventory.sendActions(for: .touchUpInside)
            }
        }

        scrRefreshTimer?.invalidate()
        scrRefreshTimer = nil
        scrBeepTimer?.invalidate()
        scrBeepTimer = nil

        CSLRfidAppEngine.shared().isBarcodeMode = false

    }

    @IBAction func btnInventoryPressed(_ sender: Any) {

        if CSLRfidAppEngine.shared().isBarcodeMode && (lbInventory.text == "Start") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnInventory.isEnabled = false

            CSLRfidAppEngine.shared().reader.startBarcodeReading()
            btnInventory.setImage(UIImage(named: "Stop-icon.png"), for: .normal)
            lbInventory.text = "Stop"
            btnInventory.isEnabled = true
        } else if CSLRfidAppEngine.shared().isBarcodeMode && (lbInventory.text == "Stop") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnInventory.isEnabled = false

            CSLRfidAppEngine.shared().reader.stopBarcodeReading()
            btnInventory.setImage(UIImage(named: "Start-icon.png"), for: .normal)
            lbInventory.text = "Start"
            btnInventory.isEnabled = true
        } else if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.CONNECTED && (lbInventory.text == "Start") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnInventory.isEnabled = false

            //start inventory
            CSLRfidAppEngine.shared().reader.startInventory()
            btnInventory.setImage(UIImage(named: "Stop-icon.png"), for: .normal)
            lbInventory.text = "Stop"
            btnInventory.isEnabled = true
            btnRemoveAllTag.isEnabled = false
            btnSelectAllTag.isEnabled = false
        } else if (lbInventory.text == "Stop") {
            CSLRfidAppEngine.shared().soundAlert(1033)
            if CSLRfidAppEngine.shared().reader.stopInventory() {
                btnInventory.setImage(UIImage(named: "Start-icon.png"), for: .normal)
                lbInventory.text = "Start"
                btnInventory.isEnabled = true

                let lockQueue = DispatchQueue(label: "CSLRfidAppEngine.shared().reader.filteredBuffer")
                lockQueue.sync {

                    let indexSet = NSMutableIndexSet()

                    //refresh tag list to the latest after stopping inventory
                    tblTagList.reloadData()
                    lbTagCount.text = String(format: "%ld", tblTagList.numberOfRows(inSection: 0))

                    //remove tags that are out of rssi range
                    for i in 0..<tblTagList.numberOfRows(inSection: 0) {
                        if (tblTagList.cellForRow(at: IndexPath(row: i, section: 0)) as? CSLTemperatureTagListCell)?.viTemperatureCell?.layer.opacity != 1.0 {
                            indexSet.add(IndexPath(row: i, section: 0).row)
                            CSLRfidAppEngine.shared().temperatureSettings.removeTemperatureAverage(forEpc: (CSLRfidAppEngine.shared().reader.filteredBuffer[i] as? CSLBleTag)!.epc)
                            CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer.removeObject(forKey: (CSLRfidAppEngine.shared().reader.filteredBuffer[i] as? CSLBleTag)!.epc as Any)
                        }
                    }

                    if indexSet.count > 0 {
                        //remove rows that are selected
                        for deletionIndex in indexSet.reversed() { CSLRfidAppEngine.shared().reader.filteredBuffer.remove(deletionIndex) }
                        //update inventory count
                        tblTagList.reloadData()
                        lbTagCount.text = String(format: "%ld", tblTagList.numberOfRows(inSection: 0))
                    }

                }
                btnRemoveAllTag.isEnabled = true
                btnSelectAllTag.isEnabled = true
            } else {
                btnInventory.setImage(UIImage(named: "Stop-icon.png"), for: .normal)
                lbInventory.text = "Stop"
                btnInventory.isEnabled = true
            }
        }


    }

    @IBAction func btnSelectAllTagPressed(_ sender: Any) {
        let totalRows = tblTagList.numberOfRows(inSection: 0)

        //check if all rows are selected
        if tblTagList.indexPathsForSelectedRows?.count == totalRows {
            for row in 0..<totalRows {
                tblTagList.deselectRow(at: IndexPath(row: row, section: 0), animated: false)
                btnSelectAllTag.setImage(UIImage(named: "Check-icon.png"), for: .normal)
            }
        } else {
            for row in 0..<totalRows {
                tblTagList.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            }
            btnSelectAllTag.setImage(UIImage(named: "Clear-icon.png"), for: .normal)
        }
    }

    @IBAction func btnRemoveAllTagPressed(_ sender: Any) {

        let indexPathForSelectedRows = tblTagList.indexPathsForSelectedRows
        let indexSet = NSMutableIndexSet()

        for i in 0..<(indexPathForSelectedRows?.count ?? 0) {
            indexSet.add(indexPathForSelectedRows?[i].row ?? 0)
            CSLRfidAppEngine.shared().temperatureSettings.removeTemperatureAverage(forEpc: (CSLRfidAppEngine.shared().reader.filteredBuffer[(indexPathForSelectedRows?[i].row)!] as? CSLBleTag)?.epc ?? "")
            CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer.removeObject(forKey: (CSLRfidAppEngine.shared().reader.filteredBuffer[(indexPathForSelectedRows?[i].row)!] as? CSLBleTag)?.epc ?? "")
        }
        if indexSet.count > 0 {
            //remove rows that are selected
            for deletionIndex in indexSet.reversed() { CSLRfidAppEngine.shared().reader.filteredBuffer.remove(deletionIndex) }
            //update inventory count
            tblTagList.reloadData()
            lbTagCount.text = String(format: "%ld", tblTagList.numberOfRows(inSection: 0))
            btnSelectAllTag.setImage(UIImage(named: "Check-icon.png"), for: .normal)
        }
    }

    @IBAction func uivInventoryPressed(_ sender: Any) {
        btnInventory.sendActions(for: .touchUpInside)

    }

    @IBAction func uivRemoveAllTagPressed(_ sender: Any) {
        btnRemoveAllTag.sendActions(for: .touchUpInside)
    }

    @IBAction func uivSelectAllTagPressed(_ sender: Any) {
        btnSelectAllTag.sendActions(for: .touchUpInside)
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
                    if (self.lbInventory.text == "Start") {
                        self.btnInventory.sendActions(for: .touchUpInside)
                    }
                } else {
                    if (self.lbInventory.text == "Stop") {
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

    @objc func button(forDetailsClicked sender: UIButton?) {
        //ignore details button click if inventory is running
        if (lbInventory.text == "Start") && btnInventory.isEnabled {
            scrRefreshTimer?.invalidate()
            scrRefreshTimer = nil
            scrBeepTimer?.invalidate()
            scrBeepTimer = nil
            CSLRfidAppEngine.shared().reader.delegate = nil
            CSLRfidAppEngine.shared().reader.readerDelegate = nil

            CSLRfidAppEngine.shared().tagSelected = (CSLRfidAppEngine.shared().reader.filteredBuffer[sender!.tag] as? CSLBleTag)?.epc
            CSLRfidAppEngine.shared().cslBleTagSelected = CSLRfidAppEngine.shared().reader.filteredBuffer[sender!.tag] as? CSLBleTag
            let tb = tabBarController as? CSLTemperatureTabVC
            let object = tb?.viewControllers?[CSLTemperatureTabVC.CSL_VC_TEMPTAB_DETAILS_VC_IDX]
            _ = tb?.tabBarController(tb!, shouldSelect: object!)
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: CSLTemperatureTagListCell?

        let lockQueue = DispatchQueue(label: "CSLRfidAppEngine.shared().reader.filteredBuffer")
        lockQueue.sync {
            if (CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] is CSLBleTag) {

                var ocrssi: UInt32 = 0
                var scanner: Scanner?
                var temperatureValue = 0.0
                var rssi: Int
                var portNumber: Int

                let currentBleTag = CSLRfidAppEngine.shared().reader.filteredBuffer[indexPath.row] as? CSLBleTag
                let epc = currentBleTag?.epc
                let data1 = currentBleTag?.data1
                let data2 = currentBleTag?.data2
                portNumber = Int(currentBleTag?.portNumber ?? 0)
                rssi = Int(currentBleTag?.rssi ?? 0)

                cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureTagCell") as? CSLTemperatureTagListCell
                if cell == nil {
                    tableView.register(UINib(nibName: "CSLTemperatureTagListCell", bundle: nil), forCellReuseIdentifier: "TemperatureTagCell")
                    cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureTagCell") as? CSLTemperatureTagListCell
                }

                if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                    if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.XERXES {
                        var result: UInt = 0
                        var _: Scanner?
                        var tempCode: Int
                        var tempCode2: Int
                        var temp2: Int
                        var tempCode1: Int
                        var temp1: Int
                        
                        var str = (data2 as NSString?)?.substring(with: NSRange(location: 16, length: 4)) ?? ""
                        result = UInt(str, radix: 16)!
                        result &= 0xfff
                        tempCode = Int(result)

                        str = (data1 as NSString?)?.substring(with: NSRange(location: 0, length: 4)) ?? ""
                        result = UInt(str, radix: 16)!
                        result &= 0xffff
                        tempCode2 = Int(result)
                        
                        str = (data1 as NSString?)?.substring(with: NSRange(location: 4, length: 4)) ?? ""
                        result = UInt(str, radix: 16)!
                        result &= 0x7ff
                        temp2 = Int(result)
                        
                        str = (data1 as NSString?)?.substring(with: NSRange(location: 8, length: 4)) ?? ""
                        result = UInt(str, radix: 16)!
                        result &= 0xffff
                        tempCode1 = Int(result)
                                                
                        str = (data1 as NSString?)?.substring(with: NSRange(location: 12, length: 4)) ?? ""
                        result = UInt(str, radix: 16)!
                        result &= 0x7ff
                        temp1 = Int(result)

                        temperatureValue = CSLTemperatureTagListCell.calculateCalibratedTemperatureValue(forXerxes: UInt16(tempCode), temperatureCode2: UInt16(tempCode2), temperature2: UInt16(temp2), temperatureCode1: UInt16(tempCode1), temperature1: UInt16(temp1))
                    } else {
                        temperatureValue = CSLTemperatureTagListCell.calculateCalibratedTemperatureValue(((data1 as NSString?)?.substring(with: NSRange(location: 8, length: 4)))!, calibration: data2!)
                    }
                } else {
                    var result: UInt = 0
                    let str = (data1 as NSString?)?.substring(with: NSRange(location: 0, length: 4)) ?? ""
                    result = UInt(str, radix: 16)!
                    if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                        result &= 0x1ff //only account for the 9 bits
                    } else {
                        result &= 0x1f //only account for the 5 bits
                    }
                    temperatureValue = Double(result)
                }

                //grey out tag from list if it is outside the on-chip rssi limits
                if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.XERXES {
                    scanner = Scanner(string: (data2 as NSString?)?.substring(with: NSRange(location: 12, length: 4)) ?? "")
                    scanner?.scanHexInt32(UnsafeMutablePointer<UInt32>(mutating: &ocrssi))
                    ocrssi &= 0x0000001f
                } else {
                    if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                        scanner = Scanner(string: (data1 as NSString?)?.substring(with: NSRange(location: 4, length: 4)) ?? "")
                    } else {
                        scanner = Scanner(string: (data2 as NSString?)?.substring(with: NSRange(location: 0, length: 4)) ?? "")
                    }
                    scanner?.scanHexInt32(UnsafeMutablePointer<UInt32>(mutating: &ocrssi))
                    ocrssi &= 0x0000001f
                }

                //for temperature measurements
                if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                    if ocrssi >= CSLRfidAppEngine.shared().temperatureSettings.rssiLowerLimit && ocrssi <= CSLRfidAppEngine.shared().temperatureSettings.rssiUpperLimit && currentBleTag != (CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[epc ?? ""] as? CSLBleTag) && (temperatureValue > MIN_TEMP_VALUE && temperatureValue < MAX_TEMP_VALUE) {
                        //filter out invalid packets that are out of temperature range on spec
                        CSLRfidAppEngine.shared().temperatureSettings.setTemperatureValueForAveraging(NSNumber(value: temperatureValue), epcid: epc!)
                        CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[epc ?? ""] = currentBleTag
                    }
                } else {
                    //moisture measurements
                    if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                        if ocrssi >= CSLRfidAppEngine.shared().temperatureSettings.rssiLowerLimit && ocrssi <= CSLRfidAppEngine.shared().temperatureSettings.rssiUpperLimit && currentBleTag != (CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[epc ?? ""] as? CSLBleTag) && (Int32(temperatureValue) > MIN_MOISTURE_VALUE && Int32(temperatureValue) < MAX_MOISTURE_VALUE) {
                            //filter out invalid packets that are out of moisture range on spec
                            CSLRfidAppEngine.shared().temperatureSettings.setTemperatureValueForAveraging(NSNumber(value: temperatureValue), epcid: epc!)
                            CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[epc ?? ""] = currentBleTag
                        }
                    } else {
                        if ocrssi >= CSLRfidAppEngine.shared().temperatureSettings.rssiLowerLimit && ocrssi <= CSLRfidAppEngine.shared().temperatureSettings.rssiUpperLimit && currentBleTag != (CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[epc ?? ""] as? CSLBleTag) && (Int32(temperatureValue) > MIN_MOISTURE_VALUE_S2 && Int32(temperatureValue) < MAX_MOISTURE_VALUE_S2) {
                            //filter out invalid packets that are out of moisture range on spec
                            CSLRfidAppEngine.shared().temperatureSettings.setTemperatureValueForAveraging(NSNumber(value: temperatureValue), epcid: epc!)
                            CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[epc ?? ""] = currentBleTag
                        }
                    }
                }


                let average = CSLRfidAppEngine.shared().temperatureSettings.getTemperatureValueAveraging(epc!)
                if (average == 0.00000000)
                {
                    cell?.viTemperatureCell!.layer.opacity = 1.0
                    if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                        if CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.CELCIUS {
                            cell?.lbTemperature!.text = String(format: "%3.1f\u{00BA}", average.doubleValue )
                        } else {
                            cell?.lbTemperature!.text = String(format: "%3.1f\u{00BA}", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: average.doubleValue ))
                        }
                    } else {
                        if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                            cell?.lbTemperature!.text = String(format: "%3.1f%%", ((490.00 - average.doubleValue ) / (490.00 - 5.00)) * 100.00)
                        } else {
                            cell?.lbTemperature!.text = String(format: "%3.1f%%", ((31 - average.doubleValue ) / (31)) * 100.00)
                        }
                    }
                }
                else
                {
                    cell?.viTemperatureCell.layer.opacity = 0.5
                    cell?.spinTemperatureValueIndicator()

                }
                

                //tag read timestamp
                let dateFormatter = DateFormatter()
                var date: Date?
                var stringFromDate: String?
                dateFormatter.dateFormat = "dd/MM/YY HH:mm:ss"
                if let EPC = currentBleTag?.epc {
                    if CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[EPC] != nil {
                        date = (CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[currentBleTag?.epc! as Any] as? CSLBleTag)?.timestamp
                        if let date = date {
                            stringFromDate = dateFormatter.string(from: date)
                        }
                    } else {
                        stringFromDate = ""
                    }
                }

                if CSLRfidAppEngine.shared().temperatureSettings.tagIdFormat == TAGIDFORMAT.ASCII {
                    cell?.lbEPC!.text = "\(asciiString(fromHexString: epc) ?? "")"
                } else {
                    cell?.lbEPC!.text = "\(epc ?? "")"
                }
                cell?.lbRssi!.text = String(format: "%3d", rssi > 100 ? 100 : rssi)
                cell?.lbDate!.text = stringFromDate
                if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS463 {
                    cell?.lbPortNumber!.text = String(format: "Port %2d", portNumber + 1)
                } else {
                    cell?.lbPortNumber!.text = ""
                }

                //temperature alert
                cell?.lbTagStatus!.layer.borderWidth = 1.0
                cell?.lbTagStatus!.layer.cornerRadius = 5.0
                cell?.lbTagStatus!.layer.borderColor = UIColor.clear.cgColor
                //if temperature is not valid, hide temperature alert.
                if (cell?.lbTemperature!.text == "  -  ") || (cell?.lbTemperature!.text == "  \\  ") || (cell?.lbTemperature!.text == "  |  ") || (cell?.lbTemperature!.text == "  /  ") {
                    cell?.lbTagStatus!.layer.opacity = 0.0
                } else {
                    cell?.lbTagStatus!.layer.opacity = 1.0
                }


                if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                    //for temperature measurements
                    if average.doubleValue < CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit {
                        cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x74b9ff)
                        cell?.lbTagStatus!.setTitle("Low", for: .normal)
                    } else if average.doubleValue > CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit {
                        cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0xd63031)
                        cell?.lbTagStatus!.setTitle("High", for: .normal)
                    } else {
                        cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x26a65b)
                        cell?.lbTagStatus!.setTitle("Normal", for: .normal)
                    }
                } else {
                    //for moisture mesurements
                    if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                        if CSLRfidAppEngine.shared().temperatureSettings.moistureAlertCondition == ALERTCONDITION.GREATER {
                            let avg = (((490.00 - average.doubleValue) / (490.00 - 5.00)) * 100.00)
                            if Int32(avg) > CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0xd63031)
                                cell?.lbTagStatus!.setTitle("High", for: .normal)
                            } else {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x26a65b)
                                cell?.lbTagStatus!.setTitle("Normal", for: .normal)
                            }
                        } else {
                            let avg=(((490.00 - average.doubleValue) / (490.00 - 5.00)) * 100.00)
                            if  Int32(avg) < CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x74b9ff)
                                cell?.lbTagStatus!.setTitle("Low", for: .normal)
                            } else {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x26a65b)
                                cell?.lbTagStatus!.setTitle("Normal", for: .normal)
                            }
                        }
                    } else {
                        //S2 chip with lower moisture resolution
                        if CSLRfidAppEngine.shared().temperatureSettings.moistureAlertCondition == ALERTCONDITION.GREATER {
                            if Int32((((31 - average.doubleValue) / (31)) * 100.00)) > CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0xd63031)
                                cell?.lbTagStatus!.setTitle("High", for: .normal)
                            } else {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x26a65b)
                                cell?.lbTagStatus!.setTitle("Normal", for: .normal)
                            }
                        } else {
                            if Int32(((31 - average.doubleValue) / (31)) * 100.00) < CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x74b9ff)
                                cell?.lbTagStatus!.setTitle("Low", for: .normal)
                            } else {
                                cell?.lbTagStatus!.backgroundColor = UIColorFromRGB(0x26a65b)
                                cell?.lbTagStatus!.setTitle("Normal", for: .normal)
                            }
                        }
                    }
                }
                

                cell?.accessory!.tag = indexPath.row
                cell?.accessory!.addTarget(self, action: #selector(button(forDetailsClicked:)), for: .touchUpInside)
                cell?.viewAccessory!.tag = indexPath.row
                (cell?.viewAccessory as? UIButton)?.addTarget(self, action: #selector(button(forDetailsClicked:)), for: .touchUpInside)
            }
        }
        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let totalRows = tblTagList.numberOfRows(inSection: 0)
        //check if all rows are selected
        if tblTagList.indexPathsForSelectedRows?.count == totalRows {
            btnSelectAllTag.setImage(UIImage(named: "Clear-icon.png"), for: .normal)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        let totalRows = tblTagList.numberOfRows(inSection: 0)
        //check if all rows are selected
        if tblTagList.indexPathsForSelectedRows?.count != totalRows {
            btnSelectAllTag.setImage(UIImage(named: "Check-icon.png"), for: .normal)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: 3)!
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
                NSException(name:NSExceptionName(rawValue: "Unexpected FormatType"), reason:"Generic Exception", userInfo:nil).raise()
        }

        return result
    }

    func asciiString(fromHexString hexString: String?) -> String? {

        // The hex codes should all be two characters.
        if ((hexString?.count ?? 0) % 2) != 0 {
            return nil
        }

        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = hexString! as NSString
        let matches = regex.matches(in: hexString ?? "", options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
        
    }
}

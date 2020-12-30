//
//  CSLTagSearchVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 18/12/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//


@objcMembers class CSLTagSearchVC: UIViewController, CSLBleInterfaceDelegate, CSLBleReaderDelegate, UITextFieldDelegate {
    private var rollingAvgRssi: CSLCircularQueue?
    private var tagLastFoundTime: Date?
    private var gaugeRefreshTimer: Timer?

    let ROLLING_AVG_COUNT = 10
    
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var txtEPC: UITextField!
    @IBOutlet weak var actSearchSpinner: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gaugeView.value = 0
        gaugeView.maxValue = 100
        gaugeView.minValue = 0
        gaugeView.numOfDivisions = 10
        gaugeView.numOfSubDivisions = 10
        gaugeView.unitOfMeasurement = "Signal"
        gaugeView.ringThickness = 30

        gaugeView.contentMode = .center
        //[self.gauageView addSubview:self.gaugeView];


        btnSearch.layer.borderWidth = 1.0
        btnSearch.layer.borderColor = UIColor.clear.cgColor
        btnSearch.layer.cornerRadius = 5.0

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.title = "Tag Search"

        actSearchSpinner.stopAnimating()
        view.isUserInteractionEnabled = true

        if !(CSLRfidAppEngine.shared().tagSelected == "") {
            txtEPC.text = CSLRfidAppEngine.shared().tagSelected
        }

        txtEPC.delegate = self

        CSLRfidAppEngine.shared().reader.delegate = self
        CSLRfidAppEngine.shared().reader.readerDelegate = self

        rollingAvgRssi = CSLCircularQueue(capacity: UInt(ROLLING_AVG_COUNT))

        // Do any additional setup after loading the view.
        (tabBarController as? CSLTabVC)?.setAntennaPortsAndPowerForTags()
        (tabBarController as? CSLTabVC)?.setConfigurationsForTags()
    }

    override func viewWillDisappear(_ animated: Bool) {

        //stop inventory if it is still running
        if btnSearch.isEnabled {
            if (btnSearch.currentTitle == "Stop") {
                btnSearch.sendActions(for: .touchUpInside)
            }
        }

        //remove delegate assignment so that trigger key will not triggered when out of this page
        CSLRfidAppEngine.shared().reader.delegate = nil
        CSLRfidAppEngine.shared().reader.readerDelegate = nil

        gaugeRefreshTimer?.invalidate()
        gaugeRefreshTimer = nil

        CSLRfidAppEngine.shared().isBarcodeMode = false
    }

    //Selector for timer event on updating UI and sound effect
    @objc func refreshGauge() {
        autoreleasepool {
            if gaugeView.ringBackgroundColor == UIColor.red {
                CSLRfidAppEngine.shared().soundAlert(1052)
            } else {
                CSLRfidAppEngine.shared().soundAlert(1005)
            }

            if let tagLastFoundTime = tagLastFoundTime {
                if Date().timeIntervalSince(tagLastFoundTime) > 1.0 {
                    //no tag found in the last 1 second.  Reset gauge
                    rollingAvgRssi?.removeAllObjects()
                    gaugeView.value = 0
                }
            }
        }
    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {
    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {

        DispatchQueue.main.async(execute: {
            if tag?.rssi == 0 {
                self.rollingAvgRssi?.removeAllObjects()
            } else if self.rollingAvgRssi?.count ?? 0 >= UInt(self.ROLLING_AVG_COUNT) {
                self.rollingAvgRssi?.deqObject()
                self.rollingAvgRssi?.enqObject(tag)
            } else {
                self.rollingAvgRssi?.enqObject(tag)
            }

            let val=self.rollingAvgRssi!.calculateRollingAverage()
            self.gaugeView.value = Double(CGFloat(val))
            if self.gaugeView.value > Double(CGFloat(self.gaugeView.maxValue * 0.8)) {
                self.gaugeView.ringBackgroundColor = UIColor.red
            } else {
                self.gaugeView.ringBackgroundColor = UIColor(red: 76.0 / 255, green: 217.0 / 255, blue: 100.0 / 255, alpha: 1)
            }

            print("Tag Search with average RRSI = \(self.gaugeView.value)")
            self.tagLastFoundTime = Date()
        })
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = battPct
    }

    func didTriggerKeyChangedState(_ sender: CSLBleReader?, keyState state: Bool) {
        DispatchQueue.main.async(execute: {
            if self.btnSearch.isEnabled {
                if state {
                    if (self.btnSearch.currentTitle == "Start") {
                        self.btnSearch.sendActions(for: .touchUpInside)
                    }
                } else {
                    if (self.btnSearch.currentTitle == "Stop") {
                        self.btnSearch.sendActions(for: .touchUpInside)
                    }
                }
            }
        })
    }

    func didReceiveBarcodeData(_ sender: CSLBleReader?, scannedBarcode barcode: CSLReaderBarcode?) {
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    @IBAction func btnSearchPressed(_ sender: Any) {

        if (txtEPC.text == "") {
            let alert = UIAlertController(title: "Tag Search", message: "No EPC Selected", preferredStyle: .alert)

            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
            return
        }

        var result = true
        rollingAvgRssi = CSLCircularQueue(capacity: UInt(ROLLING_AVG_COUNT))

        if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.CONNECTED && (btnSearch.currentTitle == "Start") {

            //timer event on updating UI
            gaugeRefreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshGauge), userInfo: nil, repeats: true)


            gaugeView.value = 0
            tagLastFoundTime = nil
            CSLRfidAppEngine.shared().soundAlert(1033)
            btnSearch.isEnabled = false
            //reader configurations before search

            //start tag search
            CSLRfidAppEngine.shared().reader.setPowerMode(false)
            result = CSLRfidAppEngine.shared().reader.startTagSearch(MEMORYBANK.EPC, maskPointer: 32, maskLength: (UInt32(txtEPC.text!.count) * 4), maskData: CSLBleReader.convertHexString(toData: txtEPC.text!))


            if result {
                btnSearch.setTitle("Stop", for: .normal)
                btnSearch.isEnabled = true
            }
        } else if (btnSearch.currentTitle == "Stop") {
            gaugeRefreshTimer?.invalidate()
            gaugeRefreshTimer = nil

            CSLRfidAppEngine.shared().soundAlert(1033)
            if CSLRfidAppEngine.shared().reader.stopTagSearch() {
                btnSearch.setTitle("Start", for: .normal)
                btnSearch.isEnabled = true
                CSLRfidAppEngine.shared().reader.setPowerMode(true)
            } else {
                btnSearch.setTitle("Stop", for: .normal)
                btnSearch.isEnabled = true
            }
        }


    }
}

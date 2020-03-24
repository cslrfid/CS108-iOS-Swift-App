//
//  CSLTemperatureUploadVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 16/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLTemperatureUploadVC: UIViewController, MQTTSessionDelegate, UITextFieldDelegate {
    
    private var scrMQTTStatusRefresh: Timer?

    @IBOutlet weak var imgMQTTStatus: UIImageView!
    @IBOutlet weak var btnMQTTStatus: UIButton!
    @IBOutlet weak var lbMQTTMessage: UILabel!
    @IBOutlet weak var txtMQTTPublishTopic: UITextField!
    @IBOutlet weak var btnMQTTUpload: UIButton!
    @IBOutlet weak var actMQTTConnectIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnSaveToFile: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        txtMQTTPublishTopic.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController!.title = "Data Upload"

        btnMQTTStatus.layer.borderWidth = 1.0
        btnMQTTStatus.layer.borderColor = UIColor.clear.cgColor
        btnMQTTStatus.layer.cornerRadius = 5.0
        btnMQTTUpload.layer.borderWidth = 1.0
        btnMQTTUpload.layer.borderColor = UIColor.clear.cgColor
        btnMQTTUpload.layer.cornerRadius = 5.0

        //clear UI
        imgMQTTStatus.image = nil
        btnMQTTStatus.isHidden = true
        btnMQTTUpload.isEnabled = false
        lbMQTTMessage.text = "Number of Records: \(Int(CSLRfidAppEngine.shared().reader.filteredBuffer.count))"

        if CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled {
            if CSLRfidAppEngine.shared().mqttSettings.mqttStatus != .connected {
                CSLRfidAppEngine.shared().mqttSettings.mqttStatus = .notConnected

                actMQTTConnectIndicator.startAnimating()
                CSLRfidAppEngine.shared().mqttSettings.connect(toMQTTBroker: txtMQTTPublishTopic.text!)

                for _ in 0..<COMMAND_TIMEOUT_5S {
                    //wait for 5s for connection
                    if CSLRfidAppEngine.shared().mqttSettings.mqttStatus == .connected || CSLRfidAppEngine.shared().mqttSettings.mqttStatus == .error {
                        break
                    }
                    Thread.sleep(forTimeInterval: 0.1)
                }
                actMQTTConnectIndicator.stopAnimating()
                if CSLRfidAppEngine.shared().mqttSettings.mqttStatus == .connected {
                    imgMQTTStatus.image = UIImage(named: "cloud-connected")
                    btnMQTTStatus.isHidden = false
                    btnMQTTStatus.setTitle("CONNECTED", for: .normal)
                    btnMQTTStatus.backgroundColor = UIColorFromRGB(0x26a65b) //green
                } else {
                    imgMQTTStatus.image = UIImage(named: "cloud-offline")
                    btnMQTTStatus.isHidden = false
                    btnMQTTStatus.setTitle("DISCONNECTED", for: .normal)
                    btnMQTTStatus.backgroundColor = UIColorFromRGB(0xd63031) //red
                }
            } else {
                imgMQTTStatus.image = UIImage(named: "cloud-connected")
                btnMQTTStatus.isHidden = false
                btnMQTTStatus.setTitle("CONNECTED", for: .normal)
                btnMQTTStatus.backgroundColor = UIColorFromRGB(0x26a65b) //green
            }
        } else {
            imgMQTTStatus.image = UIImage(named: "cloud-offline")
            btnMQTTStatus.isHidden = false
            btnMQTTStatus.setTitle("OFFLINE", for: .normal)
            btnMQTTStatus.backgroundColor = UIColorFromRGB(0xa3a3a3) //grey
        }

        if CSLRfidAppEngine.shared().mqttSettings.mqttStatus == .connected && CSLRfidAppEngine.shared().reader.filteredBuffer.count > 0 {
            btnMQTTUpload.isEnabled = true
        }

        if CSLRfidAppEngine.shared().reader.filteredBuffer.count > 0 {
            btnSaveToFile.isEnabled = true
        } else {
            btnSaveToFile.isEnabled = false
        }

        //timer event on updating MQTT status UI
        scrMQTTStatusRefresh = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshMQTTStatus), userInfo: nil, repeats: true)
        if let scrMQTTStatusRefresh = scrMQTTStatusRefresh {
            RunLoop.main.add(scrMQTTStatusRefresh, forMode: .common)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        scrMQTTStatusRefresh?.invalidate()
        scrMQTTStatusRefresh = nil
    }

    @objc func refreshMQTTStatus() {
        if !CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled {
            imgMQTTStatus.image = UIImage(named: "cloud-offline")
            btnMQTTStatus.isHidden = false
            btnMQTTStatus.setTitle("OFFLINE", for: .normal)
            btnMQTTStatus.backgroundColor = UIColorFromRGB(0xa3a3a3) //grey
            btnMQTTUpload.isEnabled = false
        } else {
            if CSLRfidAppEngine.shared().mqttSettings.mqttStatus == .connected {
                imgMQTTStatus.image = UIImage(named: "cloud-connected")
                btnMQTTStatus.isHidden = false
                btnMQTTStatus.setTitle("CONNECTED", for: .normal)
                btnMQTTStatus.backgroundColor = UIColorFromRGB(0x26a65b) //green
                if CSLRfidAppEngine.shared().reader.filteredBuffer?.count != 0 {
                    btnMQTTUpload.isEnabled = true
                }
            } else {
                imgMQTTStatus.image = UIImage(named: "cloud-offline")
                btnMQTTStatus.isHidden = false
                btnMQTTStatus.setTitle("DISCONNECTED", for: .normal)
                btnMQTTStatus.backgroundColor = UIColorFromRGB(0xd63031) //red
                btnMQTTUpload.isEnabled = false
                CSLRfidAppEngine.shared().mqttSettings.connect(toMQTTBroker: txtMQTTPublishTopic.text!) //reconnect
            }
        }
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = Int32(battPct)
    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {
    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didTriggerKeyChangedState(_ sender: CSLBleReader?, keyState state: Bool) {
    }

    func didReceiveBarcodeData(_ sender: CSLBleReader?, scannedBarcode barcode: CSLReaderBarcode?) {
        CSLRfidAppEngine.shared().soundAlert(1005)
    }

    @IBAction func btnMQTTUpload(_ sender: Any) {
        btnMQTTUpload.isEnabled = false

        if CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled && CSLRfidAppEngine.shared().mqttSettings.isMQTTEnabled == true {

            imgMQTTStatus.isHidden = true
            actMQTTConnectIndicator.startAnimating()
            CSLRfidAppEngine.shared().mqttSettings.publishTopicCounter = 0

            for tag in CSLRfidAppEngine.shared().reader.filteredBuffer {
                let lastGoodRead = CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[(tag as! CSLBleTag).epc!] as! CSLBleTag
                //tag read timestamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YY HH:mm:ss"
                let date = lastGoodRead.timestamp
                var stringFromDate: String? = nil
                if let date = date {
                    stringFromDate = dateFormatter.string(from: date)
                }
                
                let startSensorCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 0)
                let endSensorCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
                let rangeSensorCode = startSensorCode..<endSensorCode
                let startOcrssi = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
                let endOcrssi = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
                let rangeOcrssi = startOcrssi..<endOcrssi
                let startTempCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 8)
                let endTempCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
                let rangeTempCode = startTempCode..<endTempCode
                
                //build an info object and convert to json
                let info = [
                    "messageid" : UUID().uuidString,
                    "epc" : (tag as AnyObject).epc,
                    "temperature" : String(format: "%.1f", CSLRfidAppEngine.shared().temperatureSettings.getTemperatureValueAveraging((tag as AnyObject).epc).doubleValue),
                    "calibration" : lastGoodRead.data2,
                    "sensorcode" : String(lastGoodRead.data1[rangeSensorCode]),
                    "ocrssi" : String(lastGoodRead.data1[rangeOcrssi]),
                    "temperaturecode" : String(lastGoodRead.data1[rangeTempCode]),
                    "rssi" : "\((tag as! CSLBleTag).rssi)",
                    "timestamp" : stringFromDate ?? ""
                ]

                var _: Error?
                var jsonData: Data? = nil
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
                } catch _ {
                }
                let topic = txtMQTTPublishTopic.text!.replacingOccurrences(of: "{deviceId}", with: CSLRfidAppEngine.shared().mqttSettings.clientId)

                CSLRfidAppEngine.shared().mqttSettings.publishData(jsonData!, onTopic: topic)

            }

            for _ in 0..<COMMAND_TIMEOUT_10S {
                //wait for 5s for connection
                if CSLRfidAppEngine.shared().mqttSettings.publishTopicCounter == CSLRfidAppEngine.shared().reader.filteredBuffer.count {
                    break
                }
                Thread.sleep(forTimeInterval: 0.1)
            }

            let alert = UIAlertController(title: "Data Upload", message: "Uploaded \(CSLRfidAppEngine.shared().mqttSettings.publishTopicCounter)/\(Int(CSLRfidAppEngine.shared().reader.filteredBuffer.count)) Record(s).", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)

            imgMQTTStatus.isHidden = false
            actMQTTConnectIndicator.stopAnimating()
        }
        btnMQTTUpload.isEnabled = true
    }

    @IBAction func btnSave(toFilePressed sender: Any) {

        var fileContent = "TIMESTAMP,EPC,TEMPERATURE,CALIBRATION,SENSORCODE,ON-CHIP RSSI,TEMPERATURE CODE,RSSI\n"

        for tag in CSLRfidAppEngine.shared().reader.filteredBuffer {
            let lastGoodRead = CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[(tag as! CSLBleTag).epc!] as! CSLBleTag
            //tag read timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/YY HH:mm:ss"
            let date = lastGoodRead.timestamp
            var stringFromDate: String? = nil
            stringFromDate = dateFormatter.string(from: date!)

            let startSensorCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 0)
            let endSensorCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
            let rangeSensorCode = startSensorCode..<endSensorCode
            let startOcrssi = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
            let endOcrssi = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
            let rangeOcrssi = startOcrssi..<endOcrssi
            let startTempCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 8)
            let endTempCode = lastGoodRead.data1.index(lastGoodRead.data1.startIndex, offsetBy: 4)
            let rangeTempCode = startTempCode..<endTempCode
            
            let average = CSLRfidAppEngine.shared().temperatureSettings.getTemperatureValueAveraging((tag as AnyObject).epc)
            var averageText: String?
            if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                if CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.CELCIUS {
                    averageText = String(format: "%3.1f\u{00BA}", average.doubleValue )
                } else {
                    averageText = String(format: "%3.1f\u{00BA}", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: average.doubleValue ))
                }
                //build the text file content
                fileContent = fileContent + ("\(stringFromDate ?? ""),\((tag as! CSLBleTag).epc ?? ""),\(averageText ?? ""),\(lastGoodRead.data2 ?? ""),\(String(lastGoodRead.data1[rangeSensorCode])),\(String(lastGoodRead.data1[rangeOcrssi])),\(String(lastGoodRead.data1[rangeTempCode])),\("\((tag as! CSLBleTag).rssi)")\n")

            } else {
                if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                    //let avgValue = ((490.00 - average?.doubleValue ?? 0.0) / (490.00 - 5.00)) * 100.00
                    let avgValue = ((490.00 - average.doubleValue) / (490.00 - 5.00)) * 100
                    averageText = String(format: "%3.1f%%", avgValue)
                } else {
                    averageText = String(format: "%3.1f%%", ((31 - average.doubleValue ) / (31)) * 100.00)
                }
                //build the text file content
                fileContent = fileContent + ("\(String(describing: stringFromDate)),\(String(describing: (tag as! CSLBleTag).epc)),\(String(describing: averageText)),\(""),\(String(describing: lastGoodRead.data1)),\(String(describing: lastGoodRead.data2)),\(""),\("\((tag as! CSLBleTag).rssi)")\n")

            }
        }

        let objectsToShare = [fileContent]

        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        let excludeActivities: [AnyHashable]? = [
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo
        ]

        activityVC.excludedActivityTypes = excludeActivities as? [UIActivity.ActivityType]

        present(activityVC, animated: true)

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}

//
//  CSLTemperatureDetailsVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 4/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLTemperatureDetailsVC: UIViewController {
    
    @IBOutlet weak var lbEPC: UILabel!
    @IBOutlet weak var btnTagStatus: UIButton!
    @IBOutlet weak var lbTemperature: UILabel!
    @IBOutlet weak var lbTimestamp: UILabel!
    @IBOutlet weak var uivTemperatureDetails: UIView!
    @IBOutlet weak var lbCalibration: UILabel!
    @IBOutlet weak var lbSensorCode: UILabel!
    @IBOutlet weak var lbOCRSSI: UILabel!
    @IBOutlet weak var lbTemperatureCode: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBarController!.title = "Sensors Details"

        btnTagStatus.layer.borderWidth = 1.0
        btnTagStatus.layer.borderColor = UIColor.clear.cgColor
        btnTagStatus.layer.cornerRadius = 5.0

        uivTemperatureDetails.layer.borderWidth = 1.0
        uivTemperatureDetails.layer.borderColor = (UIColorFromRGB(0xaaaaaa)).cgColor
        uivTemperatureDetails.layer.cornerRadius = 5.0

        lbTemperature.text = ""
        lbEPC.text = ""
        lbTimestamp.text = ""

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController!.title = "Sensor Details"

        if CSLRfidAppEngine.shared().cslBleTagSelected != nil {

            // Do any additional setup after loading the view.
            var lastGoodRead: CSLBleTag? = nil
            if let shared = (CSLRfidAppEngine.shared().cslBleTagSelected)?.epc {
                lastGoodRead = CSLRfidAppEngine.shared().temperatureSettings.lastGoodReadBuffer[shared] as? CSLBleTag
            }
            let epc = String(lastGoodRead?.epc ?? "")
            let data1 = String(lastGoodRead?.data1 ?? "")
            let data2 = String(lastGoodRead?.data2 ?? "")

            //tag read timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/YY HH:mm:ss"
            let date = lastGoodRead?.timestamp
            var stringFromDate: String? = nil
            if let date = date {
                stringFromDate = dateFormatter.string(from: date)
            }

            let temperatureValue = CSLRfidAppEngine.shared().temperatureSettings.getTemperatureValueAveraging(epc).doubleValue
            if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                if temperatureValue > MIN_TEMP_VALUE && temperatureValue < MAX_TEMP_VALUE {
                    if CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.CELCIUS {
                        lbTemperature.text = String(format: "%3.1f\u{00BA}%@", temperatureValue, "C")
                    } else {
                        lbTemperature.text = String(format: "%3.1f\u{00BA}%@", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: temperatureValue), "F")
                    }
                } else {
                    lbTemperature.text = "  -  "
                }
            } else {
                if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                    lbTemperature.text = String(format: "%3.1f%%", ((490.00 - temperatureValue) / (490.00 - 5.00)) * 100.00)
                } else {
                    lbTemperature.text = String(format: "%3.1f%%", ((31 - temperatureValue) / (31)) * 100.00)
                }
            }

            lbEPC.text = epc
            lbTimestamp.text = stringFromDate

            //temperature alert
            if CSLRfidAppEngine.shared().temperatureSettings.isTemperatureAlertEnabled {
                if CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
                    //for temperature measurements
                    if temperatureValue < CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit {
                        btnTagStatus.backgroundColor = UIColorFromRGB(0x74b9ff)
                        btnTagStatus.setTitle("Low", for: .normal)
                    } else if temperatureValue > CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit {
                        btnTagStatus.backgroundColor = UIColorFromRGB(0xd63031)
                        btnTagStatus.setTitle("High", for: .normal)
                    } else {
                        btnTagStatus.backgroundColor = UIColorFromRGB(0x26a65b)
                        btnTagStatus.setTitle("Normal", for: .normal)
                    }
                } else {
                    //for moisture mesurements
                    if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                        if CSLRfidAppEngine.shared().temperatureSettings.moistureAlertCondition == ALERTCONDITION.GREATER {
                            let temp = (490.00 - temperatureValue) / (490.00 - 5.00);
                            if (temp * 100.00) > Double(CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue) {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0xd63031)
                                btnTagStatus.setTitle("High", for: .normal)
                            } else {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0x26a65b)
                                btnTagStatus.setTitle("Normal", for: .normal)
                            }
                        } else {
                            let temp = (490.00 - temperatureValue) / (490.00 - 5.00);
                            if ((temp) * 100.00) < Double(CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue) {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0x74b9ff)
                                btnTagStatus.setTitle("Low", for: .normal)
                            } else {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0x26a65b)
                                btnTagStatus.setTitle("Normal", for: .normal)
                            }
                        }
                    } else {
                        //S2 chip with lower moisture resolution
                        if CSLRfidAppEngine.shared().temperatureSettings.moistureAlertCondition == ALERTCONDITION.GREATER {
                            let temp = (31.0 - temperatureValue) / (31.0);
                            if (temp * 100.00) > Double(CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue) {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0xd63031)
                                btnTagStatus.setTitle("High", for: .normal)
                            } else {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0x26a65b)
                                btnTagStatus.setTitle("Normal", for: .normal)
                            }
                        } else {
                            let temp = (31.0 - temperatureValue) / (31.0);
                            if (temp * 100.00) < Double(CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue) {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0x74b9ff)
                                btnTagStatus.setTitle("Low", for: .normal)
                            } else {
                                btnTagStatus.backgroundColor = UIColorFromRGB(0x26a65b)
                                btnTagStatus.setTitle("Normal", for: .normal)
                            }
                        }
                    }
                }
            } else {
                btnTagStatus.backgroundColor = UIColorFromRGB(0x26a65b)
                btnTagStatus.setTitle("Normal", for: .normal)
            }

            if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.XERXES {
                if data1.count >= 16 {
                    //lbCalibration.text = (data1 as NSString?)?.substring(to: 15)
                    lbCalibration.text=String(data1[data1.startIndex..<data1.index(data1.startIndex, offsetBy: 16)])
                }
                if data2.count >= 20 {
                    //lbSensorCode.text = (data2 as NSString?)?.substring(with: NSRange(location: 8, length: 4))
                    //lbOCRSSI.text = (data2 as NSString?)?.substring(with: NSRange(location: 12, length: 4))
                    //lbTemperatureCode.text = (data2 as NSString?)?.substring(with: NSRange(location: 16, length: 4))
                    let range1 = data2.index(data2.startIndex, offsetBy: 8)..<data2.index(data2.startIndex, offsetBy: 12)
                    lbSensorCode.text = String(data2[range1])
                    let range2 = data2.index(data2.startIndex, offsetBy: 12)..<data2.index(data1.startIndex, offsetBy: 16)
                    lbOCRSSI.text = String(data2[range2])
                    let range3 = data2.index(data2.startIndex, offsetBy: 16)..<data2.index(data2.startIndex, offsetBy: 20)
                    lbTemperatureCode.text = String(data2[range3])
                }
            } else if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                if data2.count >= 16 {
                    //lbCalibration.text = (data2 as NSString?)?.substring(to: 15)
                    let range = data2.startIndex..<data2.index(data2.startIndex, offsetBy: 16)
                    lbCalibration.text = String(data2[range])
                }
                if data1.count >= 12 {
                    //lbSensorCode.text = (data1 as NSString?)?.substring(with: NSRange(location: 0, length: 4))
                    //lbOCRSSI.text = (data1 as NSString?)?.substring(with: NSRange(location: 4, length: 4))
                    //lbTemperatureCode.text = (data1 as NSString?)?.substring(with: NSRange(location: 8, length: 4))
                    let range1 = data1.startIndex..<data2.index(data1.startIndex, offsetBy: 4)
                    lbSensorCode.text = String(data1[range1])
                    let range2 = data1.index(data2.startIndex, offsetBy: 4)..<data1.index(data1.startIndex, offsetBy: 8)
                    lbOCRSSI.text = String(data2[range2])
                    let range3 = data1.index(data1.startIndex, offsetBy: 8)..<data1.index(data1.startIndex, offsetBy: 12)
                    lbTemperatureCode.text = String(data2[range3])
                    
                    
                }
            } else {
                if data1.count >= 4 && data2.count >= 4 {
                    lbCalibration.text = "-"
                    //lbSensorCode.text = (data1 as NSString?)?.substring(with: NSRange(location: 0, length: 4))
                    //lbOCRSSI.text = (data2 as NSString?)?.substring(with: NSRange(location: 0, length: 4))
                    lbTemperatureCode.text = "-"
                    let range1 = data1.startIndex..<data1.index(data1.startIndex, offsetBy: 4)
                    lbSensorCode.text = String(data1[range1])
                    let range2 = data2.startIndex..<data2.index(data2.startIndex, offsetBy: 4)
                    lbOCRSSI.text = String(data2[range2])
                }
            }
        } else {
            lbTemperature.text = "  -  "
            lbSensorCode.text = ""
            lbOCRSSI.text = ""
            lbTemperatureCode.text = ""
            lbCalibration.text = ""
            lbTimestamp.text = ""
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        CSLRfidAppEngine.shared().cslBleTagSelected = nil
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = battPct
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
    }

}

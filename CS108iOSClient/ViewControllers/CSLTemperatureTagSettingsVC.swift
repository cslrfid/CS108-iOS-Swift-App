//
//  CSLTemperatureTagSettingsVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 14/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

import Foundation
import UIKit
import CSL_CS108

@objcMembers class CSLTemperatureTagSettingsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var swEnableTemperatureAlert: UISwitch!
    @IBOutlet weak var txtLowTemperatureThreshold: UITextField!
    @IBOutlet weak var txtHighTemperatureThreshold: UITextField!
    @IBOutlet weak var txtOcrssiMin: UITextField!
    @IBOutlet weak var txtOcrssiMax: UITextField!
    @IBOutlet weak var txtNumberOfTemperatureAveraging: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var scTemperatureUnit: UISegmentedControl!
    @IBOutlet weak var btnSensorType: UIButton!
    @IBOutlet weak var btnMoistureCompare: UIButton!
    @IBOutlet weak var txtMoistureValue: UITextField!
    @IBOutlet weak var btnPowerLevel: UIButton!
    @IBOutlet weak var swDisplayTagInAscii: UISwitch!
    @IBOutlet weak var actSaveConfig: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        btnSave.layer.borderWidth = 1.0
        btnSave.layer.borderColor = UIColor.clear.cgColor
        btnSave.layer.cornerRadius = 5.0

        txtOcrssiMax.delegate = self
        txtOcrssiMin.delegate = self
        txtLowTemperatureThreshold.delegate = self
        txtHighTemperatureThreshold.delegate = self
        txtNumberOfTemperatureAveraging.delegate = self
        txtMoistureValue.delegate = self

        btnSensorType.layer.borderWidth = 1.0
        btnSensorType.layer.borderColor = UIColor.lightGray.cgColor
        btnSensorType.layer.cornerRadius = 5.0

        btnMoistureCompare.layer.borderWidth = 1.0
        btnMoistureCompare.layer.borderColor = UIColor.lightGray.cgColor
        btnMoistureCompare.layer.cornerRadius = 5.0

        btnPowerLevel.layer.borderWidth = 1.0
        btnPowerLevel.layer.borderColor = UIColor.lightGray.cgColor
        btnPowerLevel.layer.cornerRadius = 5.0
    }

    override func viewWillAppear(_ animated: Bool) {

        tabBarController!.title = "Settings"

        //reload previously stored settings
        CSLRfidAppEngine.shared().reloadSettingsFromUserDefaults()

        //refresh UI with stored values
        swEnableTemperatureAlert.isOn = CSLRfidAppEngine.shared().temperatureSettings.isTemperatureAlertEnabled
        if CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.CELCIUS {
            txtHighTemperatureThreshold.text = String(format: "%3.1f", CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit)
            txtLowTemperatureThreshold.text = String(format: "%3.1f", CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit)
        } else {
            txtHighTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit))
            txtLowTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit))
        }
        txtOcrssiMax.text = "\(CSLRfidAppEngine.shared().temperatureSettings.rssiUpperLimit)"
        txtOcrssiMin.text = "\(CSLRfidAppEngine.shared().temperatureSettings.rssiLowerLimit)"
        txtNumberOfTemperatureAveraging.text = "\(CSLRfidAppEngine.shared().temperatureSettings.numberOfRollingAvergage)"
        (CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.FAHRENHEIT) ? (scTemperatureUnit.selectedSegmentIndex = 1) : (scTemperatureUnit.selectedSegmentIndex = 0)

        if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.XERXES {
            btnSensorType.setTitle("Axzon Xerxes - Temperature", for: .normal)
        } else if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 && CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.TEMPERATURE {
            btnSensorType.setTitle("Axzon Magnus S3 - Temperature", for: .normal)
        } else if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 && CSLRfidAppEngine.shared().temperatureSettings.reading == SENSORREADING.MOISTURE {
            btnSensorType.setTitle("Axzon Magnus S3 - Moisture", for: .normal)
        } else {
            btnSensorType.setTitle("Axzon Magnus S2 - Moisture", for: .normal)
        }

        if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.LOWPOWER {
            btnPowerLevel.setTitle("Low (16dBm)", for: .normal)
        } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.HIGHPOWER {
            btnPowerLevel.setTitle("High (30dBm)", for: .normal)
        } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.MEDIUMPOWER {
            btnPowerLevel.setTitle("Medium (23dBm)", for: .normal)
        } else {
            btnPowerLevel.setTitle("Follow System Setting", for: .normal)
        }

        if CSLRfidAppEngine.shared().temperatureSettings.tagIdFormat == TAGIDFORMAT.HEX {
            swDisplayTagInAscii.isOn = false
        } else {
            swDisplayTagInAscii.isOn = true
        }

        if CSLRfidAppEngine.shared().temperatureSettings.moistureAlertCondition == ALERTCONDITION.GREATER {
            btnMoistureCompare.setTitle(">", for: .normal)
        } else {
            btnMoistureCompare.setTitle("<", for: .normal)
        }

        txtMoistureValue.text = "\(CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue)"

        scTemperatureUnit.addTarget(self, action: #selector(segmentChangeViewValueChanged(_:)), for: .valueChanged)
    }

    @IBAction func btnSavePressed(_ sender: Any) {
        //store the UI input to the settings object on appEng
        CSLRfidAppEngine.shared().temperatureSettings.isTemperatureAlertEnabled = swEnableTemperatureAlert.isOn
        if scTemperatureUnit.selectedSegmentIndex == (TEMPERATUREUNIT.CELCIUS.rawValue.boolValue ? 1 : 0) {
            CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit = Double(txtHighTemperatureThreshold.text!)!
            CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit = Double(txtLowTemperatureThreshold.text!)!
        } else {
            CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit = CSLTemperatureTagSettings.convertFahrenheit(toCelcius: Double(txtHighTemperatureThreshold.text!)!)
            CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit = CSLTemperatureTagSettings.convertFahrenheit(toCelcius: Double(txtLowTemperatureThreshold.text!)!)
        }
        CSLRfidAppEngine.shared().temperatureSettings.rssiUpperLimit = Int32(Int(txtOcrssiMax.text!)!)
        CSLRfidAppEngine.shared().temperatureSettings.rssiLowerLimit = Int32(txtOcrssiMin.text!)!
        CSLRfidAppEngine.shared().temperatureSettings.numberOfRollingAvergage = Int32(txtNumberOfTemperatureAveraging.text!)!
        CSLRfidAppEngine.shared().temperatureSettings.unit = TEMPERATUREUNIT(rawValue: 	ObjCBool(scTemperatureUnit.selectedSegmentIndex > 0))!
        if btnSensorType.currentTitle?.contains("Xerxes") ?? false {
            CSLRfidAppEngine.shared().temperatureSettings.sensorType = SENSORTYPE.XERXES
        } else {
            CSLRfidAppEngine.shared().temperatureSettings.sensorType = btnSensorType.currentTitle?.contains("S3") ?? false ? SENSORTYPE.MAGNUSS3 : SENSORTYPE.MAGNUSS2
        }
        CSLRfidAppEngine.shared().temperatureSettings.reading = btnSensorType.currentTitle?.contains("Temperature") ?? false ? SENSORREADING.TEMPERATURE : SENSORREADING.MOISTURE

        if (btnPowerLevel.currentTitle == "Low (16dBm)") {
            CSLRfidAppEngine.shared().temperatureSettings.powerLevel = POWERLEVEL.LOWPOWER
        } else if (btnPowerLevel.currentTitle == "High (30dBm)") {
            CSLRfidAppEngine.shared().temperatureSettings.powerLevel = POWERLEVEL.HIGHPOWER
        } else if (btnPowerLevel.currentTitle == "Medium (23dBm)") {
            CSLRfidAppEngine.shared().temperatureSettings.powerLevel = POWERLEVEL.MEDIUMPOWER
        } else {
            CSLRfidAppEngine.shared().temperatureSettings.powerLevel = POWERLEVEL.SYSTEMSETTING
        }

        CSLRfidAppEngine.shared().temperatureSettings.tagIdFormat = (swDisplayTagInAscii.isOn ? TAGIDFORMAT.ASCII : TAGIDFORMAT.HEX)
        CSLRfidAppEngine.shared().temperatureSettings.moistureAlertCondition = btnMoistureCompare.currentTitle?.contains(">") ?? false ? ALERTCONDITION.GREATER : ALERTCONDITION.LESSTHAN
        CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue = Int32(txtMoistureValue.text!)!
        CSLRfidAppEngine.shared().saveTemperatureTagSettingsToUserDefaults()

        //refresh configurations and clear previous readings on sensor read table view
        //(tabBarController as? CSLTemperatureTabVC)?.setConfigurationsForTemperatureTags()

        //initialize averaging buffer
        let sensorVC = tabBarController!.viewControllers![CSLTemperatureTabVC.CSL_VC_TEMPTAB_READTEMP_VC_IDX] as? CSLTemperatureReadVC
        sensorVC?.btnSelectAllTag.sendActions(for: .touchUpInside)
        sensorVC?.btnRemoveAllTag.sendActions(for: .touchUpInside)
        actSaveConfig.startAnimating()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
        sensorVC?.viewWillDisappear(true)
        sensorVC?.viewDidLoad()
        sensorVC?.viewWillAppear(true)
        actSaveConfig.stopAnimating()

        let alert = UIAlertController(title: "Settings", message: "Settings saved.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)

    }

    @IBAction func txtLowTemperatureThresholdChanged(_ sender: Any) {
        let val = Double(txtLowTemperatureThreshold.text!)
        var lowLimit: Double
        var highLimit: Double
        if scTemperatureUnit.selectedSegmentIndex == (TEMPERATUREUNIT.CELCIUS.rawValue.boolValue ? 1 : 0) {
            lowLimit = MIN_TEMP_VALUE
            highLimit = MAX_TEMP_VALUE
        } else {
            lowLimit = CSLTemperatureTagSettings.convertCelcius(toFahrenheit: MIN_TEMP_VALUE)
            highLimit = CSLTemperatureTagSettings.convertCelcius(toFahrenheit: MAX_TEMP_VALUE)
        }
        if val != nil {
            if Double(txtLowTemperatureThreshold.text!)! >= lowLimit && Double(txtLowTemperatureThreshold.text!)! <= highLimit {
                print("Low temperature threshold entered: OK")
                txtLowTemperatureThreshold.text = String(format: "%3.1f", val!)
                return
            }
        }
        
        //invalid input.  reset to stored configurations
        if CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.CELCIUS {
            txtLowTemperatureThreshold.text = String(format: "%3.1f", CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit)
        } else {
            txtLowTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertLowerLimit))
        }
        
    }

    @IBAction func txtHighTemperatureThresholdChanged(_ sender: Any) {
        let val = Double(txtHighTemperatureThreshold.text!)
        var lowLimit: Double
        var highLimit: Double
        if scTemperatureUnit.selectedSegmentIndex == (TEMPERATUREUNIT.CELCIUS.rawValue.boolValue ? 1 : 0) {
            lowLimit = MIN_TEMP_VALUE
            highLimit = MAX_TEMP_VALUE
        } else {
            lowLimit = CSLTemperatureTagSettings.convertCelcius(toFahrenheit: MIN_TEMP_VALUE)
            highLimit = CSLTemperatureTagSettings.convertCelcius(toFahrenheit: MAX_TEMP_VALUE)
        }
        if val != nil {
            if Double(txtHighTemperatureThreshold.text!)! >= lowLimit && Double(txtHighTemperatureThreshold.text!)! <= highLimit {
                print("High temperature threshold entered: OK")
                txtHighTemperatureThreshold.text = String(format: "%3.1f", val!)
                return
            }
            
        }
        //invalid input.  reset to stored configurations
        if CSLRfidAppEngine.shared().temperatureSettings.unit == TEMPERATUREUNIT.CELCIUS {
            txtHighTemperatureThreshold.text = String(format: "%3.1f", CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit)
        } else {
            txtHighTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: CSLRfidAppEngine.shared().temperatureSettings.temperatureAlertUpperLimit))
        }

    }

    @IBAction func txtOcrssiMinChanged(_ sender: Any) {
        let val = Int32(txtOcrssiMin.text!)
        if val != nil
        {
            if Int32(txtOcrssiMin.text!)! >= 0 && Int32(txtOcrssiMin.text!)! <= 31 {
                print("On-chip RSSI low value entered: OK")
                return
            }
        }
        txtOcrssiMin.text = "\(CSLRfidAppEngine.shared().temperatureSettings.rssiLowerLimit)"
        
    }

    @IBAction func txtOcrssiMaxChanged(_ sender: Any) {
        let val = Int32(txtOcrssiMax.text!)
        if val != nil
        {
            if Int32(txtOcrssiMax.text!)! >= 0 && Int32(txtOcrssiMax.text!)! <= 31 {
                print("On-chip RSSI high value entered: OK")
                return
            }
        }
        txtOcrssiMax.text = "\(CSLRfidAppEngine.shared().temperatureSettings.rssiUpperLimit)"
        
    }

    @IBAction func txtNumberOfTemperatureAveragingChanged(_ sender: Any) {
        let val = Int32(txtNumberOfTemperatureAveraging.text!)
        if val != nil {
            if Int32(txtNumberOfTemperatureAveraging.text!)! >= 0 && Int32(txtNumberOfTemperatureAveraging.text!)! <= 10 {
                print("Temperature averaging value entered: OK")
                return
            }
        }
        txtNumberOfTemperatureAveraging.text = "\(CSLRfidAppEngine.shared().temperatureSettings.numberOfRollingAvergage)"
        
    }

    @IBAction func btnSensorTypePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Sensor Type", message: "Please select", preferredStyle: .actionSheet)
        let s3Temp = UIAlertAction(title: "Axzon Magnus S3 - Temperature", style: .default, handler: { action in
                self.btnSensorType.setTitle("Axzon Magnus S3 - Temperature", for: .normal)
            }) // S3 - temperature
        let s3Moist = UIAlertAction(title: "Axzon Magnus S3 - Moisture", style: .default, handler: { action in
                self.btnSensorType.setTitle("Axzon Magnus S3 - Moisture", for: .normal)
            }) // S3 - Moisture
        let s2Moist = UIAlertAction(title: "Axzon Magnus S2 - Moisture", style: .default, handler: { action in
                self.btnSensorType.setTitle("Axzon Magnus S2 - Moisture", for: .normal)
            }) // Magnus - Moisture
        let xerxesTemp = UIAlertAction(title: "Axzon Xerxes - Temperature", style: .default, handler: { action in
                self.btnSensorType.setTitle("Axzon Xerxes - Temperature", for: .normal)
            }) // S2 - Moisture

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(s3Temp)
        alert.addAction(s3Moist)
        alert.addAction(s2Moist)
        alert.addAction(xerxesTemp)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @IBAction func btnMoistureComparePressed(_ sender: Any) {

        let alert = UIAlertController(title: "Moisture Alert", message: "Compare Condition", preferredStyle: .actionSheet)
        let greater = UIAlertAction(title: ">", style: .default, handler: { action in
                self.btnMoistureCompare.setTitle(">", for: .normal)
            }) // >
        let lessThan = UIAlertAction(title: "<", style: .default, handler: { action in
                self.btnMoistureCompare.setTitle("<", for: .normal)
            }) // <


        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(greater)
        alert.addAction(lessThan)
        alert.addAction(cancel)

        present(alert, animated: true)

    }

    @IBAction func btnMoistureValueChanged(_ sender: Any) {
        let val = Int32(txtMoistureValue.text!)
        if val != nil {
            if Int32(txtMoistureValue.text!)! >= 0 && Int32(txtMoistureValue.text!)! <= 100 {
                print("Moisture alert value entered: OK")
                return
            }
            txtMoistureValue.text = "\(CSLRfidAppEngine.shared().temperatureSettings.moistureAlertValue)"
        }
    }

    @IBAction func btnPowerLevelChanged(_ sender: Any) {
        let alert = UIAlertController(title: "Power Level", message: "Please select", preferredStyle: .actionSheet)
        let sysSetting = UIAlertAction(title: "Follow System Setting", style: .default, handler: { action in
                self.btnPowerLevel.setTitle("Follow System Setting", for: .normal)
            }) // Follow System Setting
        let low = UIAlertAction(title: "Low (16dBm)", style: .default, handler: { action in
                self.btnPowerLevel.setTitle("Low (16dBm)", for: .normal)
            }) // Low (16dBm)
        let medium = UIAlertAction(title: "Medium (23dBm)", style: .default, handler: { action in
                self.btnPowerLevel.setTitle("Medium (23dBm)", for: .normal)
            }) // Medium (23dBm)
        let high = UIAlertAction(title: "High (30dBm)", style: .default, handler: { action in
                self.btnPowerLevel.setTitle("High (30dBm)", for: .normal)
            }) // High (30dBm)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // cancel

        alert.addAction(sysSetting)
        alert.addAction(low)
        alert.addAction(medium)
        alert.addAction(high)
        alert.addAction(cancel)

        present(alert, animated: true)


    }

    func didInterfaceChangeConnectStatus(_ sender: CSLBleInterface?) {
    }

    func didReceiveTagResponsePacket(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didReceiveTagAccessData(_ sender: CSLBleReader?, tagReceived tag: CSLBleTag?) {
    }

    func didReceiveBatteryLevelIndicator(_ sender: CSLBleReader?, batteryPercentage battPct: Int32) {
        CSLRfidAppEngine.shared().readerInfo.batteryPercentage = battPct
    }

    func didTriggerKeyChangedState(_ sender: CSLBleReader?, keyState state: Bool) {
    }

    func didReceiveBarcodeData(_ sender: CSLBleReader?, scannedBarcode barcode: CSLReaderBarcode?) {
    }

    @IBAction func segmentChangeViewValueChanged(_ SControl: UISegmentedControl?) {
        let unit = (TEMPERATUREUNIT.CELCIUS.rawValue.boolValue ? 1 : 0)

        if scTemperatureUnit.selectedSegmentIndex == unit {
            txtLowTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertFahrenheit(toCelcius: Double(txtLowTemperatureThreshold.text!)!))
            txtHighTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertFahrenheit(toCelcius: Double(txtHighTemperatureThreshold.text!)!))
        } else {
            txtLowTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: Double(txtLowTemperatureThreshold.text!)!))
            txtHighTemperatureThreshold.text = String(format: "%3.1f", CSLTemperatureTagSettings.convertCelcius(toFahrenheit: Double(txtHighTemperatureThreshold.text!)!))
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}

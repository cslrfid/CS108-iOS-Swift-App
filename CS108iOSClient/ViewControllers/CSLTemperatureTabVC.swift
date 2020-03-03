//
//  CSLTemperatureTabVC.m
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 28/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLTemperatureTabVC: UITabBarController, UITabBarControllerDelegate {
    
    public static let CSL_VC_TEMPTAB_READTEMP_VC_IDX = 0
    public static let CSL_VC_TEMPTAB_DETAILS_VC_IDX = 1
    public static let CSL_VC_TEMPTAB_REGISTRATION_VC_IDX = 2
    public static let CSL_VC_TEMPTAB_SETTINGS_VC_IDX = 3
    public static let CSL_VC_TEMPTAB_UPLOAD_VC_IDX = 3

    var m_SelectedTabView: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {

        //clear all tag select
        CSLRfidAppEngine.shared().reader.clearAllTagSelect()

    }

    /*
     #pragma mark - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    func setActiveView(_ identifier: Int) {
        self.selectedViewController = viewControllers?[identifier]
        m_SelectedTabView = identifier
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.selectedViewController = viewControllers?[tabBarController.selectedIndex]
        m_SelectedTabView = tabBarController.selectedIndex

        CSLRfidAppEngine.shared().reader.delegate = viewControllers?[tabBarController.selectedIndex] as? CSLBleInterfaceDelegate
        CSLRfidAppEngine.shared().reader.readerDelegate = viewControllers?[tabBarController.selectedIndex] as? CSLBleReaderDelegate

    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let controllerIndex = viewControllers?.firstIndex(of: viewController) ?? NSNotFound

        if controllerIndex == tabBarController.selectedIndex {
            return false
        }

        // Get the views.
        let fromView = tabBarController.selectedViewController?.view
        let toView = tabBarController.viewControllers?[controllerIndex].view

        // Get the size of the view area.
        let viewSize = fromView?.frame
        let scrollRight = controllerIndex > tabBarController.selectedIndex

        // Add the to view to the tab bar view.
        if let toView = toView {
            fromView?.superview?.addSubview(toView)
        }

        // Position it off screen.
        let screenWidth = UIScreen.main.bounds.size.width
        toView?.frame = CGRect(x: scrollRight ? screenWidth : -screenWidth, y: viewSize?.origin.y ?? 0.0, width: screenWidth, height: viewSize?.size.height ?? 0.0)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {

            // Animate the views on and off the screen. This will appear to slide.
            fromView?.frame = CGRect(x: scrollRight ? -screenWidth : screenWidth, y: viewSize?.origin.y ?? 0.0, width: screenWidth, height: viewSize?.size.height ?? 0.0)
            toView?.frame = CGRect(x: 0, y: viewSize?.origin.y ?? 0.0, width: screenWidth, height: viewSize?.size.height ?? 0.0)
        }) { finished in
            if finished {

                // Remove the old view from the tabbar view.
                fromView?.removeFromSuperview()
                tabBarController.selectedIndex = controllerIndex
            }
        }

        return true
    }

    func setAntennaPortsAndPowerForTemperatureTags() {

        CSLRfidAppEngine.shared().reader.setAntennaCycle(UInt(COMMAND_ANTCYCLE_CONTINUOUS)) //0x0700
        if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.HIGHPOWER {
            CSLRfidAppEngine.shared().reader.setPower(30.0)
        } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.LOWPOWER {
            CSLRfidAppEngine.shared().reader.setPower(16.0)
        } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.MEDIUMPOWER {
            CSLRfidAppEngine.shared().reader.setPower(23.0)
        } else {
            CSLRfidAppEngine.shared().reader.setPower(Double(CSLRfidAppEngine.shared().settings.power / 10))
        }


        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
            if CSLRfidAppEngine.shared().temperatureSettings.powerLevel != POWERLEVEL.SYSTEMSETTING {
                //use pre-defined three level settings
                CSLRfidAppEngine.shared().reader.selectAntennaPort(0)
                CSLRfidAppEngine.shared().reader.setAntennaConfig(true, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.HIGHPOWER {
                    CSLRfidAppEngine.shared().reader.setPower(30.0)
                } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.LOWPOWER {
                    CSLRfidAppEngine.shared().reader.setPower(16.0)
                } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.MEDIUMPOWER {
                    CSLRfidAppEngine.shared().reader.setPower(23.0)
                }
                CSLRfidAppEngine.shared().reader.setAntennaDwell(2000)
                CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(0)
                //disable all other channels
                for i in 1..<16 {
                    CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                    CSLRfidAppEngine.shared().reader.setAntennaConfig(false, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                }
            } else {
                if CSLRfidAppEngine.shared().settings.numberOfPowerLevel == 0 {
                    //use global settings
                    CSLRfidAppEngine.shared().reader.selectAntennaPort(0)
                    CSLRfidAppEngine.shared().reader.setAntennaConfig(true, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                    CSLRfidAppEngine.shared().reader.setPower(Double(CSLRfidAppEngine.shared().settings.power / 10))
                    CSLRfidAppEngine.shared().reader.setAntennaDwell(2000)
                    CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(0)
                    //disable all other ports
                    for i in 1..<16 {
                        CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                        CSLRfidAppEngine.shared().reader.setAntennaConfig(false, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                    }
                } else {
                    //iterate through all the power level
                    for i in 0..<16 {
                        let dwell = (CSLRfidAppEngine.shared().settings.dwellTime[i] as? NSNumber)?.intValue
                        CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                        print("Power level \(i): \((i >= CSLRfidAppEngine.shared().settings.numberOfPowerLevel) ? "OFF" : "ON")")
                        CSLRfidAppEngine.shared().reader.setAntennaConfig(((i >= CSLRfidAppEngine.shared().settings.numberOfPowerLevel) ? false : true), inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                        CSLRfidAppEngine.shared().reader.setPower(Double(((CSLRfidAppEngine.shared().settings.powerLevel[i] as? NSNumber)?.intValue ?? 300) / 10))
                        CSLRfidAppEngine.shared().reader.setAntennaDwell(UInt(dwell!))
                        CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(dwell == 0 ? 65535 : 0)
                    }
                }
            }
        } else {
            //CS463
            //iterate through all the power level
            for i in 0..<4 {
                let dwell = (CSLRfidAppEngine.shared().settings.dwellTime[i] as? NSNumber)?.intValue
                CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                print("Antenna \(i): \((CSLRfidAppEngine.shared().settings.isPortEnabled[i] as? NSNumber)?.boolValue ?? false ? "ON" : "OFF")")
                CSLRfidAppEngine.shared().reader.setAntennaConfig((CSLRfidAppEngine.shared().settings.isPortEnabled[i] as? NSNumber)?.boolValue ?? false, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.HIGHPOWER {
                    CSLRfidAppEngine.shared().reader.setPower(30.0)
                } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.LOWPOWER {
                    CSLRfidAppEngine.shared().reader.setPower(16.0)
                } else if CSLRfidAppEngine.shared().temperatureSettings.powerLevel == POWERLEVEL.MEDIUMPOWER {
                    CSLRfidAppEngine.shared().reader.setPower(23.0)
                } else {
                    CSLRfidAppEngine.shared().reader.setPower(Double(((CSLRfidAppEngine.shared().settings.powerLevel[i] as? NSNumber)?.intValue ?? 300) / 10))
                }
                CSLRfidAppEngine.shared().reader.setAntennaDwell(UInt(dwell!))
                CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(dwell == 0 ? 65535 : 0)
            }
        }
    }

    func setConfigurationsForTemperatureTags() {

        //pre-configure inventory
        //hardcode multibank inventory parameter for RFMicron tag reading (EPC+OCRSSI+TEMPERATURE)
        CSLRfidAppEngine.shared().settings.isMultibank1Enabled = true
        CSLRfidAppEngine.shared().settings.isMultibank2Enabled = true

        //check if Xerxes or Magnus tag
        if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.XERXES {
            CSLRfidAppEngine.shared().settings.multibank1 = MEMORYBANK.USER
            CSLRfidAppEngine.shared().settings.multibank1Offset = 0x12 //word address 0xC in the RESERVE bank
            CSLRfidAppEngine.shared().settings.multibank1Length = 0x04
            CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.RESERVED
            CSLRfidAppEngine.shared().settings.multibank2Offset = 0x0a
            CSLRfidAppEngine.shared().settings.multibank2Length = 0x05
        } else {
            //check and see if this is S2 or S3 chip for capturing sensor code
            CSLRfidAppEngine.shared().settings.multibank1 = MEMORYBANK.RESERVED
            if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                CSLRfidAppEngine.shared().settings.multibank1Offset = 12 //word address 0xC in the RESERVE bank
                CSLRfidAppEngine.shared().settings.multibank1Length = 3
            } else {
                CSLRfidAppEngine.shared().settings.multibank1Offset = 11 //word address 0xB in the RESERVE bank
                CSLRfidAppEngine.shared().settings.multibank1Length = 1
            }

            if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {
                CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.USER
                CSLRfidAppEngine.shared().settings.multibank2Offset = 8
                CSLRfidAppEngine.shared().settings.multibank2Length = 4
            } else {
                CSLRfidAppEngine.shared().settings.multibank2 = MEMORYBANK.RESERVED
                CSLRfidAppEngine.shared().settings.multibank2Offset = 13
                CSLRfidAppEngine.shared().settings.multibank2Length = 1
            }
        }
        //for multiplebank inventory
        var tagRead: UInt8 = 0
        if CSLRfidAppEngine.shared().settings.isMultibank1Enabled && CSLRfidAppEngine.shared().settings.isMultibank2Enabled {
            tagRead = 2
        } else if CSLRfidAppEngine.shared().settings.isMultibank1Enabled {
            tagRead = 1
        } else {
            tagRead = 0
        }

        CSLRfidAppEngine.shared().reader.selectAlgorithmParameter(QUERYALGORITHM.DYNAMICQ)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters0(UInt8(CSLRfidAppEngine.shared().settings.qValue), maximumQ: 15, minimumQ: 0, thresholdMultiplier: 4) //0x0903
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters1(5)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters2((CSLRfidAppEngine.shared().settings.target == TARGET.ToggleAB ? true : false), runTillZero: false) //x0905
        CSLRfidAppEngine.shared().reader.setInventoryConfigurations(QUERYALGORITHM.DYNAMICQ, matchRepeats: 0, tagSelect: 0, disableInventory: 0, tagRead: 0, crcErrorRead: 0, qtMode: 0, tagDelay: 0, inventoryMode: 0) //0x0901

        CSLRfidAppEngine.shared().reader.selectAlgorithmParameter(QUERYALGORITHM.FIXEDQ)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters0(UInt8(CSLRfidAppEngine.shared().settings.qValue), maximumQ: 0, minimumQ: 0, thresholdMultiplier: 0) //0x0903
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters1(5)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters2((CSLRfidAppEngine.shared().settings.target == TARGET.ToggleAB ? true : false), runTillZero: false) //x0905
        CSLRfidAppEngine.shared().reader.setInventoryConfigurations(QUERYALGORITHM.FIXEDQ, matchRepeats: 0, tagSelect: 0, disableInventory: 0, tagRead: 0, crcErrorRead: 0, qtMode: 0, tagDelay: 0, inventoryMode: 0) //0x0901

        CSLRfidAppEngine.shared().reader.setQueryConfigurations(TARGET.A, querySession: SESSION.S1, querySelect: QUERYSELECT.SL)
        CSLRfidAppEngine.shared().reader.setInventoryConfigurations(QUERYALGORITHM.DYNAMICQ, matchRepeats: 0, tagSelect: 0, disableInventory: 0, tagRead: 0, crcErrorRead: 0, qtMode: 0, tagDelay: 0, inventoryMode: 0) //0x0901
        CSLRfidAppEngine.shared().reader.setLinkProfile(LINKPROFILE.RANGE_DRM)

        //multiple bank select
        let emptyByte = [0x00]
        let OCRSSI = [0x20]

        //select the TID for either S2 or S3 chip
        CSLRfidAppEngine.shared().reader.clearAllTagSelect()

        if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.XERXES {

            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(0)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.TID, maskPointer: 0, maskLength: 32, maskData: CSLBleReader.convertHexString(toData: String(format: "%8X", SENSORTYPE.XERXES.rawValue)), sel_action: 0)
            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(1)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.USER, maskPointer: 0x03b0, maskLength: 8, maskData: Data(bytes: emptyByte, count: MemoryLayout.size(ofValue: emptyByte)), sel_action: 5, delayTime: 15)
        } else if CSLRfidAppEngine.shared().temperatureSettings.sensorType == SENSORTYPE.MAGNUSS3 {

            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(0)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.TID, maskPointer: 0, maskLength: 28, maskData: CSLBleReader.convertHexString(toData: String(format: "%8X", SENSORTYPE.MAGNUSS3.rawValue)), sel_action: 0)
            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(1)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.USER, maskPointer: 0xe0, maskLength: 0, maskData: Data(bytes: emptyByte, count: MemoryLayout.size(ofValue: emptyByte)), sel_action: 2)
            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(2)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.USER, maskPointer: 0xd0, maskLength: 8, maskData: Data(bytes: OCRSSI, count: MemoryLayout.size(ofValue: OCRSSI)), sel_action: 2)
        } else {
            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(0)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.TID, maskPointer: 0, maskLength: 28, maskData: CSLBleReader.convertHexString(toData: String(format: "%8X", SENSORTYPE.MAGNUSS2.rawValue)), sel_action: 0)
            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(1)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.USER, maskPointer: 0xa0, maskLength: 8, maskData: Data(bytes: OCRSSI, count: MemoryLayout.size(ofValue: OCRSSI)), sel_action: 2)
        }
        CSLRfidAppEngine.shared().reader.setInventoryCycleDelay(0)
        CSLRfidAppEngine.shared().reader.setInventoryConfigurations(CSLRfidAppEngine.shared().settings.algorithm, matchRepeats: 0, tagSelect: 0, disableInventory: 0, tagRead: tagRead, crcErrorRead: 1, qtMode: 0, tagDelay: (tagRead != 0 ? 30 : 0), inventoryMode: (tagRead != 0 ? 0 : 1))

        // if multibank read is enabled
        if tagRead != 0 {
            CSLRfidAppEngine.shared().reader.tagacc_BANK(CSLRfidAppEngine.shared().settings.multibank1, acc_bank2: CSLRfidAppEngine.shared().settings.multibank2)
            CSLRfidAppEngine.shared().reader.tagacc_PTR(UInt32((CSLRfidAppEngine.shared().settings.multibank2Offset << 16) + CSLRfidAppEngine.shared().settings.multibank1Offset))
            CSLRfidAppEngine.shared().reader.tagacc_CNT((tagRead != 0 ? CSLRfidAppEngine.shared().settings.multibank1Length : 0), secondBank: (Int(tagRead) == 2 ? CSLRfidAppEngine.shared().settings.multibank2Length : 0))
            CSLRfidAppEngine.shared().reader.tagacc_ACCPWD(0x00000000)
            CSLRfidAppEngine.shared().reader.setInventoryConfigurations(CSLRfidAppEngine.shared().settings.algorithm, matchRepeats: 0, tagSelect: 1, disableInventory: 0, tagRead: tagRead, crcErrorRead: 1, qtMode: 0, tagDelay: (tagRead != 0 ? 30 : 0), inventoryMode: (tagRead != 0 ? 0 : 1))
            CSLRfidAppEngine.shared().reader.setEpcMatchConfiguration(false, matchOn: false, matchLength: 0x00000, matchOffset: 0x00000)
        }

    }
}

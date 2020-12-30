//
//  CSLTabVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import UIKit

@objcMembers class CSLTabVC: UITabBarController, UITabBarControllerDelegate {
    
    public static let CSL_VC_RFIDTAB_INVENTORY_VC_IDX = 0
    public static let CSL_VC_RFIDTAB_SEARCH_VC_IDX = 1
    public static let CSL_VC_RFIDTAB_ACCESS_VC_IDX = 2
    
    var m_SelectedTabView: Int = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    func setActiveView(_ identifier: Int) {
        self.selectedViewController = viewControllers?[identifier]
        m_SelectedTabView = identifier
    }

    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.selectedViewController = viewControllers?[tabBarController.selectedIndex]
        m_SelectedTabView = tabBarController.selectedIndex

        CSLRfidAppEngine.shared().reader.delegate = viewControllers?[tabBarController.selectedIndex] as? CSLBleInterfaceDelegate
        CSLRfidAppEngine.shared().reader.readerDelegate = viewControllers?[tabBarController.selectedIndex] as? CSLBleReaderDelegate

    }

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let controllerIndex = viewControllers?.firstIndex(of: viewController) ?? NSNotFound
        if controllerIndex == tabBarController.selectedIndex {
            return false
        } else {
            (selectedViewController?.view.viewWithTag(99) as? UIActivityIndicatorView)?.startAnimating()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0))
            selectedViewController?.view.isUserInteractionEnabled = false
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

    func setAntennaPortsAndPowerForTags() {
        CSLRfidAppEngine.shared().reader.setAntennaCycle(UInt(COMMAND_ANTCYCLE_CONTINUOUS))
        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
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
                    var dwell = Int(CSLRfidAppEngine.shared().settings.dwellTime[i] as! String)
                    //enforcing dwell time != 0 when tag focus is enabled
                    if CSLRfidAppEngine.shared().settings.tagFocus != 0 {
                        dwell = 2000
                    }

                    let power = Int(CSLRfidAppEngine.shared().settings.powerLevel[i] as! String)
                    CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                    print("Power level \(i): \((i >= CSLRfidAppEngine.shared().settings.numberOfPowerLevel) ? "OFF" : "ON")")
                    CSLRfidAppEngine.shared().reader.setAntennaConfig(((i >= CSLRfidAppEngine.shared().settings.numberOfPowerLevel) ? false : true), inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                    CSLRfidAppEngine.shared().reader.setPower(Double(power! / 10))
                    CSLRfidAppEngine.shared().reader.setAntennaDwell(UInt(dwell!))
                    CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(dwell == 0 ? 65535 : 0)
                }
            }
        } else {
            //iterate through all the power level
            for i in 0..<4 {
                var dwell = Int(CSLRfidAppEngine.shared().settings.dwellTime[i] as! String)
                //enforcing dwell time != 0 when tag focus is enabled
                if CSLRfidAppEngine.shared().settings.tagFocus != 0 {
                    dwell = 2000
                }
                let power = Int(CSLRfidAppEngine.shared().settings.powerLevel[i] as! String)
                let portEnabled = Bool(truncating: CSLRfidAppEngine.shared().settings.isPortEnabled[i] as! NSNumber)
                CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                print("Antenna \(i): \(portEnabled ? "ON" : "OFF")")
                CSLRfidAppEngine.shared().reader.setAntennaConfig(portEnabled, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                CSLRfidAppEngine.shared().reader.setPower(Double(power! / 10))
                CSLRfidAppEngine.shared().reader.setAntennaDwell(UInt(dwell!))
                CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(dwell == 0 ? 65535 : 0)
            }
        }

    }

    func setAntennaPortsAndPowerForTagAccess() {

        CSLRfidAppEngine.shared().reader.setAntennaCycle(UInt(COMMAND_ANTCYCLE_CONTINUOUS))
        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
            //disable power level ramping
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
            //enable power output on selected port
            for i in 0..<4 {
                CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                print("Antenna \(i): \(Bool(truncating: CSLRfidAppEngine.shared().settings.isPortEnabled[i] as! NSNumber) ? "ON" : "OFF")")
                CSLRfidAppEngine.shared().reader.setAntennaConfig(CSLRfidAppEngine.shared().settings.tagAccessPort == i ? true : false, inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                CSLRfidAppEngine.shared().reader.setPower(Double(CSLRfidAppEngine.shared().settings.power / 10))
                CSLRfidAppEngine.shared().reader.setAntennaDwell(2000)
                CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(0)
            }
        }

    }

    func setAntennaPortsAndPowerForTagSearch() {

        CSLRfidAppEngine.shared().reader.setAntennaCycle(UInt(COMMAND_ANTCYCLE_CONTINUOUS))
        if CSLRfidAppEngine.shared().reader.readerModelNumber == READERTYPE.CS108 {
            //disable power level ramping
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
            //enable power output on selected port
            for i in 0..<4 {
                CSLRfidAppEngine.shared().reader.selectAntennaPort(UInt(i))
                print("Antenna \(i): \(Bool(truncating: CSLRfidAppEngine.shared().settings.isPortEnabled[i] as! NSNumber) ? "ON" : "OFF")")
                CSLRfidAppEngine.shared().reader.setAntennaConfig(Bool(truncating: CSLRfidAppEngine.shared().settings.isPortEnabled[i] as! NSNumber), inventoryMode: 0, inventoryAlgo: 0, startQ: 0, profileMode: 0, profile: 0, frequencyMode: 0, frequencyChannel: 0, isEASEnabled: false)
                CSLRfidAppEngine.shared().reader.setPower(Double(CSLRfidAppEngine.shared().settings.power / 10))
                CSLRfidAppEngine.shared().reader.setAntennaDwell(2000)
                CSLRfidAppEngine.shared().reader.setAntennaInventoryCount(0)
            }
        }

    }

    func setConfigurationsForTags() {

        //set inventory configurations
        //for multiplebank inventory
        var tagRead: UInt8 = 0
        if CSLRfidAppEngine.shared().settings.isMultibank1Enabled && CSLRfidAppEngine.shared().settings.isMultibank2Enabled {
            tagRead = 2
        } else if CSLRfidAppEngine.shared().settings.isMultibank1Enabled {
            tagRead = 1
        } else {
            tagRead = 0
        }
        
        var tagDelay: UInt8
        if CSLRfidAppEngine.shared().settings.tagFocus == 0 && tagRead != 0 {
            tagDelay = 30
        }
        else {
            tagDelay = 0
        }


        CSLRfidAppEngine.shared().reader.setQueryConfigurations((CSLRfidAppEngine.shared().settings.target == TARGET.ToggleAB ? TARGET.A : CSLRfidAppEngine.shared().settings.target), querySession: CSLRfidAppEngine.shared().settings.session, querySelect: QUERYSELECT.ALL)
        CSLRfidAppEngine.shared().reader.selectAlgorithmParameter(CSLRfidAppEngine.shared().settings.algorithm)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters0(UInt8(CSLRfidAppEngine.shared().settings.qValue), maximumQ: 15, minimumQ: 0, thresholdMultiplier: 4)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters1(0)
        CSLRfidAppEngine.shared().reader.setInventoryAlgorithmParameters2((CSLRfidAppEngine.shared().settings.target == TARGET.ToggleAB ? true : false), runTillZero: false)
        CSLRfidAppEngine.shared().reader.setInventoryConfigurations(CSLRfidAppEngine.shared().settings.algorithm, matchRepeats: 0, tagSelect: 0, disableInventory: 0, tagRead: tagRead, crcErrorRead: (tagRead != 0 ? 0 : 1), qtMode: 0, tagDelay: tagDelay, inventoryMode: (tagRead != 0 ? 0 : 1))
        CSLRfidAppEngine.shared().reader.setLinkProfile(CSLRfidAppEngine.shared().settings.linkProfile)

        if CSLRfidAppEngine.shared().settings.fastId != 0 {
            CSLRfidAppEngine.shared().reader.setQueryConfigurations((CSLRfidAppEngine.shared().settings.target == TARGET.ToggleAB ? TARGET.A : CSLRfidAppEngine.shared().settings.target), querySession: CSLRfidAppEngine.shared().settings.session, querySelect: QUERYSELECT.SL)
            CSLRfidAppEngine.shared().reader.clearAllTagSelect()
            CSLRfidAppEngine.shared().reader.tagmsk_DESC_SEL(0)
            CSLRfidAppEngine.shared().reader.selectTag(forInventory: MEMORYBANK.TID, maskPointer: 0, maskLength: 24, maskData: CSLBleReader.convertHexString(toData: "E2801100"), sel_action: 0)
            CSLRfidAppEngine.shared().reader.setInventoryConfigurations(CSLRfidAppEngine.shared().settings.algorithm, matchRepeats: 0, tagSelect: 1 /* force tag_select */, disableInventory: 0, tagRead: tagRead, crcErrorRead: 1, qtMode: 0, tagDelay: (tagRead != 0 ? 30 : 0), inventoryMode: (tagRead != 0 ? 0 : 1))
        }

        
        //frequency configurations
        if CSLRfidAppEngine.shared().readerRegionFrequency.isFixed != 0 {
            CSLRfidAppEngine.shared().reader.setFixedChannel(
                CSLRfidAppEngine.shared().readerRegionFrequency,
                regionCode: CSLRfidAppEngine.shared().settings.region,
                channelIndex: UInt32(CSLRfidAppEngine.shared().settings.channel)!)
        } else {
            CSLRfidAppEngine.shared().reader.setHoppingChannel(
                CSLRfidAppEngine.shared().readerRegionFrequency,
                regionCode: CSLRfidAppEngine.shared().settings.region)
        }


        
        // if multibank read is enabled
        if tagRead != 0 {
        CSLRfidAppEngine.shared().reader.tagacc_BANK(CSLRfidAppEngine.shared().settings.multibank1, acc_bank2: CSLRfidAppEngine.shared().settings.multibank2)
        CSLRfidAppEngine.shared().reader.tagacc_PTR(UInt32(CSLRfidAppEngine.shared().settings.multibank2Offset) << 16 + UInt32(CSLRfidAppEngine.shared().settings.multibank1Offset))
        CSLRfidAppEngine.shared().reader.tagacc_CNT(CSLRfidAppEngine.shared().settings.multibank1Length, secondBank: (tagRead == 2 ? CSLRfidAppEngine.shared().settings.multibank2Length : 0))
        }
        
        print("Tag focus value: \(CSLRfidAppEngine.shared().settings.tagFocus)")
        //Impinj Extension
        CSLRfidAppEngine.shared().reader.setImpinjExtension(
            CSLRfidAppEngine.shared().settings.tagFocus,
            fastId: CSLRfidAppEngine.shared().settings.fastId,
            blockWriteMode: 0)
        //LNA settings
        CSLRfidAppEngine.shared().reader.setLNAParameters(
            CSLRfidAppEngine.shared().reader,
            rflnaHighComp: CSLRfidAppEngine.shared().settings.rfLnaHighComp,
            rflnaGain: CSLRfidAppEngine.shared().settings.rfLna,
            iflnaGain: CSLRfidAppEngine.shared().settings.ifLna,
            ifagcGain: CSLRfidAppEngine.shared().settings.ifAgc)


    }
}

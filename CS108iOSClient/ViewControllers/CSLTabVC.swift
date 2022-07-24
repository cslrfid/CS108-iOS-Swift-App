//
//  CSLTabVC.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 15/9/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

import Foundation
import UIKit
import CSL_CS108

class CSLTabVC: UITabBarController, UITabBarControllerDelegate {
    
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

}

//
//  AppDelegate.swift
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 25/8/2018.
//  Copyright © 2018 Convergence Systems Limited. All rights reserved.
//

@objcMembers class AppDelegate: UIResponder, UIApplicationDelegate {

    var reader: CSLBleReader? = nil
    var tagRangingStartTime: Date? = nil
    var window: UIWindow?

    func UIColorFromRGB(_ rgbValue: UInt32) -> UIColor {
        UIColor(red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(rgbValue & 0xff)) / 255.0), alpha: 1.0)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        CSLRfidAppEngine.shared()

        UIBarButtonItem.appearance().tintColor = UIColorFromRGB(0xffffff)

        UINavigationBar.appearance().barTintColor = UIColorFromRGB(0x1f4788)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        let font = UIFont(name: "Lato-Bold", size: 25.0)
        if font != nil {
            UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor : UIColorFromRGB(0xffffff),
            .shadow : shadow,
            .font : font!
            ]
        }

        UIApplication.shared.isIdleTimerDisabled = true
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        //power off reader and disconnect before closing application
        if ((CSLRfidAppEngine.shared()?.reader) != nil) {
            if CSLRfidAppEngine.shared().reader.connectStatus == STATUS.CONNECTED {
                CSLRfidAppEngine.shared().reader.barcodeReader(false)
                CSLRfidAppEngine.shared().reader.power(onRfid: false)
                CSLRfidAppEngine.shared().reader.disconnectDevice()
            }
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

//
//  AppDelegate.swift
//  DataDome
//
//  Created by Med Hajlaoui on 11/05/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import DataDomeSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //swiftlint:disable discouraged_optional_collection
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DataDomeSDK.setLogLevel(level: .verbose)
        return true
    }
    //swiftlint:enable discouraged_optional_collection

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        return
    }
}

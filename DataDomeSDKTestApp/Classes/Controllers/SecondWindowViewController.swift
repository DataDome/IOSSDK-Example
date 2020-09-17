//
//  SecondWindowViewController.swift
//  App
//
//  Created by Med Hajlaoui on 08/07/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import WebKit
import DataDomeSDK

class SecondWindowViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    let mainWindow: UIWindow
    
    required init(mainWindow: UIWindow) {
        self.mainWindow = mainWindow
        super.init(nibName: "SecondWindowViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        self.mainWindow = UIWindow()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let url = URL(string: "https://datadome.co") else {
            print("Empty web URL. Will fail to load webview")
            return
        }
        
        // This snippet code is demostrating how cookies are shared from native to web.
        // Basically, the SDK will keep track of cookie collected by resolving a captcha,
        // you have to read the cookie and manually assign it to any web-based componenet of your app
        // otherwise your app will display a captcha on native side and another captcha on web side.
        webView.customUserAgent = "BLOCKUA"
        if let cookie = DataDomeSDK.getCookie() {
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    

    @IBAction func switchBackToTheMainWindowButtonPressed() {
        self.mainWindow.makeKeyAndVisible()
    }

}

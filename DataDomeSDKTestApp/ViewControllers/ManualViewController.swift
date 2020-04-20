//
//  ManualViewController.swift
//  DataDomeSDKTestApp
//
//  Created by Hugo Maurer on 02/10/2019.
//  Copyright © 2019 DataDome. All rights reserved.
//

import Foundation
import UIKit
import DataDomeSDK
import Alamofire

class ManualViewController: UIViewController, DataDomeSDKDelegate {

    /**
     * UI components declaration;
     */

    @IBOutlet weak var userAgentLabel: UILabel!
    @IBOutlet weak var delegateResponseLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet var containerView: UIView!

    /**
     * Variable declaration
     */ 
    private var logSource = "Manual VC"
    private var currentUseragent: String = Config.BlockUserAgent
    private var currentEndpoint: String = Config.DatadomeEndpoint
    private var dataDomeSdk: DataDomeSDK?
    private var appVersion: String?
    private var requestsCount = 0
    private var urlSession: URLSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        dataDomeSdk = DataDomeSDK(containerView: containerView, key: "my_test_key", appVersion: appVersion, userAgent: currentUseragent)
        dataDomeSdk?.delegate = self

        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        initUI()
    }

    private func initUI() {
        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
        self.userAgentLabel.text = String(format: "UA: %@ \nEP: %@", self.currentUseragent, self.currentEndpoint)
    }

    @IBAction func makeRequest(_ sender: UIButton) {

        guard let url = URL(string: currentEndpoint) else { return }
        var request = URLRequest(url: url)

        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true

        requestsCount += 1

        if let headers = dataDomeSdk?.getHeaders(withUserAgent: true) {
            for header in headers {
                print("\(header.key) -> \(header.value)")
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        let task = self.urlSession?.dataTask(with: request, completionHandler: { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse,
                let url = httpResponse.url,
                let data = data else {
                return
            }

            debugPrint("URL: \(url)")

            if self.dataDomeSdk?.verifyResponse(statusCode: httpResponse.statusCode, headers: httpResponse.allHeaderFields, url: url) == true {
                self.dataDomeSdk?.handleResponse(statusCode: httpResponse.statusCode,
                                                 headers: httpResponse.allHeaderFields,
                                                 url: url,
                                                 data: data,
                                                 completion: { (completion, message) in
                                                    debugPrint(message ?? "")
                })
            } else {
                DispatchQueue.main.async {
                    self.responseLabel.text = String(format: "Response code: %d", httpResponse.statusCode)
                    self.responseLabel.isHidden = false
                }
            }
        })
        task?.resume()
    }

    private func switchUaAndEndpoint(useragent: String, endpoint: String) {
        dataDomeSdk?.userAgent = useragent
        self.currentEndpoint = endpoint
        dataDomeSdk?.userAgent = useragent
        dataDomeSdk?.logEvent(id: 2, message: "User-agent changed", source: self.logSource)
        self.currentUseragent = useragent
        self.userAgentLabel.text = String(format: "UA: %@ \nEP: %@", useragent, endpoint)
    }

    @IBAction func didClickOnSwitchUA(_ sender: Any) {
        let alert = UIAlertController(title: "UA", message: "Choose wich Useragent", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ALLOW",
                                      style: .default,
                                      handler: { _ in self.switchUaAndEndpoint(useragent: Config.StandardUserAgent, endpoint: Config.DatadomeEndpoint) }))
        alert.addAction(UIAlertAction(title: "BLOCK",
                                      style: .default,
                                      handler: { _ in self.switchUaAndEndpoint(useragent: Config.BlockUserAgent, endpoint: Config.DatadomeEndpoint) }))
        self.present(alert, animated: true, completion: nil)

        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
    }

    @IBAction func didClickOnClearCache(_ sender: Any) {
        dataDomeSdk?.clearCache(AF, logId: 1, logMessage: "Cache cleared", logSource: self.logSource)
        let alert = UIAlertController(title: "Cache cleared", message: "Cache is cleared", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
    }

    func captcha(_ instance: DataDomeSDK, willAppear webView: UIView?) {
        debugPrint("Captcha will appear")
    }

    func captcha(_ instance: DataDomeSDK, didAppear webView: UIView?) {
        debugPrint("Captcha did appear")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }

    func captcha(_ instance: DataDomeSDK, willDisappear webView: UIView?) {
        debugPrint("Captcha will disappear")
    }

    func captcha(_ instance: DataDomeSDK, didDisappear webView: UIView?) {
        debugPrint("Captcha did disappear")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }

    func datadomeRespond(_ responseCode: Int, withData data: Any?) {
        debugPrint("datadomeRespond", responseCode, data ?? "")
        DispatchQueue.main.async {
            self.delegateResponseLabel.text = String(format: "Delegate response code: %d", responseCode)
            self.delegateResponseLabel.isHidden = false
        }
    }

    var startLocation: CGPoint?
    var startTime: CGFloat = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dataDomeSdk?.handleTouchEvent(touches, offType: .down, inView: self.view)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dataDomeSdk?.handleTouchEvent(touches, offType: .up, inView: self.view)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        dataDomeSdk?.handleTouchEvent(touches, offType: .move, inView: self.view)
    }
}

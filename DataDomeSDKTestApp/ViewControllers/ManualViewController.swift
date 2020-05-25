//
//  ManualViewController.swift
//  DataDomePOCCaptchaIOS
//
//  Created by Hugo Maurer on 23/09/2019.
//  Copyright © 2019 dev-datadome-05. All rights reserved.
//

import Foundation
import UIKit
import DataDomeSDK

class ManualViewController: UIViewController, DataDomeSDKDelegate {

    /**
     * UI components declaration;
     */

    @IBOutlet weak var userAgentLabel: UILabel!
    @IBOutlet weak var delegateResponseLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet var containerView: UIView!

    /**
     * Variable declaration
     */
    private var logSource = "URLSession VC"
    private var currentUseragent: String = Config.blockUserAgent
    private var currentEndpoint: String = Config.datadomeEndpoint200
    private var currentTestKey: String = Config.datadomeTestKey
    private var dataDomeSdk: DataDomeSDK?
    private var appVersion: String?
    private var requestsCount = 0
    private var urlSession: URLSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        dataDomeSdk = DataDomeSDK(containerView: containerView, key: currentTestKey, appVersion: appVersion, userAgent: currentUseragent)
        //dataDomeSdk = DataDomeSDK(key: currentTestKey, appVersion: appVersion, userAgent: currentUseragent)
        dataDomeSdk?.delegate = self

        /// URLSession delegate
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        initUI()
    }

    private func initUI() {
        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true
        self.userAgentLabel.text = String(format: "UA: %@ \nEP: %@", self.currentUseragent, self.currentEndpoint)
    }

    @IBAction func makeRequest(_ sender: UIButton) {

        guard let url = URL(string: currentEndpoint) else { return }
        var request = URLRequest(url: url)

        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true

        requestsCount += 1

        /// URLSession delegate/Users/hugomaurer/Downloads/TokenAuthenticator.java
        if let headers = dataDomeSdk?.getHeaders() {
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

            if self.dataDomeSdk?.verifyResponse(statusCode: httpResponse.statusCode, headers: httpResponse.allHeaderFields, url: url) == true {
                self.dataDomeSdk?.handleResponse(statusCode: httpResponse.statusCode,
                                                 headers: httpResponse.allHeaderFields,
                                                 url: url,
                                                 data: data,
                                                 completion: { (completion, message) in
                                                    print(completion)
                                                    print(message ?? "")
                })
            } else {
                DispatchQueue.main.async {
                    self.responseLabel.text = String(format: "Response code: %d", httpResponse.statusCode)
                    self.responseLabel.isHidden = false

                    self.responseTextView.text = "\(httpResponse)"
                    self.responseTextView.isHidden = false
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

    @IBAction func readCookie(_ sender: Any) {
        dataDomeSdk?.readCookie(completion: { (_) in
            guard let cookie = self.dataDomeSdk?.getLastCookie() else {
                self.responseTextView.isHidden = true
                return
            }
            self.displayCookie(cookie: cookie)
            self.responseTextView.isHidden = false
        })
    }

    private func displayCookie(cookie: HTTPCookie) {
        self.responseTextView.text = "Name: \(cookie.name)"
        self.responseTextView.text += "\nDomain: \(cookie.domain)"
        self.responseTextView.text += "\nPath: \(cookie.path)"
        self.responseTextView.text += "\nExpires: \(cookie.expiresDate?.description ?? "")"
        self.responseTextView.text += "\nValue: \(cookie.value)"
    }

    @IBAction func didClickOnSwitchUA(_ sender: Any) {
        let alert = UIAlertController(title: "UA and EP", message: "Choose wich Useragent and Endpoint you want", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ALLOW 200",
                                      style: .default,
                                      handler: { _ in self.switchUaAndEndpoint(useragent: Config.standardUserAgent, endpoint: Config.datadomeEndpoint200) }))
        alert.addAction(UIAlertAction(title: "ALLOW 404",
                                      style: .default,
                                      handler: { _ in self.switchUaAndEndpoint(useragent: Config.standardUserAgent, endpoint: Config.datadomeEndpoint404) }))
        alert.addAction(UIAlertAction(title: "BLOCK 200",
                                      style: .default,
                                      handler: { _ in self.switchUaAndEndpoint(useragent: Config.blockUserAgent, endpoint: Config.datadomeEndpoint200) }))
        alert.addAction(UIAlertAction(title: "BLOCK 404",
                                      style: .default,
                                      handler: { _ in self.switchUaAndEndpoint(useragent: Config.blockUserAgent, endpoint: Config.datadomeEndpoint404) }))
        self.present(alert, animated: true, completion: nil)

        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true
    }

    @IBAction func didClickOnClearCache(_ sender: Any) {
        dataDomeSdk?.clearCache(logId: 1, logMessage: "Cache cleared", logSource: self.logSource)
        let alert = UIAlertController(title: "Cache cleared", message: "Cache is cleared", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true
    }

    func captchaNeedsContainer(_ instance: DataDomeSDK, forCaptchaUrl url: String) {
        debugPrint("Captcha container needed for url: \(url)")
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

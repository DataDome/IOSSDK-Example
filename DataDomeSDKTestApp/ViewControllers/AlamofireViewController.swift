//
//  AlamofireViewController.swift
//  DataDomePOCCaptchaIOS
//
//  Created by dev-datadome-05 on 24/07/2017.
//  Copyright © 2017 dev-datadome-05. All rights reserved.
//

import UIKit
import DataDomeSDK
import Alamofire

class AlamofireViewController: UIViewController, DataDomeSDKDelegate {

    /**
     * UI components declaration;
     */
    @IBOutlet weak var userAgentLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var delegateResponseLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var multipleRequestSwitchButton: UISwitch!

    /**
     * Variable declaration
     */
    private var logSource = "Alamofire VC"
    private var currentUseragent: String = Config.blockUserAgent
    private var currentEndpoint: String = Config.datadomeEndpoint200
    private var currentTestKey: String = Config.datadomeTestKey
    private var dataDomeSdk: DataDomeSDK?
    private var appVersion: String?

    var alamofireSessionManager: Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        dataDomeSdk = DataDomeSDK(containerView: containerView, key: currentTestKey, appVersion: appVersion, userAgent: currentUseragent, integrationMode: .alamofire)
        dataDomeSdk?.delegate = self

        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        if let ddSdk = dataDomeSdk {
            let loader = AlamofireLoader(dataDomeSDK: ddSdk)
            let interceptors = Interceptor(adapter: loader.alamofireSessionAdapter,
                                            retrier: loader.alamofireSessionRetrier)
            alamofireSessionManager = Session(configuration: configuration, interceptor: interceptors)
        }

        initUI()
    }

    private func initUI() {
        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true
        self.userAgentLabel.text = String(format: "UA: %@ \nEP: %@", self.currentUseragent, self.currentEndpoint)

        self.multipleRequestSwitchButton.onTintColor = .green
        self.multipleRequestSwitchButton.tintColor = .lightGray
        self.multipleRequestSwitchButton.layer.cornerRadius = self.multipleRequestSwitchButton.frame.height / 2
        self.multipleRequestSwitchButton.backgroundColor = .lightGray
    }

    @IBAction func makeRequest(_ sender: UIButton) {
        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true

        let requestToMakeCount = multipleRequestSwitchButton.isOn ? 5 : 1

        for i in 1...requestToMakeCount {
            DispatchQueue.global(qos: .userInitiated).async {
                self.alamofireSessionManager?.request(self.currentEndpoint).withDataDome(self.dataDomeSdk).validate().responseJSON { res in
                    guard let statusCode = res.response?.statusCode else { return }

                    DispatchQueue.main.async {
                        print("Response from Task: \(i)")
                        let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)

                        self.responseLabel.text = String(format: "Response code: %d", statusCode)
                        self.responseLabel.isHidden = false
                        self.responseLabel.textColor = color

                        self.responseTextView.text = "\(String(describing: res.response))"
                        self.responseTextView.isHidden = false
                        self.responseTextView.textColor = color
                    }
                }
            }
        }
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
        dataDomeSdk?.clearCache(alamofireSessionManager, logId: 1, logMessage: "Cache cleared", logSource: self.logSource)
        let alert = UIAlertController(title: "Cache cleared", message: "Cache is cleared", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

        responseLabel.isHidden = true
        responseTextView.isHidden = true
        delegateResponseLabel.isHidden = true
    }

    func captchaNeedsContainer(_ instance: DataDomeSDK, forCaptchaUrl url: String) {
        debugPrint("Captcha container needed")
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

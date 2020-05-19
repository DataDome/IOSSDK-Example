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
    @IBOutlet weak var multipleRequestSwitchButton: UISwitch!
    @IBOutlet weak var responseTextView: UITextView!

    /**
     * Variable declaration
     */
    private var logSource = "Alamofire VC"
    private var currentUseragent: String = Config.BlockUserAgent
    private var currentEndpoint: String = Config.DatadomeEndpoint
    private var dataDomeSdk: DataDomeSDK?
    private var appVersion: String?

    var alamofireSessionManager: Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        dataDomeSdk = DataDomeSDK(containerView: containerView, key: "my_test_key", appVersion: appVersion, userAgent: currentUseragent)
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
        delegateResponseLabel.isHidden = true
        self.userAgentLabel.text = String(format: "UA: %@ \nEP: %@", self.currentUseragent, self.currentEndpoint)
        self.responseTextView.text = ""

        self.multipleRequestSwitchButton.onTintColor = .green
        self.multipleRequestSwitchButton.tintColor = .lightGray
        self.multipleRequestSwitchButton.layer.cornerRadius = self.multipleRequestSwitchButton.frame.height / 2
        self.multipleRequestSwitchButton.backgroundColor = .lightGray
    }

    @IBAction func makeRequest(_ sender: UIButton) {
        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
        self.responseTextView.text = ""

        let requestToMakeCount = multipleRequestSwitchButton.isOn ? 5 : 1

        for i in 1...requestToMakeCount {
            DispatchQueue.global(qos: .userInitiated).async {
                /// Alamofire request Adapter/Retrier
                self.alamofireSessionManager?.request(self.currentEndpoint).withDataDome(self.dataDomeSdk).validate().responseJSON { res in
                    guard let statusCode = res.response?.statusCode else { return }
                    DispatchQueue.main.async {
                        let text = self.responseTextView.text ?? ""
                        self.responseTextView.text = text == "" ? "Response from Task: \(i)" : "\(text)\nResponse from Task: \(i)"
                        print("Response from Task: \(i)")
                        self.responseLabel.text = String(format: "Response code: %d", statusCode)
                        self.responseLabel.isHidden = false
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
        dataDomeSdk?.clearCache(self.alamofireSessionManager, logId: 1, logMessage: "Cache cleared", logSource: self.logSource)
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

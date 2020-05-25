//
//  MoyaViewController.swift
//  DataDomePOCCaptchaIOS
//
//  Created by Hugo Maurer on 23/07/2019.
//  Copyright © 2019 dev-datadome-05. All rights reserved.
//

import UIKit
import DataDomeSDK
import Alamofire
import Moya
import AVFoundation

class MoyaViewController: UIViewController, DataDomeSDKDelegate {

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
    private var logSource = "Moya VC"
    private var currentUseragent: String = Config.blockUserAgent
    private var currentEndpoint: String = Config.datadomeEndpoint200
    private var currentTestKey: String = Config.datadomeTestKey
    private var dataDomeSdk: DataDomeSDK?
    private var appVersion: String?

    var alamofireSessionManager: Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        if let ddSdk = dataDomeSdk {
            let loader = AlamofireLoader(dataDomeSDK: ddSdk)
            let interceptors = Interceptor(adapter: loader.alamofireSessionAdapter,
                                           retrier: loader.alamofireSessionRetrier)
            return Session(configuration: configuration, interceptor: interceptors)
        }
        return Session(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        dataDomeSdk = DataDomeSDK(containerView: containerView, key: currentTestKey, appVersion: appVersion, userAgent: currentUseragent, integrationMode: .moya)
        dataDomeSdk?.delegate = self

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
        for _ in 1...requestToMakeCount {
            moyaCall()
        }
    }

    private func moyaCall() {
        let provider = MoyaProvider<DatadomeService>(endpointClosure: moyaEndPointClosure(),
                                                     session: alamofireSessionManager,
                                                     plugins: [DataDomePlugin(with: self.dataDomeSdk)])

        let target = DatadomeService.getDataDomeService

        provider.request(target, completion: { (result) in

            switch result {
            case let .success(response):
                guard let statusCode = response.response?.statusCode else { return }
                DispatchQueue.main.async {

                    let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)

                    self.responseLabel.text = String(format: "Response code: %d", statusCode)
                    self.responseLabel.isHidden = false
                    self.responseLabel.textColor = color

                    self.responseTextView.text = "\(String(describing: response.response))"
                    self.responseTextView.isHidden = false
                    self.responseTextView.textColor = color
                }
            case let .failure(error):
                guard let statusCode = error.response?.statusCode else { return }
                DispatchQueue.main.async {

                    let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)

                    self.responseLabel.text = String(format: "Response code: %d", statusCode)
                    self.responseLabel.isHidden = false
                    self.responseLabel.textColor = color

                    self.responseTextView.text = "\(error)"
                    self.responseTextView.isHidden = false
                    self.responseTextView.textColor = color
                }
            }
        })
    }

    private func moyaEndPointClosure() -> MoyaProvider<DatadomeService>.EndpointClosure { { (target: DatadomeService) -> Endpoint in
            let url = self.currentEndpoint
            let endpoint = Endpoint(
                url: url,
                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
            return endpoint
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

    @IBAction func didClickOnCamera(_ sender: Any) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { _ in
            }
        default:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // "App-Prefs:root=General"
                    UIApplication.shared.openURL(url)
                }
            }
        }
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
        dataDomeSdk?.clearCache(AF, logId: 1, logMessage: "Cache cleared", logSource: self.logSource)
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

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

class MoyaViewController: UIViewController, DataDomeSDKDelegate {

    /**
     * UI components declaration;
     */
    @IBOutlet weak var userAgentLabel : UILabel!
    @IBOutlet var containerView       : UIView!
    @IBOutlet weak var delegateResponseLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    
    /**
     * Variable declaration
     */
    private var logSource = "Moya VC"
    private var currentUseragent : String = Config.BlockUserAgent
    private var currentEndpoint : String = Config.DatadomeEndpoint200
    private var dataDomeSdk: DataDomeSDK?
    private var appVersion : String?
    private var requestsCount = 0
    
    static let alamofireSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        return SessionManager(configuration: configuration)
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        dataDomeSdk = DataDomeSDK(containerView: containerView, key: "my_test_key", appVersion: appVersion, userAgent: currentUseragent)
        dataDomeSdk?.delegate = self
        
        /// Alamofire request Adapter/Retrier
        MoyaViewController.alamofireSessionManager.adapter = dataDomeSdk?.alamofireSessionAdapter
        MoyaViewController.alamofireSessionManager.retrier = dataDomeSdk?.alamofireSessionRetrier
        
        initUI()
    }
    
    private func initUI() {
        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
        self.userAgentLabel.text = String(format: "UA: %@ \nEP: %@", self.currentUseragent, self.currentEndpoint)
    }
    
    @IBAction func makeRequest(_ sender: UIButton)
    {
        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
        
        requestsCount += 1
        
        moyaCall()
    }
    
    private func moyaCall() {
        let provider = MoyaProvider<DatadomeService>(endpointClosure: moyaEndPointClosure(), manager: MoyaViewController.alamofireSessionManager, plugins: [NetworkLoggerPlugin(verbose: true)])
        let target = DatadomeService.getDataDomeService
        
        provider.request(target, completion: { (result) in
            
            switch result {
            case let .success(response):
                let statusCode = response.response!.statusCode
                guard let url = URL(string: self.currentEndpoint) else {
                    return
                }
                self.dataDomeSdk?.handleResponse(url: url, code: statusCode, headers: response.response?.allHeaderFields as! [String : String], data: response.data, fromInternal: false, completion: { wasBlocked, code, response, data in
                    DispatchQueue.main.async {
                        self.responseLabel.text = String(format: "Response code: %d", statusCode)
                        self.responseLabel.isHidden = false
                    }
                }) { error, code in
                    DispatchQueue.main.async {
                        self.responseLabel.text = String(format: "Response code: %d", statusCode)
                        self.responseLabel.isHidden = false
                    }
                }
            case let .failure(error):
                let statusCode = error.response!.statusCode
                DispatchQueue.main.async {
                    self.responseLabel.text = String(format: "Response code: %d", statusCode)
                    self.responseLabel.isHidden = false
                }
            }
        })
    }
    
    private func moyaEndPointClosure() -> MoyaProvider<DatadomeService>.EndpointClosure {
        
        return { (target: DatadomeService) -> Endpoint in
            
            let url = self.currentEndpoint
            let endpoint = Endpoint(
                url: url,
                sampleResponseClosure: {.networkResponse(200, target.sampleData)},
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
    
    @IBAction func didClickOnSwitchUA(_ sender: Any) {
        let alert = UIAlertController(title: "UA", message: "Choose wich Useragent", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ALLOW", style: .default, handler: { _ in self.switchUaAndEndpoint(useragent: Config.StandardUserAgent, endpoint: Config.DatadomeEndpoint200)}))
        alert.addAction(UIAlertAction(title: "BLOCK", style: .default, handler: { _ in self.switchUaAndEndpoint(useragent: Config.BlockUserAgent, endpoint: Config.DatadomeEndpoint200)}))
        self.present(alert, animated: true, completion: nil)
        
        responseLabel.isHidden = true
        delegateResponseLabel.isHidden = true
    }
    
    @IBAction func didClickOnClearCache(_ sender: Any) {
        dataDomeSdk?.clearCache(AlamofireViewController.alamofireSessionManager, logId: 1, logMessage: "Cache cleared", logSource: self.logSource)
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
    
    var startLocation: CGPoint? = nil
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

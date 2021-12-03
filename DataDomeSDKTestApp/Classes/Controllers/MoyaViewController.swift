//
//  MoyaViewController.swift
//  App
//
//  Created by Med Hajlaoui on 07/06/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import Alamofire
import Moya
import AVFoundation

import DataDomeAlamofire

class MoyaViewController: NetworkingViewController {
    
    var alamofireSessionManager: Session?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        
        let dataDome = AlamofireInterceptor()
        let interceptor = Interceptor(adapter: dataDome.sessionAdapter, retrier: dataDome.sessionRetrier)
        alamofireSessionManager = Session(configuration: configuration, interceptor: interceptor)
    }
    
    
    override func makeRequest(index: Int) {
        moyaCall()
    }
    
    private func moyaCall() {
        guard let session = alamofireSessionManager else {
            return
        }
        
        let provider = MoyaProvider<MyService>(endpointClosure: moyaEndPointClosure(),
                                               session: session,
                                               plugins: [])
        
        provider.request(.ping, completion: { (result) in
            
            switch result {
            case let .success(response):
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                
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
                guard let statusCode = error.response?.statusCode else {
                    return
                }
                
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
    
    private func moyaEndPointClosure() -> MoyaProvider<MyService>.EndpointClosure { { (target: MyService) -> Endpoint in
        let url = "https://datadome.co/wp-json"
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
}


// MARK: - Moya
enum MyService {
    case ping
}

extension MyService: TargetType {
    var baseURL: URL {
        let url = URL(string: "https://datadome.co") ?? URL(fileURLWithPath: "")
        return url
    }
    
    var validationType: ValidationType {
        let type = ValidationType.successAndRedirectCodes
        return type
    }
    
    var path: String {
        switch self {
        case .ping:
            return "/wp-json"
        }
    }
        
    var method: Moya.Method {
        switch self {
        case .ping:
            return .get
        }
    }
        
    var task: Task {
        switch self {
        case .ping:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
        case .ping:
            return Data()
        }
    }
        
    // swiftlint:disable discouraged_optional_collection
    var headers: [String: String]? {
        let headers = ["Content-type": "application/json"]
        return headers
    }
    // swiftlint:enable discouraged_optional_collection
}

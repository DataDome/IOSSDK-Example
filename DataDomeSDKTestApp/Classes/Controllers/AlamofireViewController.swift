//
//  AlamofireViewController.swift
//  App
//
//  Created by Med Hajlaoui on 07/06/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import Alamofire
import DataDomeAlamofire
import DataDomeSDK

class AlamofireViewController: NetworkingViewController {
    
    var alamofireSessionManager: Alamofire.Session?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpShouldSetCookies = true
        
        let dataDome = AlamofireInterceptor(captchaDelegate: self)
        let interceptor = Interceptor(adapter: dataDome.sessionAdapter, retrier: dataDome.sessionRetrier)
        alamofireSessionManager = Session(configuration: configuration, interceptor: interceptor)
    }
    
    override func makeRequest(index: Int) {
        self.alamofireSessionManager?.request(self.endpoint()).validate().responseData { res in
            print("Response from Task: \(index)")
            let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
            
            
            
            guard let statusCode = res.response?.statusCode else {
                self.responseTextView.text = "Did finish with error \(String(describing: res.error?.localizedDescription))"
                self.responseTextView.isHidden = false
                self.responseTextView.textColor = color
                return
            }
            
            self.responseTextView.text = "\(String(describing: res.response))"
            self.responseTextView.isHidden = false
            self.responseTextView.textColor = color
            
            self.responseLabel.text = String(format: "Response code: %d", statusCode)
            self.responseLabel.isHidden = false
            self.responseLabel.textColor = color
        }
    }
}

extension AlamofireViewController: CaptchaDelegate {
    func present(captchaController controller: UIViewController) {
        present(controller, animated: true) {
            print("Captcha displayed")
        }
    }
    
    func dismiss(captchaController controller: UIViewController) {
        controller.dismiss(animated: true) {
            print("Captcha dismissed")
        }
    }
    
    
}

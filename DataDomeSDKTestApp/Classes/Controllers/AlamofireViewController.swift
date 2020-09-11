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

class AlamofireViewController: NetworkingViewController {
    
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
        self.alamofireSessionManager?.request(self.endpoint).validate().responseJSON { res in
            guard let statusCode = res.response?.statusCode else {
                return
            }
            
            print("Response from Task: \(index)")
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

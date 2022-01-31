//
//  NetworkingViewController.swift
//  App
//
//  Created by Med Hajlaoui on 07/06/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import AVFoundation

class NetworkingViewController: UIViewController {

    /**
     * UI components declaration;
     */
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var multipleRequestSwitchButton: UISwitch!
    
    func endpoint() -> String {
        // For multi-domain accounts, use two endpoints with different domains
        let firstEndpoint = "https://datadome.co/wp-json"
        let secondEndpoint = "https://datadome.co/wp-json"
        let endpoints = [firstEndpoint, secondEndpoint]
        let endpoint = endpoints.randomElement() ?? firstEndpoint
        return endpoint
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    private func initUI() {
        self.responseLabel.isHidden = true
        self.responseTextView.isHidden = true
        
        self.multipleRequestSwitchButton.onTintColor = .green
        self.multipleRequestSwitchButton.tintColor = .lightGray
        self.multipleRequestSwitchButton.layer.cornerRadius = self.multipleRequestSwitchButton.frame.height / 2
        self.multipleRequestSwitchButton.backgroundColor = .lightGray
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
    
    @IBAction func didClickOnClearCache(_ sender: Any) {
        self.clearCache()
        
        let alert = UIAlertController(title: "Cache cleared", message: "Cache is cleared", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.responseLabel.isHidden = true
        self.responseTextView.isHidden = true
    }
    
    @IBAction func makeRequest(_ sender: UIButton) {
        self.responseLabel.isHidden = true
        self.responseTextView.isHidden = true
        
        let requestToMakeCount = multipleRequestSwitchButton.isOn ? 50 : 1
        
        DispatchQueue.concurrentPerform(iterations: requestToMakeCount) { index in
            self.makeRequest(index: index)
        }
    }
    
    func makeRequest(index: Int) {
        print("Override this methode")
    }
    
    func clearCache() {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
}

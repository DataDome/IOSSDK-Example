//
//  NetworkingViewController.swift
//  App
//
//  Created by Med Hajlaoui on 07/06/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit

class NetworkingViewController: UIViewController {

    /**
     * UI components declaration;
     */
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var multipleRequestSwitchButton: UISwitch!
    
    let endpoint: String = "https://datadome.co/wp-json"
    
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
        
        let requestToMakeCount = multipleRequestSwitchButton.isOn ? 5 : 1
        
        for i in 1...requestToMakeCount {
            self.makeRequest(index: i)
        }
    }
    
    func makeRequest(index: Int) {
        print("Override this methode")
    }
    
    func clearCache() {
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
}

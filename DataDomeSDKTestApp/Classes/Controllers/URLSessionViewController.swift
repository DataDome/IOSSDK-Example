//
//  URLSessionViewController.swift
//  App
//
//  Created by Med Hajlaoui on 07/06/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import DataDomeSDK

class URLSessionViewController: NetworkingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func makeRequest(index: Int) {
        self.makeRequest(taskIdToPrint: "\(index)")
    }
    
    private func makeRequest(taskIdToPrint: String = "") {
        print("Enter Task: \(taskIdToPrint)")
        guard let url = URL(string: self.endpoint) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler: { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Leave Task in error mode: \(taskIdToPrint)")
                return
            }
            
            print("Task returned with success: \(taskIdToPrint)")
            DispatchQueue.main.sync {
                let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
                
                self.responseLabel.text = String(format: "Response code: %d", httpResponse.statusCode)
                self.responseLabel.isHidden = false
                self.responseLabel.textColor = color
                
                self.responseTextView.text = "\(httpResponse)"
                self.responseTextView.isHidden = false
                self.responseTextView.textColor = color
            }
        })
        task.resume()
    }
    
    @IBAction func changeWindowButtonPressed() {
        guard let mainWindow = self.view.window else {
            print("Unable to hold the main window")
            return
        }
        
        let vc = SecondWindowViewController(mainWindow: mainWindow)
        if let scene = UIApplication.shared.connectedScenes.first {
            guard let windowScene = (scene as? UIWindowScene) else {
                return
            }
            
            print(">>> windowScene: \(windowScene)")
            let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window.windowScene = windowScene
            
            let controller = UIViewController()
            window.rootViewController = controller
            (windowScene.delegate as? SceneDelegate)?.window = window
            window.makeKeyAndVisible()
            
            controller.present(vc, animated: true, completion: nil)
        }
        
    }
}

/*extension URLSessionViewController: CaptchaDelegate {
    func present(captchaController controller: UIViewController) {
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func dismiss(captchaController controller: UIViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}*/

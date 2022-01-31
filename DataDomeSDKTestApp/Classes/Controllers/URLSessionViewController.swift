//
//  URLSessionViewController.swift
//  App
//
//  Created by Med Hajlaoui on 07/06/2020.
//  Copyright © 2020 DataDome. All rights reserved.
//

import UIKit
import DataDomeSDK
import Combine

class URLSessionViewController: NetworkingViewController, URLSessionDelegate {
    var subs: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func makeRequest(index: Int) {
        self.makeRequest(taskIdToPrint: "\(index)")
        
        /*if #available(iOS 13, *) {
         self.makeRequestWithPublisher(taskIdToPrint: "\(index)")
         } else {
         // Fallback on earlier versions
         self.makeRequest(taskIdToPrint: "\(index)")
         }*/
    }
    
    private func makeRequest(taskIdToPrint: String = "") {
        print("Enter Task: \(taskIdToPrint)")
        guard let url = URL(string: self.endpoint()) else {
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.protectedDataTask(
            withRequest: request,
            captchaDelegate: nil,
            completionHandler: { _, response, error in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
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
                    
                    self.responseTextView.text = "\(httpResponse.allHeaderFields)"
                    self.responseTextView.isHidden = false
                    self.responseTextView.textColor = color
                }
            })
        task.resume()
    }
    
    @available(iOS 13, *)
    private func makeRequestWithPublisher(taskIdToPrint: String = "") {
        print("Enter Task: \(taskIdToPrint)")
        guard let url = URL(string: self.endpoint()) else {
            return
        }
        
        let sub = URLSession
            .shared
            .protectedDataTaskPublisher(forURL: url, captchaDelegate: nil)
            .sink(receiveCompletion: { completion in
                print("received completion")
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error returned: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                print("received value")
                guard let httpResponse = response.response as? HTTPURLResponse else {
                    print("Leave Task in error mode: \(taskIdToPrint)")
                    return
                }
                
                print("Task returned with success: \(taskIdToPrint)")
                DispatchQueue.main.sync {
                    let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
                    
                    self.responseLabel.text = String(format: "Response code: %d", httpResponse.statusCode)
                    self.responseLabel.isHidden = false
                    self.responseLabel.textColor = color
                    
                    self.responseTextView.text = "\(httpResponse.allHeaderFields)"
                    self.responseTextView.isHidden = false
                    self.responseTextView.textColor = color
                }
            })
        
        subs.append(sub)
    }
    
    @IBAction func changeWindowButtonPressed() {
        /*guard let mainWindow = self.view.window else {
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
         }*/
        
    }
}

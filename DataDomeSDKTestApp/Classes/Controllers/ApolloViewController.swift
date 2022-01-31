//
//  ApolloViewController.swift
//  App
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//  Copyright © 2021 DataDome. All rights reserved.
//

import UIKit
import DataDomeApollo
import Apollo

class ApolloViewController: NetworkingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func makeRequest(index: Int) {
        self.makeRequest(taskIdToPrint: "\(index)")
    }
    
    private func makeRequest(taskIdToPrint: String = "") {
        print("Enter Task: \(taskIdToPrint)")
        
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            DispatchQueue.main.async {
                let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)

                self.responseLabel.isHidden = false
                self.responseLabel.textColor = color
                
                self.responseTextView.isHidden = false
                self.responseTextView.textColor = color
                
                switch result {
                case .success(let response):
                    print("Leave Task in success mode: \(taskIdToPrint)")

                    self.responseLabel.text = "Success"
                    self.responseTextView.text = "Response: \(response)"
                case .failure(let error):
                    print("Leave Task in error mode: \(taskIdToPrint)")
                    
                    self.responseLabel.text = "Error"
                    self.responseTextView.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}


class Network {
    static let shared = Network()
    
    private(set) lazy var apollo: ApolloClient = {
        // Create your own store needed to init the DataDomeInterceptor provider
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        
        // Configure your session client
        let client = DataDomeURLSessionClient()
        
        // Create the DataDome Interceptor Provider
        let provider = DataDomeInterceptorProvider(store: store, client: client)
        
        // Create your GraphQL URL
        guard let url = URL(string: "https://datadome.co/wp-json") else {
            fatalError("Unable to create url https://datadome.co/wp-json")
        }
        
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                 endpointURL: url,
                                                                 useGETForQueries: true)
        
        // Create the client with the request chain transport
        return ApolloClient(networkTransport: requestChainTransport,
                            store: store)
    }()
    
}

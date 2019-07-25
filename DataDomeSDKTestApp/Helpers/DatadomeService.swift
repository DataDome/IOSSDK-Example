//
//  DatadomeService.swift
//  DataDomePOCCaptchaIOS
//
//  Created by Hugo Maurer on 23/07/2019.
//  Copyright © 2019 dev-datadome-05. All rights reserved.
//

import Foundation
import Moya

enum DatadomeService {
    case getDataDomeService
}

// MARK: - TargetType Protocol Implementation
extension DatadomeService: TargetType {
    
    // NOTE : It is important to set-up validationType because default of Moya is accepting all request and never go in retrier of DD
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    var baseURL: URL { return URL(string: "https://datadome.co/")! }
    
    var path: String {
        switch self {
        case .getDataDomeService:
            return "wp-json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)! as Data
    }
    
    var multipartBody: [Moya.MultipartFormData]? {
        return nil
    }
    
    var task: Task {
        let defaultParams = [String : Any]()
        return .requestParameters(parameters: defaultParams, encoding: URLEncoding.default)
    }
}

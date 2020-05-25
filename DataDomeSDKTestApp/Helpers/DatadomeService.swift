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
    var headers: [String: String]? {
        [:]
    }

    var validationType: ValidationType {
        .successAndRedirectCodes
    }

    var baseURL: URL {
        guard let url = URL(string: "https://datadome.co/") else {
            fatalError("Error: Bad BaseURL")
        }
        return url
    }

    var path: String {
        switch self {
        case .getDataDomeService:
            return "wp-json"
        }
    }

    var method: Moya.Method {
        .get
    }

    var sampleData: Data {
        "".data(using: String.Encoding.utf8) ?? Data()
    }

    var multipartBody: [Moya.MultipartFormData]? {
        nil
    }

    var task: Task {
        let defaultParams = [String: Any]()
        return .requestParameters(parameters: defaultParams, encoding: URLEncoding.default)
    }
}

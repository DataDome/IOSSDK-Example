//
//  Datadome+Helper.swift
//  DataDomePOCCaptchaIOS
//
//  Created by Hugo Maurer on 22/07/2019.
//  Copyright © 2019 dev-datadome-05. All rights reserved.
//

import Foundation
import DataDomeSDK
import Alamofire

extension DataDomeSDK {
    
    public func clearCache(_ sessionManager: SessionManager? = nil, logId: Int = 1, logMessage: String = "", logSource: String = "") {
        self.clearCookie()
        sessionManager?.session.reset {
            debugPrint("Alamofire session cleared")
        }
        self.logEvent(id: logId, message: logMessage, source: logSource)
    }
}

//
//  PTError.swift
//  NKTube
//
//  Created by NoodleKim on 2018/11/16.
//  Copyright © 2018 NoodleKim. All rights reserved.
//

import Foundation
import Alamofire

public enum PTError: Error {
    
    case networkError
    case alamofireError(error: Error)
    case successRefreshToken
    case failRefreshToken
    case otherAPIError(error: APIError)
    case exceedAuthErrorCount
}

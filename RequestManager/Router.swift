//
//  Router.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = ""
    
    case getPlaylist //(params)
    
    var method: HTTPMethod {
        switch self {
        case .getPlaylist:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getPlaylist:
            return ""
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        // Set parameters
        
        return urlRequest
    }
}

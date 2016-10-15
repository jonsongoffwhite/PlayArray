//
//  Router.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import Alamofire

/// Router contains information about a request, and provides information for specific requests
/// so we don't have to
enum Router: URLRequestConvertible {
    /// The base URL of the API
    static let baseURLString = ""
    
    case getPlaylist //(params)
    
    /// The HTTP method related to the call we are making
    var method: HTTPMethod {
        switch self {
        case .getPlaylist:
            return .get
        }
    }
    
    /// The URL extension related to the call we are making
    var path: String {
        switch self {
        case .getPlaylist:
            return ""
        }
    }
    
    /** 
        Provides a URLRequest based on the API call
     
        - Returns:
            A URLRequest created using information provided by the router, specific to the current API call
     */
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        // Set parameters
        
        return urlRequest
    }
}

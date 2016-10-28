//
//  Router.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Router contains information about a request, and provides information for specific requests
/// so we don't have to
enum Router: URLRequestConvertible {

    /// The base URL of the API
    static let baseURLString = "http://cloud-vm-46-57.doc.ic.ac.uk:3000/api/v1/playlist?"
    
    case getPlaylist(criteria: [(String, String)])
    
    /// The HTTP method related to the call we are making
    var method: HTTPMethod {
        switch self {
        case .getPlaylist(_):
            return .get
        }
    }
    
    /// The URL extension related to the call we are making
    var path: String {
        switch self {
        case .getPlaylist(let criteria):
            return pathFrom(criteria: criteria)
        }
    }
    
    /** 
        Provides a URLRequest based on the API call
     
        - Returns:
            A URLRequest created using information provided by the router, specific to the current API call
     */
    func asURLRequest() throws -> URLRequest {
        let url = try (Router.baseURLString + path).asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Set parameters where necessary
        
        return urlRequest
    }
    
    func pathFrom(criteria: [(String, String)]) -> String {
        var path = ""
        criteria.forEach { (id, value) in
            path += id + "=" + value + "&"
        }
        path = path.substring(to: path.index(before: path.endIndex))
        print("path: \(path)")
        return path
    }
}

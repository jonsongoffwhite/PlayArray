//
//  RequestProtocol.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import SwiftyJSON

/// The public protocol which lists available API calls to be used by PlayArray
public protocol RequestProtocol {
    func getPlaylist(from criteria: [(String, String)], completion: @escaping (JSON, NSError?) -> Void)
    
    func getWeather(_ lat: Double, lon: Double, completion: @escaping (String, NSError?) -> Void)
}

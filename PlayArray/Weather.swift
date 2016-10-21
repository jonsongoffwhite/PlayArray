//
//  Weather.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import RequestManager

/// Represents all possible options for weather
public enum Weather: Criteria {
    case sunny
    case raining
    case overcast
    case snow
    case windy
    
    var stringValue: String {
        switch self {
        case .sunny: return "sunny"
        case .raining: return "raining"
        case .overcast: return "overcast"
        case .snow: return "snow"
        case .windy: return "windy"
        }
    }
}

// Category for weather
class WeatherCategory: LocationCategory {
    
    /// Get the current weather for the user's location using some API
    override func getData() {
        let location = self.locationManager.location!.coordinate
        // Request using location (latitude and longitude)
        // Convert answer of call into enum value(s)
        
        // Maybe move this api call into a WeatherManager or something
        let Request: RequestProtocol = RequestManager.sharedInstance
        Request.getWeather(location.latitude, lon: location.longitude) { (weather, error) in
            // fill in criteria
        }
    }
    
}

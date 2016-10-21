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
public enum Weather: String, Criteria {
    
    case thunderstorm = "thunderstorm"
    case drizzle = "drizzle"
    case rain = "rain"
    case snow = "snow"
    case clear = "clear"
    case clouds = "clouds"
    case extreme = "extreme"
    case atmosphere = "atmosphere"
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
            self.criteria.append(Weather(rawValue: weather.lowercased())!)
        }
    }
    
}

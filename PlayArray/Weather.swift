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
    case sunny = "sunny"
    case raining = "raining"
    case overcast = "overcast"
    case snow = "snow"
    case windy = "windy"
    
    /* The Open Weather Map weather categories
    case thunderstorm = "thunderstorm"
    case drizzle = "drizzle"
    case rain = "rain"
    case snow = "snow"
    case clear = "clear"
    case clouds = "clouds"
    case extreme = "extreme"
    case atmosphere = "atmosphere"
 */
}

// Category for weather
class WeatherCategory: LocationCategory {
    
    /// Get the current weather for the user's location using some API
    override func getData(completion: @escaping () -> Void) {
        let location = self.locationManager.location!.coordinate
        // Request using location (latitude and longitude)
        // Convert answer of call into enum value(s)
        
        // Maybe move this api call into a WeatherManager or something
        let Request: RequestProtocol = RequestManager.sharedInstance
        Request.getWeather(location.latitude, lon: location.longitude) { (weather, error) in
            // We shouldn't have to do this conversion when we agree on the weather categories
            var weather_: String = weather.lowercased()
            switch weather.lowercased() {
            case "clear": weather_ = "sunny"
            case "rain": weather_ = "raining"
            case "extreme": weather_ = "windy"
            default: weather_ = "overcast"
            }

            self.criteria.append(Weather(rawValue: weather_)!)
            completion()
        }
    }
    
}

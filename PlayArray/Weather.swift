//
//  Weather.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import RequestManager
import CoreLocation

/// Represents all possible options for weather
public enum Weather: String, Criteria {
    case sunny = "sunny"
    case rainy = "rainy"
    case cloudy = "cloudy"
    case snowy = "snowy"
    case thunderstorm = "thunderstorm"
    
    static let allValues = [Weather.sunny, Weather.rainy, Weather.cloudy, Weather.snowy, Weather.thunderstorm]
}

// Category for weather
class WeatherCategory: LocationCategory {
    
    /// Get the current weather for the user's location using some API
    override func getData(completion: @escaping () -> Void) {
        var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        if self.locationManager.location != nil {
            location = self.locationManager.location!.coordinate
        }
        
        // Request using location (latitude and longitude)
        // Convert answer of call into enum value(s)
        
        // Maybe move this api call into a WeatherManager
        let Request: RequestProtocol = RequestManager.sharedInstance
        Request.getWeather(location.latitude, lon: location.longitude) { (weather, error) in
            var weather_: String = weather.lowercased()
            switch weather.lowercased() {
            case "clear": weather_ = "sunny"
            case "rain": weather_ = "rainy"
            case "snow": weather_ = "snowy"
            case "thunderstorm", "extreme": weather_ = "thunderstorm"
            default: weather_ = "cloudy"
            }

            self.current = weather_
            self.add(criteria: Weather(rawValue: weather_)!)
            completion()
        }
    }
    
    override func getCriteria() -> [String] {
        var criteriaStrings: [String] = []
        criteria.forEach { c in
            let weatherCriteria = c as! Weather
            criteriaStrings.append(weatherCriteria.rawValue)
        }
        return criteriaStrings
    }
    
    override func getAllValues() -> [Criteria] {
        return Weather.allValues
    }
    
    override func getRawValue(criterion: Criteria) -> String {
        let weatherCriterion = criterion as! Weather
        return weatherCriterion.rawValue
    }
    
    override func getIdentifier() -> String {
        return "weather"
    }
    
    override func getStringValue() -> String {
        return "Weather"
    }
    
    override func hasCurrentValues() -> Bool {
        return true
    }
}

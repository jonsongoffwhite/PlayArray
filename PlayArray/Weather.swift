//
//  Weather.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

/// Represents all possible options for weather
public enum Weather: Criteria {
    case Sunny
    case Raining
    case Overcast
    case Snow
    case Windy
}

// Category for weather
class WeatherCategory: Category {
    
    /// Get the current weather for the user's location using some API
    override func getData() {
        
    }
}

//
//  TimeOfDay.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

// Represents all options of time of day
public enum TimeOfDay: String, Criteria {
    case dawn = "dawn"
    case morning = "morning"
    case afternoon = "afternoon"
    case dusk = "dusk"
    case night = "night"
    case midnight = "midnight"
    
    static let allValues = [TimeOfDay.dawn, TimeOfDay.morning, TimeOfDay.afternoon, TimeOfDay.dusk, TimeOfDay.night, TimeOfDay.midnight]
    
    init(from hour: Int) {
        if hour < 5 { self = .midnight }
        else if hour < 7 { self = .dawn }
        else if hour < 12 { self = .morning }
        else if hour < 18 { self = .afternoon }
        else if hour < 21 { self = .dusk }
        else if hour < 24 { self = .night }
        else { self = .night }
    }
}

// Category for time of day
class TimeOfDayCategory: Category {
    
    override func getData(completion: @escaping () -> Void) {
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let time = TimeOfDay(from: hour)
        current = time.rawValue
        self.add(criteria: time)
        completion()
    }
    
    override func getCriteria() -> [String] {
        var criteriaStrings: [String] = []
        criteria.forEach { c in
            let timeCriteria = c as! TimeOfDay
            criteriaStrings.append(timeCriteria.rawValue)
        }
        return criteriaStrings
    }
    
    override func getAllValues() -> [Criteria] {
        return TimeOfDay.allValues
    }
    
    override func getRawValue(criterion: Criteria) -> String {
        let timeCriterion = criterion as! TimeOfDay
        return timeCriterion.rawValue
    }
    
    override func getIdentifier() -> String {
        return "local_time"
    }
    
    override func getStringValue() -> String {
        return "Time"
    }
    
    override func hasCurrentValues() -> Bool {
        return true
    }
    
}

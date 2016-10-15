//
//  TimeOfDay.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

// Represents all options of time of day
enum TimeOfDay: Criteria {
    case dawn
    case morning
    case afternoon
    case evening
    case dusk
    case night
    case lateNight
    
    init(from hour: Int) {
        if hour < 2 { self = .night }
        else if hour < 5 { self = .lateNight }
        else if hour < 7 { self = .dawn }
        else if hour < 12 { self = .morning }
        else if hour < 18 { self = .afternoon }
        else if hour < 21 { self = .evening }
        else if hour < 23 { self = .dusk }
        else { self = .night }
    }
    
}

// Category for time of day
class TimeOfDayCategory: Category {
    
    override func getData() {

        let date = NSDate()
        let calendar = NSCalendar.current
        
        let hour = calendar.component(.hour, from: date as Date)
        
        criteria.append(TimeOfDay(from: hour))
        
    }
    
}

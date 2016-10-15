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
    case Dawn
    case Morning
    case Day
    case Evening
    case Dusk
    case Night
    case LateNight
}

// Category for time of day
class TimeOfDayCategory: Category {
}

//
//  Criteria.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import CoreLocation

public protocol Criteria {}

class Category {
    var criteria: [Criteria] = []
    
    func add(criteria criterion: Criteria) {
        criteria.append(criterion)
    }
    
    public func getData(completion: @escaping () -> Void) {
        preconditionFailure("This method must be overridden")
    }
}

class LocationCategory: Category {
    
    let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
    }
    
}



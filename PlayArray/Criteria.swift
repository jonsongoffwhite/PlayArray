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
    internal var criteria: [Criteria] = []
    
    func add(criteria criterion: Criteria) {
        criteria.append(criterion)
    }
    
    func getCriteria() -> [String] {
        preconditionFailure("This method must be overridden")
    }
    
    func getAllValues() -> [Criteria] {
        preconditionFailure("This method must be overridden")
    }
    
    func getAllStringValues() -> [String] {
        preconditionFailure("This method must be overridden")
    }
    
    func getRawValue(criterion: Criteria) -> String {
        preconditionFailure("This method must be overridden")
    }
    
    func getData(completion: @escaping () -> Void) {
        preconditionFailure("This method must be overridden")
    }
    
    func getIdentifier() -> String {
        preconditionFailure("This method must be overridden")
    }
    
    func getStringValue() -> String {
        preconditionFailure("This method must be overriden")
    }
    
}

class LocationCategory: Category {
    
    let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
    }
    
    override func getIdentifier() -> String {
        return "location"
    }
    
}



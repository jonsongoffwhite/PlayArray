//
//  Criteria.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

protocol Criteria {}

class Category {
    var criteria: [Criteria] = []
    
    init () {
        getData()
    }
    
    func addCriteria(criterion: Criteria) {
        criteria.append(criterion)
    }
    
    func getData() {
        preconditionFailure("This method must be overridden")
    }
    
}

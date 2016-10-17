//
//  DataQuery.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

// Object that represents all the information in a query to the server.
// It stores a list of each of the things the user has chosen to narrow down their
// search for a playlist.
class DataQuery {
    
    // List of all categories to be queried
    var categories: [Category] = []
    
    // Add a category to the request
    func addCategory(category: Category) {
        categories.append(category)
    }
}

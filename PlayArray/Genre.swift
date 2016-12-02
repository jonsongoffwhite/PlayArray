//
//  Genre.swift
//  PlayArray
//
//  Created by Jono Muller on 10/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

public enum Genre: String, Criteria {
    case alternative = "alternative"
    case ambient = "ambient"
    case blues = "blues"
    case christianHymn = "christian hymn"
    case classical = "classical"
    case country = "country"
    case electronic = "electronic"
    case folk = "folk"
    case hipHop = "hip hop"
    case indie = "indie"
    case instrumental = "instrumental"
    case international = "international"
    case jazz = "jazz"
    case neo = "neo"
    case newAge = "new age"
    case pop = "pop"
    case rap = "rap"
    case reggae = "reggae"
    case rock = "rock"
    case soundtracks = "soundtracks"
    
    static let allValues: [Genre] = [.alternative, .ambient, .blues, .christianHymn, .classical, .country,
                                     .electronic, .folk, .hipHop, .indie, instrumental, .international, .jazz,
                                     .neo, .newAge, .pop, .rap, .reggae, .rock, .soundtracks]
}

class GenreCategory: Category {
    override func getData(completion: @escaping () -> Void) {
        let genre = Genre.alternative
        current = genre.rawValue
        self.add(criteria: genre)
        completion()
    }
    
    override func getCriteria() -> [String] {
        var criteriaStrings: [String] = []
        criteria.forEach { c in
            let genreCriteria = c as! Genre
            criteriaStrings.append(genreCriteria.rawValue)
        }
        return criteriaStrings
    }
    
    override func getAllValues() -> [Criteria] {
        return Genre.allValues
    }
    
    override func getRawValue(criterion: Criteria) -> String {
        let genreCriterion = criterion as! Genre
        return genreCriterion.rawValue
    }
    
    override func getIdentifier() -> String {
        return "genre"
    }
    
    override func getStringValue() -> String {
        return "Genre"
    }
    
    override func hasCurrentValues() -> Bool {
        return false
    }
}




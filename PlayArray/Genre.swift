//
//  Genre.swift
//  PlayArray
//
//  Created by Jono Muller on 10/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

public enum Genre: String, Criteria {
    case rock = "rock"
    case country = "country"
    case indie = "indie"
    case reggae = "reggae"
    case pop = "pop"
    case christianHymn = "christian hymn"
    case alternative = "alternative"
    case soundtracks = "soundtracks"
    case hipHop = "hip hop"
    case electronic = "electronic"
    case newAge = "new age"
    case neo = "neo"
    case classical = "classical"
    case blues = "blues"
    case international = "international"
    case rap = "rap"
    case jazz = "jazz"
    case ambient = "ambient"
    case instrumental = "instrumental"
    case folk = "folk"
    
    static let allValues = [Genre.rock, Genre.country, Genre.indie, Genre.reggae, Genre.pop, Genre.christianHymn, Genre.alternative, Genre.soundtracks, Genre.hipHop, Genre.electronic, Genre.newAge, Genre.neo, Genre.classical, Genre.blues, Genre.international, Genre.rap, Genre.jazz, Genre.ambient, Genre.instrumental, Genre.folk]
}

class GenreCategory: Category {
    override func getData(completion: @escaping () -> Void) {
        let rock = Genre.rock
        current = rock.rawValue
        self.add(criteria: rock)
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




//
//  Playlist.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 21/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import CoreData

/// Contains information describing a playlist
class Playlist {
    var name: String
    var songs: [Song] = []
    var spotifyURI: String?
    
    init(name: String, songs: [Song]) {
        self.name = name
        self.songs = songs
    }
}

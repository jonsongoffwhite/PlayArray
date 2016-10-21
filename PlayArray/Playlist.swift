//
//  Playlist.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 21/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

/// Contains information describing a playlist
// Contains playlist name and a list of songs
class Playlist {
    var name: String
    var songs: [Song]
    
    init(name: String, songs: [Song]) {
        self.name = name
        self.songs = songs
    }
}

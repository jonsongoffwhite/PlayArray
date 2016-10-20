//
//  Song.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

/// Contains information describing a song
// Will eventually need to contain links to be used by Spotify etc.
public struct Song {
    
    var name: String
    var artist: String
    var album: String
    
}


/// Contains information describing a playlist
// Contains playlist name and a list of songs
public struct Playlist {
    
    var name: String
    var songs: [Song]
    
}

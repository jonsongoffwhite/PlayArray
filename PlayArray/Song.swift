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
public class Song {
    let title: String
    let artist: String
    let album: String
    
    init(title: String, artist: String, album: String) {
        self.title = title
        self.artist = artist
        self.album = album
    }
}


/// Contains information describing a playlist
// Contains playlist name and a list of songs
public class Playlist {
    var name: String
    var songs: [Song]
    
    init(name: String, songs: [Song]) {
        self.name = name
        self.songs = songs
    }
}

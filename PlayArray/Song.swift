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
class Song {

    let id: String
    let spotifyId: String
    let title: String
    let artist: String
    let album: String
    
    init(id: String, spotifyId: String, title: String, artist: String, album: String) {
        self.id = id
        self.spotifyId = spotifyId
        self.title = title
        self.artist = artist
        self.album = album
    }
}

//
//  PlaylistManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 21/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import RequestManager
import SwiftyJSON

class PlaylistManager {
    /// Request is PlaylistManager's reference to the RequestManager, used to create calls to the API
    private static var Request: RequestProtocol = RequestManager.sharedInstance

    static func getPlaylist(from time: TimeOfDay, completion: @escaping (Playlist, NSError?) -> Void) {
        Request.getPlaylistFromTime(from: time.stringValue) { (json, error) in
            let playlist = parsePlaylist(from: json)
            completion(playlist, nil)
        }
    }
    
    static func getPlaylist(from weather: Weather, completion: @escaping (Playlist, NSError?) -> Void) {
        Request.getPlaylistFromWeather(from: weather.rawValue) { (json, error) in
        }
    }
    
    /**
        OUTDATED DOCUMENTATION
        Returns a list of songs from JSON representing the songs
     
        - Parameters:
            - json: The JSON (from the server) containing information about the songs
        - Returns:
            A list of Song, to be used by PlayArray
     */
    static func parsePlaylist(from json: JSON) -> Playlist {
        var songs_: [Song] = []
        let songs = json["songs"].arrayValue
        
        songs.forEach { songJSON in
            let title = songJSON["title"].stringValue
            let artist = songJSON["artist"].stringValue
            let album = songJSON["album"].stringValue
            songs_.append(Song(title: title, artist: artist, album: album))
        }
        
        return Playlist(name: "Test Playlist Name", songs: songs_)
    }
}

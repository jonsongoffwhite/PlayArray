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

    static func getPlaylist(from categories: [Category], completion: @escaping (Playlist, NSError?) -> Void) {
        let dictionary = getDictionary(from: categories)
        Request.getPlaylist(from: dictionary) { (json, error) in
            let playlist = parsePlaylist(from: json)
            completion(playlist, nil)
        }
    }
    
    static func getDictionary(from categories: [Category]) -> [(String, String)] {
        var dictionary: [(String, String)] = []
        
        categories.forEach { category in
            let id = category.getIdentifier()
            let criteria: [String] = category.getCriteria()
            criteria.forEach({ c in
                let noSpaces = c.replacingOccurrences(of: " ", with: "%20")
                dictionary.append((id, noSpaces))
            })   
        }
        
        return dictionary
    }
    
    /**
        Parses the servers JSON into a Playlist
     
        - Parameters:
            - json: The JSON (from the server) containing information about the playlist
        - Returns:
            The Playlist object containing the server's passed playlist
     */
    static func parsePlaylist(from json: JSON) -> Playlist {
        var songs_: [Song] = []
        let songs = json["songs"].arrayValue
        
        songs.forEach { songJSON in
            let id = songJSON["_id"].stringValue
            let spotifyId = songJSON["spotify_id"].stringValue
            let title = songJSON["title"].stringValue
            let artist = songJSON["artist"].stringValue
            let album = songJSON["album"].stringValue
            songs_.append(Song(id: id, spotifyId: spotifyId, title: title, artist: artist, album: album))
        }
        
        return Playlist(name: "Test Playlist Name", songs: songs_)
    }
}

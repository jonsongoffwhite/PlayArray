//
//  DataManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 08/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    private static let PLAYLIST_ENTITY: String = "SpotifyPlaylist"
    private static let TRACK_ENTITY: String = "SpotifyTrack"
    private static let URI_KEY: String = "uri"
    private static let PLAYLIST_TO_TRACK_RELATION = "hasTrack"
    private static let TRACK_TO_PLAYLIST_RELATION = "inPlaylist"
    
    /* Note: This function checks whether a playlist with the same URI is stored on the phone. This is
       relevant to when we have got a playlist from Spotify and are checking against our stored playlists.
       It will update songs and note any tracks that require user feedback. 
       However clicking 'Open in Spotify' multiple times in a row will not notice the _same_ playlist, as
       the Spotify call is made first and we receive a new URI as a new playlist is made on Spotify. 
       It might be fixable by storing (somewhere) an `exportedToSpotify` boolean, which we can then disable the
       Open in Spotify (or check in the function) with. */
    static func savePlaylist(_ uri: String, tracks: [String]) throws {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: PLAYLIST_ENTITY, in: context)
        var playlist: NSManagedObject?
        
        // Check if playlist already exists
        let playlistFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PLAYLIST_ENTITY)
        playlistFetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", uri) // Note: Could probably refactor out `playlistExists` and `trackExists`
        let playlistFetchResults = try context.fetch(playlistFetchRequest)
        playlist = playlistFetchResults.first as? NSManagedObject
        
        if playlist != nil {
            print("Found playlist (\(uri))")
            
            var deletedTracks: [String] = []
            // var newTracks: [String] = tracks
            
            // Populate deleted tracks
            let storedTracks = playlist?.value(forKey: PLAYLIST_TO_TRACK_RELATION) as! [NSManagedObject]
            storedTracks.forEach({ storedTrack in
                let storedURI = storedTrack.value(forKey: URI_KEY) as! String
                if !tracks.contains(storedURI) {
                    deletedTracks.append(storedURI)
                }
            })
            
            // Populate new tracks - will be necessary only for API learning
            /*
            newTracks.append(contentsOf: deletedTracks)
            storedTracks.forEach({ storedTrack in
                if let index = newTracks.index(of: storedTrack) {
                    newTracks.remove(at: index)
                }
            })
             */
            
            // Check deleted tracks and ask for feedback
            
        } else {
            // If it doesn't exists create the object and save tracks to it
            print("Creating new playlist (\(uri))")
            playlist = NSManagedObject(entity: entity!, insertInto: context)
            playlist!.setValue(uri, forKey: URI_KEY)
        }
        
        save(tracks: tracks, context: context, into: playlist!, playlistURI: uri)
    
        try context.save()
        print("Playlist (\(uri)) saved to phone")
    }
    
    static func save(tracks URIs: [String], context: NSManagedObjectContext, into playlist: NSManagedObject, playlistURI: String) {
        let entity = NSEntityDescription.entity(forEntityName: TRACK_ENTITY, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TRACK_ENTITY)
        URIs.forEach { uri in
            fetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", uri)
            do {
                let fetchResults = try context.fetch(fetchRequest)
                var track: NSManagedObject? = fetchResults.first as? NSManagedObject
                if track == nil {
                    track = NSManagedObject(entity: entity!, insertInto: context)
                    track!.setValue(uri, forKey: URI_KEY)
                    print("Saved new track with URI: \(uri)")
                } else {
                    print("Found track with URI: \(uri)")
                }
                
                let playlists = track!.mutableSetValue(forKey: TRACK_TO_PLAYLIST_RELATION)
                playlists.add(playlist)
                
                let tracks = playlist.mutableSetValue(forKey: PLAYLIST_TO_TRACK_RELATION)
                tracks.add(track!)
            } catch {
                print(error)
            }
        }
    }
    
    static func getTrackURIs(for playlistURI: String) -> [String] {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PLAYLIST_ENTITY)
        fetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", playlistURI)
        
        var uris: [String] = []
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count == 0 { return [] }
            
            let playlist = fetchResults.first as! NSManagedObject
            let trackRelation = playlist.mutableSetValue(forKey: PLAYLIST_TO_TRACK_RELATION)
            trackRelation.forEach({ track_ in
                let track = track_ as! NSManagedObject
                uris.append(track.value(forKey: URI_KEY) as! String)
            })
        } catch {
            print(error)
        }
        
        return uris
    }
}

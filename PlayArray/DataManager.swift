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
    private static let CRITERIA_ENTITY: String = "Criteria"
    private static let PLAYLIST_TO_TRACK_RELATION = "hasTrack"
    private static let PLAYLIST_TO_CRITERIA_RELATION = "hasCriteria"
    private static let TRACK_TO_PLAYLIST_RELATION = "inPlaylist"
    private static let CRITERIA_TO_PLAYLIST_RELATION = "definesPlaylist"
    
    // Now that we are storing all data, it's better to refactor our Playlist and Song
    // objects in NSManagedObject subclasses as opposed to dealing with the NSManagedObjects
    // and their keys.
    private static let URI_KEY: String = "uri"
    private static let NAME_KEY: String = "name"
    private static let TITLE_KEY: String = "title"
    private static let ARTIST_KEY: String = "artist"
    private static let ALBUM_KEY: String = "album"
    private static let TYPE_KEY: String = "type"
    private static let VALUE_KEY: String = "value"
    
    /* Note: This function checks whether a playlist with the same URI is stored on the phone. This is
       relevant to when we have got a playlist from Spotify and are checking against our stored playlists.
       It will update songs and note any tracks that require user feedback. 
       However clicking 'Open in Spotify' multiple times in a row will not notice the _same_ playlist, as
       the Spotify call is made first and we receive a new URI as a new playlist is made on Spotify. 
       It might be fixable by storing (somewhere) an `exportedToSpotify` boolean, which we can then disable the
       Open in Spotify (or check in the function) with. */
    static func save(playlist: Playlist, songs: [Song], createNew: Bool, completion: (([Song]) -> Void)) throws {
        // Get playlist URI, return if it is nil as we have no way of saving the playlist
        let uri = playlist.spotifyURI
        guard let _ = uri else {
            return
        }
        
        let tracks = SpotifyManager.getSpotifyIds(from: songs)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: PLAYLIST_ENTITY, in: context)
        var managedPlaylist: NSManagedObject?
        
        // Check if playlist already exists
        let playlistFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PLAYLIST_ENTITY)
        playlistFetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", uri!) // Note: Could probably refactor out `playlistExists` and `trackExists`
        let playlistFetchResults = try context.fetch(playlistFetchRequest)
        managedPlaylist = playlistFetchResults.first as? NSManagedObject
        
        if managedPlaylist != nil {
            print("Found existing playlist (\(uri))")
            
            var deletedTracks: [Song] = []
            // var newTracks: [String] = tracks
            
            // Populate deleted tracks
            let storedTrackObjects = managedPlaylist?.value(forKey: PLAYLIST_TO_TRACK_RELATION) as! NSMutableSet
            var storedTracks = NSMutableArray(array: storedTrackObjects.allObjects) as! [NSManagedObject] // This doesn't fail

            storedTracks.forEach({ storedTrack in
                let storedURI = storedTrack.value(forKey: URI_KEY) as! String
                if !tracks.contains(storedURI) {
                    let title = storedTrack.value(forKey: TITLE_KEY) as! String
                    let artist = storedTrack.value(forKey: ARTIST_KEY) as! String
                    let album = storedTrack.value(forKey: ALBUM_KEY) as! String
                    let deletedTrack = Song(id: "", spotifyId: storedURI, title: title, artist: artist, album: album)
                    deletedTracks.append(deletedTrack)
                    
                    // Remove deleted track from stored tracks
                    storedTracks.remove(at: storedTracks.index(of: storedTrack)!)
                }
            })

            // Update stored tracks, removing any deleted tracks
            managedPlaylist?.setValue(NSMutableSet(array: storedTracks), forKey: PLAYLIST_TO_TRACK_RELATION)
            
            // Populate new tracks - will be necessary only for API learning
            /*
            newTracks.append(contentsOf: deletedTracks)
            storedTracks.forEach({ storedTrack in
                if let index = newTracks.index(of: storedTrack) {
                    newTracks.remove(at: index)
                }
            })
             */
            
            // Deal with deleted tracks
            // Show option to review deleted tracks on SelectViewController
            if deletedTracks.count > 0 {
                print("Found \(deletedTracks.count) deleted tracks for \(playlist.spotifyURI)")
                
                completion(deletedTracks)
                // Pass the deleted tracks to the SelectViewController
                //NotificationCenter.default.post(name: Notification.Name(feedbackKey), object: deletedTracks)
                
            }
        } else if createNew {
            // If it doesn't exists create the object and save tracks to it
            print("Creating new playlist (\(uri!))")
            managedPlaylist = NSManagedObject(entity: entity!, insertInto: context)
            managedPlaylist!.setValue(uri, forKey: URI_KEY)
        } else {
            print("Playlist not saved")
            return
        }
        
        managedPlaylist!.setValue(playlist.name, forKey: NAME_KEY)
        
        do {
            try save(songs: songs, context: context, into: managedPlaylist!)
            try save(criteria: criteria, context: context, into: managedPlaylist!)
        } catch {
            print("Error saving playlist data: \(error)")
        }
    
        try context.save()
        print("Playlist (\(uri!)) saved to phone")
    }
    
    static func save(songs: [Song], context: NSManagedObjectContext, into playlist: NSManagedObject) throws {
        let entity = NSEntityDescription.entity(forEntityName: TRACK_ENTITY, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TRACK_ENTITY)
        for song in songs {
            let uri = song.spotifyId
            if uri == "Null" { continue } // Skip song if ID is Null. Will be fixed when server no longer contains these IDs
            
            fetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", uri)
            let results = try context.fetch(fetchRequest)
            var track: NSManagedObject? = results.first as? NSManagedObject
            if track == nil {
                track = NSManagedObject(entity: entity!, insertInto: context)
                track!.setValue(uri, forKey: URI_KEY)
                track!.setValue(song.title, forKey: TITLE_KEY)
                track!.setValue(song.artist, forKey: ARTIST_KEY)
                track!.setValue(song.album, forKey: ALBUM_KEY)
                print("Saved new track with URI: \(uri)")
            } else {
                print("Found track with URI: \(uri)")
            }
            
            let playlists = track!.mutableSetValue(forKey: TRACK_TO_PLAYLIST_RELATION)
            playlists.add(playlist)
            
            let tracks = playlist.mutableSetValue(forKey: PLAYLIST_TO_TRACK_RELATION)
            tracks.add(track!)
        }
    }
    
    static func save(criteria: [Category], context: NSManagedObjectContext, into playlist: NSManagedObject) throws {
        for category in criteria {
            let type = category.getIdentifier()
            let criteria_ = category.getCriteria()
            let value = criteria_.first!
            let entity = NSEntityDescription.entity(forEntityName: CRITERIA_ENTITY, in: context)
            let managedCriteria = NSManagedObject(entity: entity!, insertInto: context)
            managedCriteria.setValue(type, forKey: TYPE_KEY)
            managedCriteria.setValue(value, forKey: VALUE_KEY)
            
            let playlistsCriteria: NSMutableSet? = playlist.value(forKey: PLAYLIST_TO_CRITERIA_RELATION) as? NSMutableSet
            playlistsCriteria!.add(managedCriteria)
            
            let criteriaPlaylists: NSMutableSet? = managedCriteria.value(forKey: CRITERIA_TO_PLAYLIST_RELATION) as? NSMutableSet
            criteriaPlaylists!.add(playlist)

            print("Saved \(type) criteria with value \(value)")
        }
    }
    
    static func getTrackURIs(for playlistURI: String) -> [String] {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PLAYLIST_ENTITY)
        fetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", playlistURI)
        
        var uris: [String] = []
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count == 0 { return [] }
            
            let playlist = results.first as! NSManagedObject
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
    
    static func getPlaylists() throws -> [Playlist] {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PLAYLIST_ENTITY)

        var playlists: [Playlist] = []
        let results = try context.fetch(fetchRequest) as! [NSManagedObject]
        for result in results {
            let name = result.value(forKey: NAME_KEY) as! String
            let spotifyId = result.value(forKey: URI_KEY) as! String
            let trackURIs = getTrackURIs(for: spotifyId)
            
            var songs: [Song] = []
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TRACK_ENTITY)
            for uri in trackURIs {
                fetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", uri)
                let trackEntries = try context.fetch(fetchRequest) as! [NSManagedObject]
                let trackEntry = trackEntries.first
                if trackEntry == nil { continue }
                
                let title = trackEntry!.value(forKey: TITLE_KEY) as! String
                let artist = trackEntry!.value(forKey: ARTIST_KEY) as! String
                let album = trackEntry!.value(forKey: ALBUM_KEY) as! String
                
                // ID has been left out here. With the new database, we probably won't have a database ID
                // but instead work solely with Spotify IDs
                songs.append(Song(id: "", spotifyId: uri, title: title, artist: artist, album: album))
            }
            
            playlists.append(Playlist(name: name, songs: songs))
        }
        
        playlists.reverse()
        return playlists
    }
    
    static func getCriteria(for playlist: Playlist) throws -> [String: String] {
        let uri = playlist.spotifyURI
        
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PLAYLIST_ENTITY)
        fetchRequest.predicate = NSPredicate(format: "\(URI_KEY) == %@", uri!)
        
        let results = try context.fetch(fetchRequest) as! [NSManagedObject]
        let storedPlaylist = results.first
        if storedPlaylist == nil { return [:] }
        
        let criteria: NSMutableSet? = storedPlaylist!.value(forKey: PLAYLIST_TO_CRITERIA_RELATION) as? NSMutableSet
        if criteria == nil { return [:] }
        
        var storedCriteria: [String: String] = [:]
        for criteria_ in criteria! {
            let managedCriteria = criteria_ as! NSManagedObject
            
            let type = managedCriteria.value(forKey: TYPE_KEY) as! String
            let value = managedCriteria.value(forKey: VALUE_KEY) as! String
            
            storedCriteria[type] = value
        }
        
        return storedCriteria
    }
}

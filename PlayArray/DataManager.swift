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
    static func savePlaylist(_ uri: String, tracks: [String]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "SpotifyPlaylist", in: context)
        let playlist = NSManagedObject(entity: entity!, insertInto: context)
        
        playlist.setValue(uri, forKey: "uri")
        save(tracks: tracks, context: context, into: playlist, playlistURI: uri)
        
        do {
            try context.save()
            print("Playlist (\(uri)) saved to phone")
        } catch {
            print("Error saving playlist to phone: \(error)")
        }
    }
    
    static func save(tracks URIs: [String], context: NSManagedObjectContext, into playlist: NSManagedObject, playlistURI: String) {
        let entity = NSEntityDescription.entity(forEntityName: "SpotifyTrack", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SpotifyTrack")
        URIs.forEach { uri in
            fetchRequest.predicate = NSPredicate(format: "uri == %@", uri)
            do {
                let fetchResults = try context.fetch(fetchRequest)
                var track: NSManagedObject? = fetchResults.first as? NSManagedObject
                if track == nil {
                    track = NSManagedObject(entity: entity!, insertInto: context)
                    track!.setValue(uri, forKey: "uri")
                    print("Saved new track with URI: \(uri)")
                } else {
                    print("Found track with URI: \(uri)")
                }
                
                let playlists = track!.mutableSetValue(forKey: "inPlaylist")
                playlists.add(playlist)
                
                let tracks = playlist.mutableSetValue(forKey: "hasTrack")
                tracks.add(track!)
            } catch {
                print(error)
            }
        }
        
        print("Track URIS for playlist \(playlistURI)")
        print(getTrackURIs(for: playlistURI))
    }
    
    static func getTrackURIs(for playlistURI: String) -> [String] {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SpotifyPlaylist")
        fetchRequest.predicate = NSPredicate(format: "uri == %@", playlistURI)
        
        var uris: [String] = []
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count == 0 { return [] }
            
            let playlist = fetchResults.first as! NSManagedObject
            let trackRelation = playlist.mutableSetValue(forKey: "hasTrack")
            trackRelation.forEach({ track_ in
                let track = track_ as! NSManagedObject
                uris.append(track.value(forKey: "uri") as! String)
            })
        } catch {
            print(error)
        }
        
        return uris
    }
}

//
//  SpotifyManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 03/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

let sessionKey = "sessionData"

class SpotifyManager {
    static let clientID = "ab0607417c0c4a13bb87262583255500"
    static let redirectURL = "playarray://spotify/callback"
    static let scopes = ["playlist-modify-private", "playlist-read-private", "playlist-modify-public"]
    
    let auth = SPTAuth.defaultInstance()
    var session: SPTSession?
    
    func login(completion: @escaping () -> Void) {
        auth?.clientID = SpotifyManager.clientID
        auth?.redirectURL = URL(string: SpotifyManager.redirectURL)
        auth?.requestedScopes = SpotifyManager.scopes
        
        let loginURL = auth?.spotifyWebAuthenticationURL()
        UIApplication.shared.open(loginURL!, options: [:]) { (success) in
            // handle error
            completion()
        }
    }
    
    func isLoggedIn() -> Bool {
        let sessionData = UserDefaults.standard.object(forKey: sessionKey)
        
        if sessionData != nil {
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: sessionData as! Data) as! NSMutableDictionary
            
            session = SPTSession(userName: dictionary.value(forKey: "canonicalUsername") as! String!, accessToken: dictionary.value(forKey: "accessToken") as! String!, encryptedRefreshToken: dictionary.value(forKey: "encryptedRefreshToken") as! String!, expirationDate: dictionary.value(forKey: "expirationDate") as! Date!)
            
            let valid = session?.isValid()
            if valid != nil {
                return valid!
            }
        }
        
        return false
    }
    
    func renewSession(completion: @escaping (Bool) -> Void ) {
        if session == nil {
            completion(false)
        } else {
            auth?.renewSession(session, callback: { (error, session) in
                if error != nil {
                    print("Could not renew session: \(error?.localizedDescription)")
                    completion(false)
                } else {
                    self.storeSession(session: session!)
                    completion(true)
                }
            })
        }
    }
    
    func respondToAuth(url: URL) {
        if(auth?.canHandle(url))! {
            auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if error != nil {
                    print("Could not login: \(error?.localizedDescription)")
                } else {
                    self.storeSession(session: session!)
                    SettingsTableViewController.loggedIn = true
                    NotificationCenter.default.post(name: Notification.Name(sessionKey), object: session)
                }

            })
        }
    }
    
    func storeSession(session: SPTSession) {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(session.canonicalUsername, forKey: "canonicalUsername")
        dictionary.setValue(session.accessToken, forKey: "accessToken")
        dictionary.setValue(session.encryptedRefreshToken, forKey: "encryptedRefreshToken")
        dictionary.setValue(session.expirationDate, forKey: "expirationDate")
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: sessionKey)
        userDefaults.synchronize()
        
        self.session = session
    }
    
    // Currently only gets first 20 playlists. Need to get them all
    func getPlaylists(completion: @escaping ([Playlist]) -> Void) throws {
        let playlistRequest: URLRequest
        playlistRequest = try SPTPlaylistList.createRequestForGettingPlaylists(forUser: session?.canonicalUsername, withAccessToken: session?.accessToken)
        
        Alamofire.request(playlistRequest)
        .response { response in
            do {
                let list = try SPTPlaylistList(from: response.data, with: response.response)
                let results = list.value(forKey: "items") as! [SPTPartialPlaylist]
                
                var playlists: [Playlist] = []
                DispatchQueue.main.async {
                    for playlist in results {
                        let uri = playlist.uri.absoluteString
                        let name = playlist.name
                        if playlist.trackCount > 0 {
                            self.getSpotifySongs(with: uri, completion: { songs in
                                let playlist = Playlist(name: name!, songs: songs)
                                playlist.spotifyURI = SpotifyManager.uriFrom(spotifyURI: uri)
                                playlists.append(playlist)
                            })
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    completion(playlists)
                })
            } catch {
                print(error)
            }
        }
    }
    
    func getSpotifySongs(with playlistURI: String, completion: @escaping ([Song]) -> Void) {
        let uri = URL(string: playlistURI)
        let songsRequest: URLRequest
        do {
            songsRequest = try SPTPlaylistSnapshot.createRequestForPlaylist(withURI: uri, accessToken: session?.accessToken)
        } catch {
            print("Unable to get playlist from URI: \(error)")
            return
        }
        
        var snapshot: SPTPlaylistSnapshot?
        Alamofire.request(songsRequest)
        .response { response in
            do {
                snapshot = try SPTPlaylistSnapshot(from: response.data, with: response.response)
                let tracks = snapshot?.firstTrackPage.items as! [SPTTrack]
                
                var songs: [Song] = []
                
                tracks.forEach({ (track) in
                    let songURI = track.identifier
                    let title = track.name
                    let album = track.album.name
                    let artists = track.artists as! [SPTPartialArtist]
                    let artist = artists.first?.name
                    if songURI != nil {
                        songs.append(Song(id: "", spotifyId: songURI!, title: title!, artist: artist!, album: album!))
                    }
                })
               
                completion(songs)
            } catch {
                print("Unable to make request: \(error)")
            }
        }
    }
    
    func makePlaylist(with songs: [Song], called name: String, completion: @escaping (String) -> Void) {
        let createPlaylistRequest: URLRequest?
        
        do {
            createPlaylistRequest = try SPTPlaylistList.createRequestForCreatingPlaylist(withName:name, forUser: session?.canonicalUsername, withPublicFlag: false, accessToken: session?.accessToken)
        } catch {
            print("Error: \(error)")
            return
        }
        
        Alamofire.request(createPlaylistRequest!)
        .response { response in
            do {
                let playlist: SPTPlaylistSnapshot = try SPTPlaylistSnapshot(from: response.data, with: response.response)
                let uri = SpotifyManager.uriFrom(spotifyURI: playlist.uri.absoluteString)
                completion(uri)
                self.add(songs: songs, to: playlist)
            } catch {
                print("Playlist creation response error: \(error)")
            }
        }
    }
    
    func add(songs: [Song], to playlist: SPTPlaylistSnapshot) {
        let addSongsToPlaylistRequest: URLRequest?
        let tracks = SpotifyManager.getSpotifyURIs(from: songs)
        
        do {
            var tracks: [NSURL] = []
            songs.forEach({ song in
                if song.spotifyId != "Null" {
                    tracks.append(NSURL(string: "spotify:track:\(song.spotifyId)")!)
                }
            })
            
            addSongsToPlaylistRequest = try SPTPlaylistSnapshot.createRequest(forAddingTracks: tracks, toPlaylist: playlist.uri, withAccessToken: session?.accessToken)
        } catch {
            print("Error adding songs to playlist: \(error)")
            return
        }
        
        Alamofire.request(addSongsToPlaylistRequest!)
        .response { response in
                print("Added songs to Spotify playlist")
        }
    }
    
    static func getSpotifyIds(from songs: [Song]) -> [String] {
        var tracks: [String] = []
        songs.forEach({ song in
            tracks.append(song.spotifyId)
        })
        
        return tracks
    }
    
    static func getSpotifyURIs(from songs: [Song]) -> [NSURL] {
        let ids: [String] = getSpotifyIds(from: songs)
        var uris: [NSURL] = []
        ids.forEach { id in
            uris.append(NSURL(string: "spotify:track:\(id)")!)
        }
        
        return uris
    }
    
    static func uriFrom(spotifyURI: String) -> String {
        return spotifyURI.components(separatedBy: ":").last!
    }
    
    // MARK: Singleton
    
    public static let sharedInstance = SpotifyManager()
    
    private init() {
        
    }
}

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

class SpotifyManager {
    static let clientID = "ab0607417c0c4a13bb87262583255500"
    static let redirectURL = "playarray://spotify/callback"
    static let scopes = ["playlist-modify-private"]
    let sessionKey = "sessionData"
    
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
                    print("Could not renew session")
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
                    print("Could not login")
                } else {
                    self.storeSession(session: session!)
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
        userDefaults.set(data, forKey: self.sessionKey)
        userDefaults.synchronize()
        
        self.session = session
    }
    
    func getPlaylists() {
        let playlistRequest: URLRequest
        do {
            playlistRequest = try SPTPlaylistList.createRequestForGettingPlaylists(forUser: session?.canonicalUsername, withAccessToken: session?.accessToken)
        } catch {
            print("error getting playlist: \(error)")
            return
        }
        
        Alamofire.request(playlistRequest)
        .response { response in
            do {
                let list = try SPTPlaylistList(from: response.data, with: response.response)
                let playlists = list.value(forKey: "items") // SPTPartialPlaylist array
            } catch {
                print(error)
            }
        }
    }
    
    func makePlaylist(with songs: [Song], called name: String) {
        let createPlaylistRequest: URLRequest?
        
        print("username: ", session?.canonicalUsername)
        
        do {
            createPlaylistRequest = try SPTPlaylistList.createRequestForCreatingPlaylist(withName:name, forUser: session?.canonicalUsername,
                                                                                         withPublicFlag: false, accessToken: session?.accessToken)
        } catch {
            print("error: \(error)")
            return
        }
        
        Alamofire.request(createPlaylistRequest!)
        .response { response in
            do {
                let playlist = try SPTPlaylistSnapshot(from: response.data, with: response.response)
                self.add(songs: songs, to: playlist)
            } catch {
                print("playlist creation response error: \(error)")
            }
        }
    }
    
    func add(songs: [Song], to playlist: SPTPlaylistSnapshot) {
        let addSongsToPlaylistRequest: URLRequest?
        
        do {
            var tracks: [NSURL] = []
            songs.forEach({ song in
                tracks.append(NSURL(string: "spotify:track:\(song.id)")!)
            })
            
            addSongsToPlaylistRequest = try SPTPlaylistSnapshot.createRequest(forAddingTracks: tracks, toPlaylist: playlist.uri, withAccessToken: session?.accessToken)
        } catch {
            print("error adding songs to playlist: \(error)")
            return
        }
        
        Alamofire.request(addSongsToPlaylistRequest!)
            .response { (response) in
                print("Added \(songs.count) songs to playlist")
        }
    }
    
    // MARK: Singleton
    
    public static let sharedInstance = SpotifyManager()
    
    private init() {
        
    }
}

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
    
    let auth = SPTAuth.defaultInstance()
    var accessToken: String?
    var username: String?
    
    func login() {
        auth?.clientID = SpotifyManager.clientID
        auth?.redirectURL = URL(string: SpotifyManager.redirectURL)
        auth?.requestedScopes = SpotifyManager.scopes
        
        let loginURL = auth?.spotifyWebAuthenticationURL()
        UIApplication.shared.open(loginURL!, options: [:]) { (success) in
            // handle error
        }
    }
    
    func respondToAuth(url: URL) {
        if(auth?.canHandle(url))! {
            auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                self.accessToken = session?.accessToken
                self.username = session?.canonicalUsername
            })
        }
    }
    
    func getPlaylists() {
        let playlistRequest: URLRequest
        do {
            playlistRequest = try SPTPlaylistList.createRequestForGettingPlaylists(forUser: username, withAccessToken: accessToken)
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
        
        do {
            createPlaylistRequest = try SPTPlaylistList.createRequestForCreatingPlaylist(withName:name, forUser: username,
                                                                                         withPublicFlag: false, accessToken: accessToken)
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
            
            addSongsToPlaylistRequest = try SPTPlaylistSnapshot.createRequest(forAddingTracks: tracks, toPlaylist: playlist.uri, withAccessToken: accessToken)
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

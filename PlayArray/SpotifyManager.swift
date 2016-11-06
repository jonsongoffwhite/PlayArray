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
    static let scopes = ["playlist-modify-private", "playlist-read-private", "playlist-modify-public"]
    
    let auth = SPTAuth.defaultInstance()
    var accessToken: String?
    var username: String?
    
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
    
    func getSpotifySongIds(with playlistURI: String, completion: @escaping ([String]) -> Void) {
        let uri = URL(string: playlistURI)
        let songsRequest: URLRequest
        do {
            songsRequest = try SPTPlaylistSnapshot.createRequestForPlaylist(withURI: uri, accessToken: accessToken)
        } catch {
            print("unable to get playlist from URI: \(error)")
            return
        }
        
        var snapshot: SPTPlaylistSnapshot?
        Alamofire.request(songsRequest)
            .response { response in
                do {

                    snapshot = try SPTPlaylistSnapshot(from: response.data, with: response.response)
                    let tracks = snapshot?.firstTrackPage.items as! [SPTTrack]
                    
                    var songIds: [String] = []
                    
                    tracks.forEach({ (track) in
                        songIds.append(track.identifier)
                    })
                   
                    completion(songIds)    
                } catch {
                    print("unable to make request: \(error)")
                }
        }
    }
    
    func makePlaylist(with songs: [Song], called name: String) {
        let createPlaylistRequest: URLRequest?
        
        do {
            createPlaylistRequest = try SPTPlaylistList.createRequestForCreatingPlaylist(withName:name, forUser: username,
                                                                                         withPublicFlag: true, accessToken: accessToken)
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

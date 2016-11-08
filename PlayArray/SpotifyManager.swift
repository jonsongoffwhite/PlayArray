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
    
    // Currently only gets first 20 playlists. Need to get them all
    func getPlaylists(completion: @escaping ([Playlist]) -> Void) throws {
        let playlistRequest: URLRequest
        playlistRequest = try SPTPlaylistList.createRequestForGettingPlaylists(forUser: username, withAccessToken: accessToken)
        
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
                                playlists.append(Playlist(name: name!, songs: songs))
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
            songsRequest = try SPTPlaylistSnapshot.createRequestForPlaylist(withURI: uri, accessToken: accessToken)
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
                    songs.append(Song(id: "", spotifyId: songURI!, title: title!, artist: "", album: album!))
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
            createPlaylistRequest = try SPTPlaylistList.createRequestForCreatingPlaylist(withName:name, forUser: username,
                                                                                         withPublicFlag: true, accessToken: accessToken)
        } catch {
            print("Error: \(error)")
            return
        }
        
        Alamofire.request(createPlaylistRequest!)
        .response { response in
            do {
                let playlist = try SPTPlaylistSnapshot(from: response.data, with: response.response)
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
            addSongsToPlaylistRequest = try SPTPlaylistSnapshot.createRequest(forAddingTracks: tracks, toPlaylist: playlist.uri, withAccessToken: accessToken)
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

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
                
                self.getPlaylists()
            })
        }
    }
    
    func getPlaylists() {
        let playlistRequest: URLRequest
        do {
            playlistRequest = try SPTPlaylistList.createRequestForGettingPlaylists(forUser: username, withAccessToken: accessToken)
        } catch {
            print("fuck off \(error)")
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
    
    // MARK: Singleton
    
    public static let sharedInstance = SpotifyManager()
    
    private init() {
        
    }
}

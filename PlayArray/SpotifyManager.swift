//
//  SpotifyManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 03/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

class SpotifyManager {
    static let clientID = "ab0607417c0c4a13bb87262583255500"
    static let redirectURL = "playarray://spotify/callback" // check if this is the right one
    static let scopes = ["playlist-modify-private"]
    
    let auth = SPTAuth.defaultInstance()
    
    func login() {
        print("spotify logging in")
        
        auth?.clientID = SpotifyManager.clientID
        auth?.redirectURL = URL(string: SpotifyManager.redirectURL)
        auth?.requestedScopes = SpotifyManager.scopes
        
        let loginURL = auth?.spotifyWebAuthenticationURL()
        UIApplication.shared.open(loginURL!, options: [:]) { (success) in
            print("success: \(success)")
        }
    }
    
    func handleAuthCallbackWithTriggeredAuthURL(url: NSURL, callback: SPTAuthCallback) {
        print("got callback")
    }
}

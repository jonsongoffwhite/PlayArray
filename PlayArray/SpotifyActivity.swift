//
//  SpotifyActivity.swift
//  PlayArray
//
//  Created by Jono Muller on 26/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit

class SpotifyActivity: UIActivity {
    
    let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init()
    }
    
    // changes whether it is on the top or bottom row
    override class var activityCategory: UIActivityCategory {
        return .share
    }
    
    override var activityType: UIActivityType? {
        return UIActivityType("PlayArray.activityType.Spotify")
    }
    
    override var activityTitle: String? {
        return "Open in Spotify"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "Spotify_Icon_RGB_Green")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        let spotify = SpotifyManager.sharedInstance
        
        if SettingsTableViewController.loggedIn {
            makePlaylist(spotify: spotify)
        }
    }
    
    override var activityViewController: UIViewController? {
        if !SettingsTableViewController.loggedIn {
            let alert = UIAlertController(title: "Not logged in", message: "Please log in to Spotify in the Settings tab first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            return alert
        }
        
        return nil
    }
    
    func makePlaylist(spotify: SpotifyManager) {
        spotify.makePlaylist(with: playlist.songs, called: self.playlist.name) { uri in
            self.playlist.spotifyURI = SpotifyManager.uriFrom(spotifyURI: uri.absoluteString)
            print(uri)
            spotify.openSpotify(uri: uri)
            //            do {
            // No need for completion handler as we can guarantee a new playlist is being created on Spotify
            //                try DataManager.save(playlist: self.playlist, songs: self.playlist.songs, createNew: true) {_ in }
            //            } catch {
            
            //            }
        }
    }
}

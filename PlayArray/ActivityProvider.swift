//
//  ActivityProvider.swift
//  PlayArray
//
//  Created by Jono Muller on 30/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit

class ActivityProvider: NSObject, UIActivityItemSource {
    
    var uri: URL
    var shareString: String = "Check out this playlist I made using PlayArray: "
    
    init(uri: URL) {
        self.uri = uri
        super.init()
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        let shareTypes = [UIActivityType.message, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.mail]
        let linkTypes = [UIActivityType.airDrop, UIActivityType.copyToPasteboard]
        
//        let spotify = SpotifyManager.sharedInstance
        let webURL = SpotifyManager.webURLFrom(username: (SpotifyManager.sharedInstance.session?.canonicalUsername)!, spotifyURI: SpotifyManager.uriFrom(spotifyURI: uri.absoluteString))
        
        if shareTypes.contains(activityType)  {
//            makePlaylist(spotify: spotify)
            shareString = shareString + webURL
        } else if linkTypes.contains(activityType) {
            shareString = webURL
        }
        
        return shareString
    }

//    func makePlaylist(spotify: SpotifyManager) {
//        spotify.makePlaylist(with: playlist.songs, called: playlist.name, completion: { (uri) in
//            let webURL = SpotifyManager.webURLFrom(username: (SpotifyManager.sharedInstance.session?.canonicalUsername)!, spotifyURI: SpotifyManager.uriFrom(spotifyURI: uri.absoluteString))
//            self.shareString = self.shareString + webURL
//            print(self.shareString)
//        })
//    }
}

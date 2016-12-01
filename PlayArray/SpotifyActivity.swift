//
//  SpotifyActivity.swift
//  PlayArray
//
//  Created by Jono Muller on 26/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit

class SpotifyActivity: UIActivity {
    
    let uri: URL
    
    init(uri: URL) {
        self.uri = uri
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
        SpotifyManager.sharedInstance.openSpotify(uri: uri)
    }
}

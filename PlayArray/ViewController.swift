//
//  ViewController.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let MAKE_PLAYLIST_SEGUE = "makePlaylistSegue"

    var playlist: Playlist?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.requestLocation()
        }
        
        //USE `locationManager.requestLocation() to receive one-time user location data
        
//        playlist = Playlist(name: "Test playlist", songs: [])
        
//        playlist.name = "Test playlist"
//        playlist.songs.append(contentsOf: [Song(title: "May You Never", artist: "Lou Lou", album: "Smokey Folkey"), Song(title: "Test", artist: "Lou", album: "Louis's 1st Album")])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        // Do something with current location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @IBAction func makePlaylist(_ sender: AnyObject) {
        PlaylistManager.getPlaylist(from: .dawn) { (playlist, error) in
            self.playlist = playlist
            // Set destination etc. The prepare function gets called before this callback occurs.
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MAKE_PLAYLIST_SEGUE {
            let dest = segue.destination as! PlaylistTableViewController
            dest.playlist = playlist ?? Playlist(name: "no playlist", songs: [])
        }
    }
}


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
    
    let MAKE_PLAYLIST_SEGUE = "makePlaylistSegue"

    let locationManager = CLLocationManager()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        // Do something with current location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @IBAction func makePlaylistFromTime(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "playlistViewController") as! PlaylistTableViewController
        
        let time = TimeOfDayCategory()
        time.getData {
            let timeEnum = time.criteria.first as! TimeOfDay
            PlaylistManager.getPlaylist(from: timeEnum) { (playlist, error) in
                self.playlist = playlist
                self.playlist!.name = timeEnum.rawValue
                vc.playlist = self.playlist ?? Playlist(name: "no playlist", songs: [])
                self.show(vc, sender: sender)
            }
        }
    }
    
    @IBAction func makePlaylist(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "playlistViewController") as! PlaylistTableViewController
        
        let weather = WeatherCategory(locationManager: locationManager)
        weather.getData {
            let weatherEnum = weather.criteria.first as! Weather
            print("weather: \(weatherEnum)")
            PlaylistManager.getPlaylist(from: weatherEnum) { (playlist, error) in
                self.playlist = playlist
                self.playlist!.name = weatherEnum.rawValue
                vc.playlist = self.playlist ?? Playlist(name: "no playlist", songs: [])
                self.show(vc, sender: sender)
            }
        }
    }

}


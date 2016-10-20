//
//  RequestManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// RequestManager is used by PlayArray to create API calls, including creating and retrieving playlists
public class RequestManager: RequestProtocol {
    
    /// Alamofire SessionManager, which handles request headers
    let manager: Alamofire.SessionManager = SessionManager(configuration: .default)
    
    /** 
        Uses the Alamofire SessionManager to create a request to the server.
        Validates the request, checking the HTTP status code (200..299) and matches the `Accept` header
     
        - Parameters:
            - router: Contains information about the request
        - Returns:
            The servers response, including headers
     */
    func request(_ router: Router) -> DataRequest {
        return manager.request(router).validate()
    }
    
    // MARK: Playlist API Calls
    
    /**
        OUTDATED DOCUMENTATION: This will eventually be a general getPlaylist function. They are only separate for this sprint (hopefully not for too long)
        Creates a GET request for a playlist, passing criteria as a parameter
     
        - Parameters:
            - criteria: The criteria selected by the user, used to choose songs for the playlist
            - completion: Called with the servers response, will contain a list of songs or an error
     */
    
    public func getPlaylist(from time: TimeOfDay, completion: @escaping ([Song], NSError?) -> Void) {
        request(.getPlaylistFromTime(time: time)).responseJSON { response in
            let json = JSON(response.result.value)
            let playlist = self.parsePlaylist(from: json)
            completion(playlist, nil)
        }
    }
    
    public func getPlaylist(from weather: Weather, completion: @escaping ([Song], NSError?) -> Void) {
        request(.getPlaylistFromWeather(weather: weather)).responseJSON { response in
            let json = JSON(response.result.value)
            let playlist = self.parsePlaylist(from: json)
            completion(playlist, nil)
        }
    }
    
    // MARK: Weather API Calls
    
    /// The base URL to look up the weather at the user's current city
    let weatherBaseURL = "http://api.openweathermap.org/data/2.5/weather?APPID=432b38173b0e45e0c0c2c2fd601e95fa"
    
    /**
        Uses Open Weather Map to get the weather at a given location
     
        - Parameters:
            - lat: The user's latitude
            - lon: The user's longitude
            - completion: Returns the Weather enum value and a possible error when the information is got from the weather service
     */
    public func getWeather(_ lat: Double, lon: Double, completion: @escaping (String, NSError?) -> Void) {
        let weatherURLString = weatherBaseURL + "&lat=" + String(format:"%f", lat) + "&lon=" + String(format:"%f", lon)
        let weatherURL = URL(string: weatherURLString)
        Alamofire.request(weatherURL!)
        .response { response in
            let json = JSON(data: response.data!)
            let weather = json["weather"].arrayValue.first
            let mainWeather = weather?["main"].stringValue
            
            completion(mainWeather!, nil)
        }
    }
    
    // MARK: Parsing
    
    /**
        Returns a list of songs from JSON representing the songs
     
        - Parameters:
            - json: The JSON (from the server) containing information about the songs
        - Returns:
            A list of Song, to be used by PlayArray
     */
    func parsePlaylist(from json: JSON) -> [Song] {
        var playlist: [Song] = []
        let songs = json["songs"].arrayValue
        
        songs.forEach { songJSON in
            let title = songJSON["title"].stringValue
            let artist = songJSON["artist"].stringValue
            let album = songJSON["album"].stringValue
            playlist.append(Song(title: title, artist: artist, album: album))
        }
        
        return playlist
    }
    
    // MARK: Singleton
    
    /// The singleton instance of the RequestManager class, referenced in PlayArray 
    public static let sharedInstance = RequestManager()
    
    private init() {
        
    }
}

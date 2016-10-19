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
        Creates a GET request for a playlist, passing criteria as a parameter
     
        - Parameters:
            - criteria: The criteria selected by the user, used to choose songs for the playlist
            - completion: Called with the servers response, will contain a list of songs or an error
     */
    public func getPlaylist(from time: TimeOfDay, completion: @escaping ([Song], NSError?) -> Void) {
        print("getting playlist")
        self.request(.getPlaylist(time: time)).responseJSON { response in
            print("response")
            print(response)
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
    
    // MARK: Singleton
    
    /// The singleton instance of the RequestManager class, referenced in PlayArray 
    public static let sharedInstance = RequestManager()
    
    private init() {
        
    }
}

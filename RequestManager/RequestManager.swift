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
    public func getPlaylist(from criteria: Data, completion: @escaping ([Song], NSError?) -> Void) {
        self.request(.getPlaylist).responseJSON { response in
        }
    }
    
    // MARK: Weather API Calls
    
    /// The base URL to look up the user's current city using latitude and longitude
    let geoLookupBaseURL = "http://api.wunderground.com/api/d0c9667a28371bd1/geolookup/q/"
    /// The base URL to look up the weather at the user's current city
    let weatherBaseURL = "http://api.wunderground.com/api/d0c9667a28371bd1/conditions/q/"
    
    /**
        Uses Wunderground to get the weather at a given location
     
        - Parameters:
            - lat: The user's latitude
            - lon: The user's longitude
            - completion: Returns the Weather enum value and a possible error when the information is got from the Wunderground service
     */
    public func getWeather(_ lat: Double, lon: Double, completion: @escaping (Weather, NSError?) -> Void) {
        let geoLookupURLString = geoLookupBaseURL + String(format:"%f", lat) + "," + String(format:"%f", lon) as String + ".json"
        let geoLookupURL = URL(string: geoLookupURLString)
        Alamofire.request(geoLookupURL!)
        .response { response in
            let json = JSON(data: response.data!)
            let location = json["location"].dictionary!
            let city = location["city"]?.stringValue
            let country = location["country"]?.stringValue
             print(json)
            
            // Get information about the city
            
            let weatherURLString = self.weatherBaseURL + country! + "/" + city! + ".json" // Add information about city
            let weatherURL = URL(string: weatherURLString)
            Alamofire.request(weatherURL!)
                .response { response in
                    let json = JSON(data: response.data!)
//                    print(json)
                    
                    // Convert response into weather enum value
                    
                    completion(.Sunny, nil)
            }
        }
    }
    
    // MARK: Singleton
    
    /// The singleton instance of the RequestManager class, referenced in PlayArray 
    public static let sharedInstance = RequestManager()
    
    private init() {
        
    }
}

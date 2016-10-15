//
//  RequestManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import Alamofire

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
    
    // MARK: API Calls
    
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
    
    // MARK: Singleton
    
    /// The singleton instance of the RequestManager class, referenced in PlayArray 
    public static let sharedInstance = RequestManager()
    
    private init() {
        
    }
}

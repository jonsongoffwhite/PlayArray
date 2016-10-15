//
//  RequestManager.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import Alamofire

class RequestManager: RequestProtocol {
    
    let manager: Alamofire.SessionManager = SessionManager(configuration: .default)
    
    func request(_ router: Router) -> DataRequest {
        return manager.request(router).validate()
    }
    
    func getPlaylist(from request: Data, completion: @escaping () -> ()) {
        self.request(.getPlaylist).responseJSON { response in
        }
    }
    
    // MARK: Singleton
    static let sharedInstance = RequestManager()
    
    private init() {
        
    }
}

//
//  RequestProtocol.swift
//  PlayArray
//
//  Created by Louis de Beaumont on 15/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    // criteria: Data will probably change to a custom class in future
    func getPlaylist(from criteria: Data, completion: @escaping () -> ())
}

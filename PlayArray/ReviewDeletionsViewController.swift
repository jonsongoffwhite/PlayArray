//
//  ReviewDeletionsViewController.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import UIKit

class ReviewDeletionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var alteredSongs: [Song] = []
    
    //TODO:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alteredSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
}

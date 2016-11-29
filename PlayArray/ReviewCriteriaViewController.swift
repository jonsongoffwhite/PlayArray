//
//  ReviewCriteriaViewController.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 29/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import UIKit

class ReviewCriteriaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataSource: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
}

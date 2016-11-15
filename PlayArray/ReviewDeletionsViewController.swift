//
//  ReviewDeletionsViewController.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 15/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import UIKit
import MGSwipeTableCell

class ReviewDeletionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    var alteredSongs: [(Playlist, [Song])] = []
    
    override func viewDidLoad() {
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    //TODO:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alteredSongs.reduce(0, { (r, tuple) -> Int in
            let songs = tuple.1
            return r + songs.count
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "programmaticCell"
        let cell = self.table.dequeueReusableCell(withIdentifier: reuseIdentifier) as! MGSwipeTableCell
        
        let item = getTupleItem(at: indexPath.row)!
        
        cell.textLabel!.text = "\(item.0.name): \(item.1.title) - \(item.1.artist)"
        //cell.detailTextLabel!.text = "Detail text"
        cell.delegate = self //optional
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Not My Thing", backgroundColor: UIColor(red: 0.596, green: 0.761, blue: 0.38, alpha: 1))]
        
        cell.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Not Appropriate", backgroundColor: UIColor(red: 1, green: 0.835, blue: 0, alpha: 1))]
        cell.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        return cell
        
    }
}

extension ReviewDeletionsViewController {

    func getTupleItem(at index: Int) -> (Playlist, Song)? {
        var decounter = index
        var returnValue: (Playlist, Song)?
        alteredSongs.forEach { (tuple) in
            let playlist = tuple.0
            let songs = tuple.1
            
            if decounter - songs.count >= 0 {
                decounter -= songs.count
            } else {
                returnValue = (playlist, songs[decounter])
                return
            }
        }
        return returnValue
    }
    
}

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
    var alteredSongs: [Song] = [Song(id: "song's id", spotifyId: "spotify id", title: "test song", artist: "test artist", album: "test album")]
    
    override func viewDidLoad() {
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    //TODO:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alteredSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "programmaticCell"
        var cell = self.table.dequeueReusableCell(withIdentifier: reuseIdentifier) as! MGSwipeTableCell
        
        cell.textLabel!.text = "Title"
        //cell.detailTextLabel!.text = "Detail text"
        cell.delegate = self //optional
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Not Appropriate", backgroundColor: UIColor.brown)]
        cell.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Not My Thing", backgroundColor: UIColor.blue)]
        cell.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        return cell
        
    }
}

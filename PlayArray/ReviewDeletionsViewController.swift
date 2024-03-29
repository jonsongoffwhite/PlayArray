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
import RequestManager

var alteredSongs: [(Playlist, [Song])] = []
var alteredSongsList: [(Playlist, Song)] = []

class ReviewDeletionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        
        alteredSongs.forEach { (tuple) in
            let playlist = tuple.0
            let songs = tuple.1
            
            songs.forEach({ (song) in
                alteredSongsList.append((playlist, song))
            })
            
        }
        
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.reloadData()
        popView()
    }
    
    func popView() {
        if alteredSongsList.count == 0 {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    //TODO:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alteredSongsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "programmaticCell"
        let cell = self.table.dequeueReusableCell(withIdentifier: reuseIdentifier) as! MGSwipeTableCell
        
        let item = alteredSongsList[indexPath.row]
        
        cell.textLabel!.text = "\(item.1.title) - \(item.1.artist)"
        cell.detailTextLabel!.text = item.0.name
        cell.delegate = self //optional
        
        //configure left buttons
        
        let leftButton = MGSwipeButton(title: "Not My Thing", backgroundColor: UIColor(red: 0.596, green: 0.761, blue: 0.38, alpha: 1))
        leftButton.callback = { (sender: MGSwipeTableCell!) -> Bool in
            
            alteredSongsList.remove(at: indexPath.row)
            self.table.reloadData()
            self.popView()
//            self.table.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            
            return true
        }
        
        cell.leftButtons = [leftButton]
        
        cell.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        //configure right buttons
        
        let rightButton = MGSwipeButton(title: "Not Appropriate", backgroundColor: UIColor(red: 1, green: 0.835, blue: 0, alpha: 1))
        
        rightButton.callback = { (sender: MGSwipeTableCell) -> Bool in
        
            // if there are more than one criteria associated with song, bring up selection
            // and send feedback for chosen criteria
            // else send feedback for just the one
            
            do {
                let criteria = try DataManager.getCriteria(for: item.0)
                
                
                if criteria.count > 1 {
                    
                    // Create a ReviewCriteriaViewController
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "reviewCriteriaViewController") as! ReviewCriteriaViewController
                    
                    vc.dataSource = Array(criteria.values)
                    vc.categories = Array(criteria.keys)
                    vc.songId = item.1.id
                    vc.selectedIndexPath = indexPath.row
                    print("row: \(indexPath.row)")
                    vc.delegate = self
                    
                    self.show(vc, sender: self)
                
                } else {
                    RequestManager.sharedInstance.giveFeedback(for: item.1.id, with: criteria, completion: { (error) in
                        print("deleting \(item.1.title)")
                        print("inappropriate for: ")
                        criteria.forEach({ (key: String, value: String) in
                            print("\(key) : \(value)")
                        })
                        
                        
                        alteredSongsList.remove(at: indexPath.row)
                        self.table.reloadData()
                        self.popView()
//                        self.table.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
                    })
                }
            } catch {
                print("error getting playlist criteria")
            }
            return true
        }
        
        cell.rightButtons = [rightButton]
        cell.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        return cell
        
    }
}

extension ReviewDeletionsViewController: CriteriaFeedbackDelegate {
    
    func giveFeedback(songId: String, criteria: [String : String]) {
        
        RequestManager.sharedInstance.giveFeedback(for: songId, with: criteria) { (error) in
            
            print("deleting \(songId)")
            print("inappropriate for: ")
            criteria.forEach({ (key: String, value: String) in
                print("\(key) : \(value)")
            })
            
        }
    }
    
}


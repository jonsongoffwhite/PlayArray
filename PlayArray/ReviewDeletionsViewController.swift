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

class ReviewDeletionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    var alteredSongs: [(Playlist, [Song])] = []
    var alteredSongsList: [(Playlist, Song)] = []
    
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
    
    //TODO:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alteredSongsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "programmaticCell"
        let cell = self.table.dequeueReusableCell(withIdentifier: reuseIdentifier) as! MGSwipeTableCell
        
        let item = alteredSongsList[indexPath.row]
        
        cell.textLabel!.text = "\(item.0.name): \(item.1.title) - \(item.1.artist)"
        //cell.detailTextLabel!.text = "Detail text"
        cell.delegate = self //optional
        
        //configure left buttons
        
        let leftButton = MGSwipeButton(title: "Not My Thing", backgroundColor: UIColor(red: 0.596, green: 0.761, blue: 0.38, alpha: 1))
        leftButton.callback = { (sender: MGSwipeTableCell!) -> Bool in
            
            self.alteredSongsList.remove(at: indexPath.row)
            
            self.table.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            
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
                    
                    // Create a UIAlertController
                    
                    let title = "Criteria"
                    let message = "Please select the criteria that you felt did not apply to this song: "
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                    
                    let margin:CGFloat = 8.0
                    let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 100)
                    
                    var tableView = UITableView(frame: rect)
                    
                    class AlertTableController: NSObject, UITableViewDelegate, UITableViewDataSource {
                        
                        let dataDictionary: [String: String]
                        var dataSource: [(String, String)]
                        
                        
                        init(with dataDictionary: [String: String]) {
                            print("created AlertTableController")
                            self.dataDictionary = dataDictionary
                            dataSource = []
                            super.init()
                            convertDictionaryToArray()
                        }
                        
                        func convertDictionaryToArray() {
                            self.dataDictionary.forEach({ (key: String, value: String) in
                                dataSource.append((key, value))
                            })
                        }
                        
                        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                            print("INNER CLASS CALLED")
                            return dataSource.count
                        }
                        
                        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                            
                            let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
                            let category = dataSource[indexPath.row].0
                            let criterion = dataSource[indexPath.row].1
                            cell.textLabel?.text = "\(category): \(criterion)"
                            return cell
                            
                        }
                    }
                    
                    let alertTableController = AlertTableController(with: criteria)
                    tableView.dataSource = alertTableController
                    tableView.delegate = alertTableController
                    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                    tableView.backgroundColor = UIColor.green
                    
                    alertController.view.addSubview(tableView)
                    
                    self.present(alertController, animated: true, completion:{
                        // Completion
                    })
                    
                    
                
                } else {
                    RequestManager.sharedInstance.giveFeedback(for: item.1.id, with: criteria, completion: { (error) in
                        print("deleting \(item.1.title)")
                        print("inappropriate for: ")
                        criteria.forEach({ (key: String, value: String) in
                            print("\(key) : \(value)")
                        })
                        
                        
                        self.alteredSongsList.remove(at: indexPath.row)
                        self.table.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
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

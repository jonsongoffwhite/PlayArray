//
//  SelectViewController.swift
//  PlayArray
//
//  Created by Jono Muller on 31/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

private let reuseIdentifier = "criteriaCell"
private let cellsPerRow: CGFloat = 2
var criteria: [Category] = []
var selectedCriteria: [Category] = []
private var player: AVAudioPlayer!

class SelectViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var makePlaylistButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationManager = CLLocationManager()
        criteria.append(WeatherCategory(locationManager: locationManager))
        criteria.append(TimeOfDayCategory())
        criteria.append(GenreCategory())
        
        collectionView.allowsMultipleSelection = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SelectViewController.handleLongPress))
        longPress.delegate = self
        self.collectionView.addGestureRecognizer(longPress)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let cells = collectionView.indexPathsForVisibleItems
        cells.forEach({ (i) in
            let cell = collectionView.cellForItem(at: i) as! CriteriaCell
            displayCell(cell: cell, criterion: criteria[i.row])
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLongPress(sender: UIRotationGestureRecognizer) {
        let location = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: location)
        if indexPath != nil {
            openCriteriaTypeView(indexPath: indexPath!)
        }
    }
    
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        let location = sender.convert(CGPoint(x: 0, y: 0), to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: location)
        openCriteriaTypeView(indexPath: indexPath!)
    }
    
    func openCriteriaTypeView(indexPath: IndexPath) {
        let criterion = criteria[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "selectEnumTableViewController") as! SelectEnumTableViewController
        let navController = UINavigationController(rootViewController: vc)
        
        vc.criterion = criterion
        vc.values = criterion.getAllValues()
        
        self.present(navController, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func makePlaylistButtonPressed(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "playlistViewController") as! PlaylistTableViewController
        
        var playlistName: String = ""
        
        for (index, item) in selectedCriteria.enumerated() {
            playlistName.append(item.getCriteria().first!)
            if index < selectedCriteria.count - 1 {
                playlistName.append(", ")
            }
        }

        PlaylistManager.getPlaylist(from: selectedCriteria) { (playlist, error) in
            vc.playlist = playlist
            vc.playlist.name = playlistName
            self.show(vc, sender: sender)
        }
        
    }
}

extension SelectViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criteria.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CriteriaCell
        let criterion = criteria[indexPath.row]
        
        if criterion.getCriteria().count == 0 {
            criterion.getData {
                self.displayCell(cell: cell, criterion: criterion)
            }
        } else {
            displayCell(cell: cell, criterion: criterion)
        }
        
        return cell
    }
    
    func displayCell(cell: CriteriaCell, criterion: Category) {
        let criteriaType: String = criterion.getCriteria().first!
        let cellText: String = criterion.getStringValue()
        
        if criteriaType == criterion.current {
            cell.mainLabel.text = "Current " + cellText
        } else {
            cell.mainLabel.text = cellText
        }
        
        cell.detailLabel.text = criteriaType.capitalized
        var imagePath: String = ""
        let id: String = criterion.getIdentifier()
        
        if id == "weather" {
            imagePath = criteriaType
        } else if id == "local_time" {
            imagePath = "time"
        }
        
        cell.imageView.image = UIImage(named: imagePath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCriteria.count == 0 {
            let upSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "WHOOP", ofType: "wav")!)
            do {
                player = try AVAudioPlayer(contentsOf: upSound as URL)
            } catch {
                
            }
            UIView.animate(withDuration: 0.3, animations: {
                player.play()
                self.makePlaylistButton.frame = CGRect(x: self.makePlaylistButton.frame.origin.x, y: self.makePlaylistButton.frame.origin.y - 55, width: self.makePlaylistButton.frame.size.width, height: self.makePlaylistButton.frame.size.height)
            })
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.red
        let criterion = criteria[indexPath.row]
        selectedCriteria.append(criterion)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectedCriteria.count == 1 {
            let downSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "AWHOOP", ofType: "wav")!)
            do {
                player = try AVAudioPlayer(contentsOf: downSound as URL)
            } catch {
                
            }
            UIView.animate(withDuration: 0.3, animations: {
                player.play()
                self.makePlaylistButton.frame = CGRect(x: self.makePlaylistButton.frame.origin.x, y: self.makePlaylistButton.frame.origin.y + 55, width: self.makePlaylistButton.frame.size.width, height: self.makePlaylistButton.frame.size.height)
            })
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(colorLiteralRed: 0, green: 155/255, blue: 205/255, alpha: 1)
        
        let criterion = criteria[indexPath.row]
        let index = selectedCriteria.index(where: {$0.getIdentifier() == criterion.getIdentifier()})
        selectedCriteria.remove(at: index!)
    }
}

extension SelectViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.width - 20.0 * (cellsPerRow + 1)) / cellsPerRow
        let size = CGSize(width: cellWidth, height: cellWidth)
        return size
    }
}

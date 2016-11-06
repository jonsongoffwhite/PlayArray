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
private var criteria: [Category] = []
private var selectedCriteria: [Category] = []
private var player: AVAudioPlayer!

class SelectViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var makePlaylistButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationManager = CLLocationManager()
        criteria.append(WeatherCategory(locationManager: locationManager))
        criteria.append(TimeOfDayCategory())
        
        collectionView.allowsMultipleSelection = true
        
        SpotifyManager.sharedInstance.login {
            //
        }
                
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.mainLabel.text = criterion.getStringValue()
        criterion.getData {
            let weatherType: String = criterion.getCriteria().first!
            cell.detailLabel.text = weatherType
            var imagePath: String = ""
            
            if criterion.getIdentifier() == "weather" {
                imagePath = String(format: "%@.png", weatherType)
            } else if criterion.getIdentifier() == "local_time" {
                imagePath = "time.png"
            }
            
            cell.imageView.image = UIImage(named: imagePath)
        }
        
        return cell
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

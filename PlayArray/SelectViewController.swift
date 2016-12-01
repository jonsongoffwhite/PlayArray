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

class SelectViewController: UIViewController, UIGestureRecognizerDelegate, SelectEnumDelegate {

    var deletedTracks: [(Playlist, [Song])] = []
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var makePlaylistButton: UIButton!
    @IBOutlet weak var reviewDeletionsButton: UIButton!
    
    private var selectedIndexPath: IndexPath = IndexPath(row: 0, section: -1)
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(SelectViewController.makePlaylistButtonPressed()))
        
        NotificationCenter.default.addObserver(forName: Notification.Name(feedbackKey), object: nil, queue: OperationQueue.main) { (Notification) in
            
//            self.deletedTracks = Notification.object as! [(Playlist, [Song])]
            
            UIView.animate(withDuration: 0.3, animations: {
                self.reviewDeletionsButton.frame = CGRect(x: self.reviewDeletionsButton.frame.origin.x, y: self.reviewDeletionsButton.frame.origin.y - 55, width: self.reviewDeletionsButton.frame.size.width, height: self.reviewDeletionsButton.frame.size.height)
            })
        }
        
        locationManager = CLLocationManager()
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        criteria.append(WeatherCategory(locationManager: locationManager))
        criteria.append(TimeOfDayCategory())
        criteria.append(GenreCategory())
        
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        
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
        
        if selectedIndexPath.section != -1 {
            collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
            selectCell(indexPath: selectedIndexPath)
        }
        
        let selectedCells = collectionView.indexPathsForSelectedItems
        selectedIndexPath = IndexPath(row: 0, section: -1)
    }
    
    // Delegate method for SelectEnumDelegate
    func passIndexPath(indexPath: IndexPath) {
        selectedIndexPath = indexPath
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
        vc.delegate = self
        
        let cell = collectionView.cellForItem(at: indexPath)
        if !(cell?.isSelected)! {
            selectedIndexPath = indexPath
        }
        
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
            vc.criteria = selectedCriteria
            
            let backButton = UIBarButtonItem()
            backButton.title = "Back"
            self.navigationItem.backBarButtonItem = backButton
            
            self.show(vc, sender: sender)
        }
        
    }
    @IBAction func reviewDeletionsButtonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "reviewDeletionsViewController") as! ReviewDeletionsViewController
        vc.alteredSongs = self.deletedTracks
        self.show(vc, sender: sender)
        
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
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = APCustomBlurView(withRadius: 1.5)
        blurView.tag = 100
        
        blurView.frame = cell.blurredImageView.bounds
        cell.blurredImageView.addSubview(blurView)
        
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        vibrancyView.frame = cell.blurredImageView.bounds
        blurView.addSubview(vibrancyView)
        
        // vibrancyView.contentView.addSubview(cell.mainLabel)
        
        let darkView = UIView(frame: blurView.frame)
        darkView.backgroundColor = UIColor.black
        darkView.alpha = 0.3
        darkView.tag = 200
        
        blurView.addSubview(darkView)
        
        cell.blurredImageView.layer.cornerRadius = 7.5
        cell.blurredImageView.clipsToBounds = true
        
        
        return cell
    }
    
    func displayCell(cell: CriteriaCell, criterion: Category) {
        let criteriaType: String = criterion.getCriteria().first!
        let cellText: String = criterion.getStringValue()
        
        if criteriaType == criterion.current && criterion.getIdentifier() != "genre" {
            cell.mainLabel.text = "Current " + cellText
        } else {
            cell.mainLabel.text = cellText
        }
        
        cell.detailLabel.text = criteriaType.capitalized
        let iconImagePath: String = criteriaType + "-icon"
        
        cell.blurredImageView.image = UIImage(named: criteriaType)
        cell.imageView.image = UIImage(named: iconImagePath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCell(indexPath: indexPath)
    }
    
    func selectCell(indexPath: IndexPath) {
        if selectedCriteria.count == 0 {
            let upSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "WHOOP", ofType: "wav")!)
            do {
                player = try AVAudioPlayer(contentsOf: upSound as URL)
            } catch {
                
            }
            UIView.animate(withDuration: 0.3) {
                //                player.play()
                self.makePlaylistButton.frame = CGRect(x: self.makePlaylistButton.frame.origin.x, y: self.makePlaylistButton.frame.origin.y - 55, width: self.makePlaylistButton.frame.size.width, height: self.makePlaylistButton.frame.size.height)
            }
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CriteriaCell
        
        UIView.animate(withDuration: 0.13) {
            cell.blurredImageView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            let blurView: APCustomBlurView = cell.blurredImageView.viewWithTag(100) as! APCustomBlurView
            blurView.setBlurRadius(10)
        }
        
        cell.checkBoxImageView.isHidden = false
        
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
            UIView.animate(withDuration: 0.3) {
//                player.play()
                self.makePlaylistButton.frame = CGRect(x: self.makePlaylistButton.frame.origin.x, y: self.makePlaylistButton.frame.origin.y + 55, width: self.makePlaylistButton.frame.size.width, height: self.makePlaylistButton.frame.size.height)
            }
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CriteriaCell
//        cell?.backgroundColor = UIColor(colorLiteralRed: 0, green: 155/255, blue: 205/255, alpha: 1)
        
        UIView.animate(withDuration: 0.13) {
            cell.blurredImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            let blurView: APCustomBlurView = cell.blurredImageView.viewWithTag(100) as! APCustomBlurView
            blurView.setBlurRadius(1.5)
//            let darkView = blurView.viewWithTag(200)
//            darkView?.alpha = 0.3
        }
        
        cell.checkBoxImageView.isHidden = true
        
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

extension SelectViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        collectionView.reloadData()
    }
}

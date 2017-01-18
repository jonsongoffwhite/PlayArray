//
//  PlaylistTableViewController.swift
//  PlayArray
//
//  Created by Jono Muller on 16/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {
    
    var playlist: Playlist = Playlist(name: "", songs: [])
    var showSpotifyButton = true
    var criteria: [Category] = []
    var uri: URL!
    var shared: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = playlist.name
        
        print("Loaded playlist table view controller")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Add button in navigation bar for exporting
        if showSpotifyButton {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(PlaylistTableViewController.share))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        let song = playlist.songs[indexPath.row]
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = String(format: "%@ - %@", song.artist, song.album)

        return cell
    }
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlaylistTableViewController {

    func share() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        if SettingsTableViewController.loggedIn {
            if !shared {
                SpotifyManager.sharedInstance.makePlaylist(with: playlist.songs, called: playlist.name, completion: { (uri) in
                    self.shared = true
                    self.uri = uri
                    self.playlist.spotifyURI = SpotifyManager.uriFrom(spotifyURI: uri.absoluteString)
                    
                    do {
                        try DataManager.save(playlist: self.playlist, songs: self.playlist.songs, createNew: true, completion: { (songs) in
                            // completion
                        })
                    } catch {
                        print("Error saving playlist: \(error)")
                    }
                    
                    spinner.stopAnimating()
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(PlaylistTableViewController.share))
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                    
                    self.showShareSheet(uri: uri)
                })
                
                spinner.startAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
            } else {
                self.showShareSheet(uri: uri)
            }
        } else {
            let alert = UIAlertController(title: "Not logged in", message: "Please log in to Spotify on the Settings tab first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showShareSheet(uri: URL) {
        let spotifyActivity = SpotifyActivity(uri: uri)
        let activityProvider = ActivityProvider(uri: uri)
        let shareSheet = UIActivityViewController(activityItems: [activityProvider], applicationActivities: [spotifyActivity])
        
        shareSheet.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.addToReadingList]
        
        self.present(shareSheet, animated: true, completion: nil)
    }
}

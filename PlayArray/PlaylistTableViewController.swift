//
//  PlaylistTableViewController.swift
//  PlayArray
//
//  Created by Jono Muller on 16/10/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit
import CoreData

class PlaylistTableViewController: UITableViewController {
    
    var playlist: Playlist = Playlist(name: "", songs: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = playlist.name
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Add button in navigation bar for exporting
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open in Spotify", style: .plain, target: self, action: #selector(PlaylistTableViewController.openInSpotify))
        
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

    func openInSpotify() {
        let spotify = SpotifyManager.sharedInstance
        spotify.makePlaylist(with: playlist.songs, called: self.playlist.name) { uri in
            print("Created playlist with uri \(uri)")
            let tracks = SpotifyManager.getSpotifyIds(from: self.playlist.songs)
            self.savePlaylist(uri: uri, tracks: tracks)
        }
    }
    
    func savePlaylist(uri: String, tracks: [String]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "SpotifyPlaylist", in: context)
        let playlist = NSManagedObject(entity: entity!, insertInto: context)
        
        playlist.setValue(uri, forKey: "uri")
        save(tracks: tracks, context: context, into: playlist)
        
        do {
            try context.save()
            print("Playlist (\(uri)) saved to phone")
        } catch {
            print("Error saving playlist to phone: \(error)")
        }
    }
    
    func save(tracks URIs: [String], context: NSManagedObjectContext, into playlist: NSManagedObject) {
        let entity = NSEntityDescription.entity(forEntityName: "SpotifyTrack", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SpotifyTrack")
        URIs.forEach { uri in
            fetchRequest.predicate = NSPredicate(format: "uri == %@", uri)
            do {
                let fetchResults = try context.fetch(fetchRequest)
                var track: NSManagedObject? = fetchResults.first as? NSManagedObject
                if fetchResults.count == 0 { // Using nil check is better
                    // Create a new entry for the track
                    track = NSManagedObject(entity: entity!, insertInto: context)
                    track!.setValue(uri, forKey: "uri")
                    print("Saved new track with URI: \(uri)")
                } else {
                    print("Found track with URI: \(uri)")
                }
                
                // Don't trust this... Hope we can do this without creating an NSManagedObject subclass:
                
                // Add `inPlaylist` relation
                track!.setValue(NSSet(object: playlist), forKey: "inPlaylist")
                
                // Add `hasTrack` relation
//                playlist.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
                
            } catch {
                print(error)
            }
        }
    }

}

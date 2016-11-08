//
//  SettingsTableViewController.swift
//  PlayArray
//
//  Created by Jono Muller on 06/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit

private let sections: [String] = ["Spotify"]

class SettingsTableViewController: UITableViewController {
    
    var loggedIn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SpotifyManager.sharedInstance.isLoggedIn() {
            loggedIn = true
        } else {
            SpotifyManager.sharedInstance.renewSession(completion: { (success) in
                if success {
                    self.loggedIn = true
                } else {
                    self.loggedIn = false
                }
            })
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        if loggedIn {
            cell.textLabel?.text = String(format: "Logged in as %@", (SpotifyManager.sharedInstance.session?.canonicalUsername)!)
        } else {
            cell.textLabel?.text = "Login to Spotify"
            cell.textLabel?.textColor = UIColor(colorLiteralRed: 0, green: 122/255, blue: 1, alpha: 1)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if !loggedIn {
                SpotifyManager.sharedInstance.login {
                    self.loggedIn = true
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
                cell.textLabel?.text = String(format: "Logged in as %@", (SpotifyManager.sharedInstance.session?.canonicalUsername)!)
                cell.textLabel?.textColor = .black
            }
        }
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
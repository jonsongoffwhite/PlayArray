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
    
    static var loggedIn: Bool = false
    private var notification: NSObjectProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name(sessionKey), object: nil, queue: OperationQueue.main) { (Notification) in
            self.tableView.reloadData()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
            if SettingsTableViewController.loggedIn {
                return 2
            } else {
                return 1
            }
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.selectionStyle = .default
        cell.isUserInteractionEnabled = true
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.textColor = .black
        
        let buttonColour = UIColor(colorLiteralRed: 0, green: 122/255, blue: 1, alpha: 1)
        
        if SettingsTableViewController.loggedIn {
            if indexPath.row == 0 {
                cell.textLabel?.text = String(format: "Logged in as %@", (SpotifyManager.sharedInstance.session?.canonicalUsername)!)
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Log out"
                cell.textLabel?.textColor = buttonColour
                cell.textLabel?.textAlignment = .center
            }
        } else {
            cell.textLabel?.text = "Log in to Spotify"
            cell.textLabel?.textColor = buttonColour
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if !SettingsTableViewController.loggedIn {
                    SpotifyManager.sharedInstance.login {
                        //
                    }
                }
            } else if indexPath.row == 1 {
                let alert = UIAlertController(title: "Logout successful", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: {
                    UserDefaults.standard.removeObject(forKey: sessionKey)
                    SpotifyManager.sharedInstance.session = nil
                    SettingsTableViewController.loggedIn = false
                    tableView.reloadData()
                })
            }

        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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

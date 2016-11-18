//
//  SelectEnumTableViewController.swift
//  PlayArray
//
//  Created by Jono Muller on 09/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import UIKit

private let reuseIdentifier = "enumCell"

class SelectEnumTableViewController: UITableViewController {
    
    var criterion: Category!
    var values: [Criteria]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Select Type"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SelectEnumTableViewController.cancel))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        stringValues = [criterion.getCriteria().first!] + criterion.getAllStringValues()
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
        return values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let indexOfCurrent = values.index(where: {criterion.getRawValue(criterion: $0) == criterion.current})
        let current = values[indexOfCurrent!]
        values.remove(at: indexOfCurrent!)
        values.insert(current, at: 0)
        let id: String = criterion.getIdentifier()
        
        let value = values[indexPath.row]
        let rawValue = criterion.getRawValue(criterion: value)
        
        var cellText: String = rawValue.capitalized
        
        if indexPath.row == 0 {
            if id == "weather" {
                cellText = "Current weather (\(criterion.current))"
            } else if id == "local_time" {
                cellText = "Current time (\(criterion.current))"
            }
        }
        
        cell.textLabel?.text = cellText
        let imagePath: String = rawValue + "-icon"
        
        cell.imageView?.image = UIImage(named: imagePath)
        
        let imageSize = CGSize(width: 37, height: 37)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        let imageRect = CGRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height)
        cell.imageView?.image?.draw(in: imageRect)
        cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.imageView?.image = cell.imageView?.image?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = .black
        
        if criterion.getCriteria().first! == rawValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = values[indexPath.row]
        criterion.criteria = []
        criterion.add(criteria: value)
        self.dismiss(animated: true, completion: nil)
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

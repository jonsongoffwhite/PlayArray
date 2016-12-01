//
//  ReviewCriteriaViewController.swift
//  PlayArray
//
//  Created by Jonny Goff-White on 29/11/2016.
//  Copyright © 2016 PlayArray. All rights reserved.
//

import Foundation
import UIKit

class ReviewCriteriaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    var dataSource: [String] = []
    
    var delegate: CriteriaFeedbackDelegate?
    
    override func viewDidLoad() {
        
        table.dataSource = self
        table.delegate = self
        
        self.title = "Select Inappropriate Criteria"
        
        table.allowsMultipleSelection = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ReviewCriteriaViewController.donePressed))
        
        super.viewDidLoad()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "criteriaCell")!
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

extension ReviewCriteriaViewController {
    
    func donePressed() {
        if (table.indexPathsForSelectedRows?.count == 0) {
            //Must select at least one
        } else {
            //Return the results
            delegate?.giveFeedBack(criteria: <#T##[String : String]#>)
        }
    }
    
}

protocol CriteriaFeedbackDelegate {

    func getData() -> [String: String]
    
    func giveFeedback(criteria: [String: String])
    
}

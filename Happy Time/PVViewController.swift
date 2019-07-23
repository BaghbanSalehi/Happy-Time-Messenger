//
//  PMViewController.swift
//  Happy Time Messenger
//
//  Created by Shayan on 4/29/19.
//  Copyright © 2019 Game4Life. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class PVViewController: SwipeTableViewController {
    
    var pmList = [String]()
    var pmKey = ""
    var goToPm = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs")
        usersDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! String
            let snapshotKey = snapshot.key
            if !(snapshotKey == "seen")
            {
            self.pmList.append(snapshotValue)
            self.tableView.reloadData()
            }

            
            
            
        }

    }
//    override func viewWillAppear(_ animated: Bool) {
//        
//            let value = ["seen" : "true"]
//            let seenDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs/seenDB")
//            seenDB.updateChildValues(value)
//         
//    }



    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pmList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = pmList[indexPath.row]
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs")
        usersDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! String
            if self.pmList[indexPath.row].contains(snapshotValue) {
            let snapshotKey = snapshot.key
                self.pmKey = snapshotKey
                
                self.performSegue(withIdentifier: "pm", sender: nil)
            
            }
            
        }
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pm"
        {
            let pmVC = segue.destination as! PMViewController
            pmVC.rooms = "\(pmKey)"
            
            
        }
        
    }
    
}

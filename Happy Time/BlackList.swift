//
//  BlackList.swift
//  Happy Time Messenger
//
//  Created by Shayan on 4/20/19.
//  Copyright © 2019 Game4Life. All rights reserved.
//

import UIKit
import Firebase

protocol BlackListDelegate {
    func updateBlackList(black :[String])
}

class BlackList: SwipeTableViewController {
    
    
 
    let defaults = UserDefaults.standard

    var blackList = [String]()
    var del = [String]()
    
    var delegate : BlackListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let BlackListDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/BlackList")
//        BlackListDB.observe(.childAdded) { (snapshot) in
//            let snapshotValue = snapshot.value as! String
//            if !(snapshotValue == "Nill"){
//            self.blackList.append(snapshotValue)
//            self.del.append(snapshot.key)
//            self.tableView.reloadData()
//
//        }
//        }
        
        
    }
//**************************************************************************************************************************

//**************************************************************************************************************************

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blackList.count
    }
//**************************************************************************************************************************
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = blackList[indexPath.row]
        return cell
    }
//***************************************************************************************
    override func updateModel(at indexPath: IndexPath) {
//        let BlackListDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/BlackList")
        defaults.mutableArrayValue(forKey: "Block").removeObject(at: indexPath.row)
         blackList.remove(at: indexPath.row)
        delegate?.updateBlackList(black: blackList)
        tableView.reloadData()
        
        
        
    }
    


}


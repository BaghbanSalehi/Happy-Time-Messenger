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
        defaults.mutableArrayValue(forKey: "Block").removeObject(at: indexPath.row)
         blackList.remove(at: indexPath.row)
        delegate?.updateBlackList(black: blackList)
        tableView.reloadData()
        
        
        
    }
    
    @IBAction func helpPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "INFORMATION", message: "Swipe left to unblock a user.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert,animated: true)
        
    }
    

}


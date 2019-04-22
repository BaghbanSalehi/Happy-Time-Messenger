//
//  SiwpeTableViewController.swift
//  Happy Time Messenger
//
//  Created by Shayan on 4/20/19.
//  Copyright © 2019 Game4Life. All rights reserved.
//

import UIKit
import SwipeCellKit
import Firebase

class SwipeTableViewController: UITableViewController,SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
 tableView.rowHeight = 80
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Unblock") { action, indexPath in
           
            self.updateModel(at: indexPath)
            
            
        }
        
        // customize the action appearance
        // deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }



    func updateModel (at indexPath : IndexPath)
    {
        //data update
        
    }
   

}

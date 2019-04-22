//
//  Rooms.swift
//  Happy Time Messenger
//
//  Created by Shayan on 1/22/19.
//  Copyright © 2019 Game4Life. All rights reserved.
//

import UIKit
import Firebase

class Rooms: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pak kardan back button navigation bar :)
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var rooms = segue.destination as! ChatViewController
        switch segue.identifier {
        case "En":
            rooms = segue.destination as! ChatViewController
            rooms.rooms = "En"
        case "Sw":
            rooms.rooms = "Sw"
        case "No":
            rooms.rooms = "No"
        case "Ge":
            rooms.rooms = "Ge"
        case "Fr":
            rooms.rooms = "Fr"
        default:
            print("error")
        }
    }
    
    
}

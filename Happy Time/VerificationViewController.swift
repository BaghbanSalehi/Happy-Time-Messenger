//
//  VerificationViewController.swift
//  Happy Time Messenger
//
//  Created by Shayan on 1/8/19.
//  Copyright © 2019 Game4Life. All rights reserved.
//

import UIKit
import Firebase

class VerificationViewController: UIViewController {
    @IBOutlet weak var noteLable: UILabel!
    
    @IBAction func successButton(_ sender: UIButton) {
      performSegue(withIdentifier: "goToLogin", sender: self)
        
    }
    
    
    @IBAction func resendButton(_ sender: UIButton) {
        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
        let alertVC = UIAlertController(title: "Success", message: "We have sent you another verification email", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(alertOk)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // pak kardan back button navigation bar :)
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        // Do any additional setup after loading the view.
    }
    
    
}

//
//  LogInViewController.swift
//  Happy Time Messenger
//
//  Created by Shayan on 12/8/18.
//  Copyright © 2019 Game4Life. All rights reserved.
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController,UITextFieldDelegate {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil
            {
              print(error!._code)
                self.handleError(error!)
                
                
                SVProgressHUD.dismiss()
            }
            else
            {
                if (Auth.auth().currentUser!.isEmailVerified){
                    self.performSegue(withIdentifier: "goToRooms", sender: self)
                    SVProgressHUD.dismiss()
                }
                else
                {
                    let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not been verified yet. Do you want us to send another verification email to \(self.emailTextfield.text!)?", preferredStyle: .alert)
                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                        (_) in
                         Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    
                    alertVC.addAction(alertActionOkay)
                    alertVC.addAction(alertActionCancel)
                    self.present(alertVC, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
                
            }
            
        }
       
        
        
    }
    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch errorCode
            {
            case .invalidEmail:
                errorLabel.text = "Invalid emial address"
            case .wrongPassword:
                errorLabel.text = "Wrong password"
            case .networkError:
                errorLabel.text = "Connection issues,please check your connection"
            case .userNotFound:
                errorLabel.text = "User not found,check your email address"
            default:
                print(error)
                errorLabel.text = "Connection issues,please check your connection"
                
                
            
        }
    }
    
}
    // vaghty return mizani keyboard baste she
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        view.endEditing(true)
        return true
    }

    
}  

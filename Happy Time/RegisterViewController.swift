//
//  RegisterViewController.swift
//  Happy Time Messenger
//
//  Created by Shayan on 12/8/18.
//  Copyright © 2019 Game4Life. All rights reserved.
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD



class RegisterViewController: UIViewController,UITextFieldDelegate {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var EULATextView: UITextView!
    @IBOutlet weak var usernameTextfield: UITextField!
    
    var agreed = false
    
   let doesNotAllowed = ["fuck","Fuck","bitch","BITCH","Nill","NILL","ADMIN","admin","Admin","Nigga","NIGGA","fck","FCK"]
//    let doesNotAllowed = CharacterSet(charactersIn: "fuck FUCK BITCH bitch ADMIN admin NILL nill NIGGA nigaa fkc FCK")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        usernameTextfield.delegate = self
      
        // bando basate gozashtan link vasate matn
        //******************************************************************************************************
        let attributedString = NSMutableAttributedString(string: "I have read and agreed to EULA terms")
        let url = URL(string: "http://happytimemessenger.blogfa.com")!
        
        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: url], range: NSMakeRange(26, 4))

        EULATextView.attributedText = attributedString
        EULATextView.isUserInteractionEnabled = true
        EULATextView.isEditable = false
        // Set how links should appear: blue and underlined
        EULATextView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

    }
//*******************************************************************************************************************
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func agreePressed(_ sender: UIButton) {
    agreed = !agreed
        if agreed {
            
            sender.setImage(UIImage(named: "check"), for: .normal)
            
        }
        else
        {
            sender.setImage(UIImage(named: "CheckBox"), for: .normal)
        }
        
        
    }
    
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        // in hamon completion handler hast ke be shekl closuer daromade,,faghat vaghty ke amaliat tolani background anjam she tamom she in execute mishe :
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil
            {
                handleError(error!)
                SVProgressHUD.dismiss()
            }
            
            else if (self.usernameTextfield.text?.trimmingCharacters(in: .whitespaces).isEmpty)! || (self.doesNotAllowed.contains(where: self.usernameTextfield.text!.contains))
            {
                Auth.auth().currentUser?.delete(completion: nil)
                self.errorLabel.text = "Please enter a valid username"
                SVProgressHUD.dismiss()
            }
            
                
            else if !self.agreed {
                
                Auth.auth().currentUser?.delete(completion: nil)
                self.errorLabel.text = "You must agree to EULA terms in order to proceed"
                SVProgressHUD.dismiss()
                }
            else
            {
                let image = UIImage(named: "egg")
                let storage = Storage.storage().reference().child("UserPics/\(Auth.auth().currentUser!.uid)")
                var data = Data()
                data = image!.jpegData(compressionQuality: 0.01)!
                storage.putData(data)
                
                
                
                let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/Username")
                usersDB.setValue(self.usernameTextfield.text)
                

                Auth.auth().currentUser?.sendEmailVerification {(error) in
if error != nil
{
    Auth.auth().currentUser?.delete(completion: nil)
    print(error!)
    handleError(error!)
    SVProgressHUD.dismiss()
}
else
{
    self.performSegue(withIdentifier: "goToVerification", sender: self)
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
                case .weakPassword:
                    errorLabel.text = "Password should contain at least 6 characters"
                case .emailAlreadyInUse:
                    errorLabel.text = "Email is already in use please enter another email"
                
                    
                default:
                    errorLabel.text = "Connection issues,please check your connection"
                    
                    
                    
                }
        
        

        
        
    } 
    
    
}
}
    //bara inke return zadim keyboard baste she
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    // mahdod kardan tedad kalamate textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 50
    }
}


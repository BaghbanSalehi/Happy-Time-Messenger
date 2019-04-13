//
//  ViewController.swift
//  Happy Time Messenger
//
//  Created by Shayan on 12/8/18.
//  Copyright © 2019 Game4Life. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import MobileCoreServices




class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // Declare instance variables
    var messageArray : [Message] = [Message]()
    var user = ""
    
    var avatar = ["String":UIImage()]
    // aks az camera ya library?
    var newPic : Bool?
    var login = true
    
    var keyHeight : CGFloat = 0
    var rooms = ""
    
    var myRealoaded = false
    var theirRealoaded = false
    

    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    @IBOutlet weak var i: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // taghire size keyboard be surate dynamic (stackflow)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/Username")
        usersDB.observe(.value){ (snapshot) in
            let snapshotValue = snapshot.value as? String
            self.user = snapshotValue!
            
        }

        //link kardan table ba vc
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        // elam kardane khodemun be onvane delegate baraye textfield
        messageTextfield.delegate = self
        

        
        
        //bando basate inke payane type kardan moshakhas she ba click roye jaye dg joz textfield ke hamun tv e inja
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        // Register kardan cell tarahi shode
messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
messageTableView.register(UINib(nibName: "MessageSent", bundle: nil), forCellReuseIdentifier: "sentMessageCell")

        messageTableView.separatorStyle = .none
        
        configureTableView()
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
       if (messageArray[indexPath.row].sender == user)
       {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentMessageCell", for: indexPath) as! SentMessageCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender

        if login == true
        {
            
        let storage = Storage.storage().reference().child("UserPics/\(Auth.auth().currentUser!.uid)")
        storage.getData(maxSize: 1 * 1024 * 1024){(data, error) in
            if error != nil
            {
               print(error!)
            }
            else
            {
                self.avatar["\(self.messageArray[indexPath.row].photoId)"] = UIImage(data: data!)
                if !self.myRealoaded {
                self.messageTableView.reloadData()
                    self.myRealoaded = true
                }
            }
        }
           cell.avatarImageView.image = avatar["\(messageArray[indexPath.row].photoId)"]
    }
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
            return cell
       }
        
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            if login == true
            {
            
            let storage = Storage.storage().reference().child("UserPics/\(messageArray[indexPath.row].photoId)")
          
            storage.getData(maxSize: 1 * 1024 * 1024){(data, error) in
                if error != nil
                {
                  print(error!)
                }
                else
                {
                    self.avatar["\(self.messageArray[indexPath.row].photoId)"] = UIImage(data: data!)
                    if !self.theirRealoaded{
                        self.messageTableView.reloadData()
                        self.theirRealoaded = true
                    }
                    
                }
            }
                cell.avatarImageView.image = avatar["\(messageArray[indexPath.row].photoId)"]
        }
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            return cell
        }
        
        

    }

    
    
    //tedad satrh haye table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    
    //in tabe bara vaghtie ke roye safhe ke hamun tv hast mizanim e ke darvaghe payane type kardan ro neshun mide
    @objc func tableViewTapped()
    {
    messageTextfield.endEditing(true)
    
    }
    
    
    
    //bara inke cell ha be nesbat andaze payam taghir size bedan
    func configureTableView()
    {
        
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
        
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    // didbegin tabe protocol uitextfielddelegate hast,bara zamanie ke roye field baraye type mizanim
   // func textFieldDidBeginEditing(_ textField: UITextField) {
// ino to halati ke dasty bud bekar bordim ke ro iphone x javab nemidad vase hamin az dastor paen ke tabash dar viewdidload hast use...
//}
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            keyHeight = keyboardHeight
            UIView.animate (withDuration: 0.5) {
                self.heightConstraint.constant = self.keyHeight + 50
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    
/*didendediting ham tabe protocol texfield hsat,bara zamanie ke type payam tamom shode,niaz dare be inke behesh begi key type tamome
vase hamin bayad barname befahme roye safhe va kharej textfield click mishe*/
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        //MARK : -bando basat ersal payam va zakhire shodaneshun dar firebase
        if messageTextfield.text != ""{ // payam bedune matn nade
        //aval az hame baad az zadane send keyboard ro mibandim
        messageTextfield.endEditing(true)
        
        // bara inke beyne fasele send shodan payam user fekr nakone freez shode va hey send ro bezane
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // sakhtan yek database be name messages dakhel database firebase
        let messagesDB = Database.database().reference().child("Messages/\(rooms)")
        //sakhtan dic baraye inke formate save shodane payam o dar db moshakhas konim
            let messagesDictionary = ["sender":user,"MessageBody":messageTextfield.text!,"photo":"\(Auth.auth().currentUser!.uid)"]
        // dic ro dar db ke sakhtim dar firebase be unvane child save mikone, in dastor male firebase hast
        messagesDB.childByAutoId().setValue(messagesDictionary){(error,reference) in // az closure use mikonim bara check kardan suc
            if error != nil
            {
                print(error!)
            }
            else
            {
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = "" // bara inke chizi ke dar textfield neveshte shode baad az ersal payam pak she
            }
            
            
            
        }
        
        }
        
        
    }
    
    //TODO: retrieve kardan payam ha az firebase
    func retrieveMessages ()
    {
        
    
        let messageDB = Database.database().reference().child("Messages/\(rooms)")
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["sender"]!
            let photo = snapshotValue["photo"]!
            let message = Message()
            message.messageBody = text
            message.sender = sender
            message.photoId = photo
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
            let ip = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: ip, at: .bottom , animated: true)
                
            
            
        }
        
        
        
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        login = false
        // amaliat do cath baraye inke age throw call emun be har dalili error dasht error toye catch handle she
        do
        {
            try Auth.auth().signOut() // amaliat signout az dastorate firebase
            
        }
        catch
        {
            print("error")
        }
        guard (navigationController?.popToRootViewController(animated: true)) != nil // be safhe root mire (wlc)
        else {
            print("error : no viewController")
            return
        }
        
    }
    // bando basat camera
    @IBAction func cameraPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Select Image From", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default){(action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
            {
             let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = true
            
        }
            }
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default){ (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
            {
               let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = false
                
                
            }
            
        }
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        self.present(alert, animated: true)
        
        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let mediaType = info[.mediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as String)
        {
            let image = info[.originalImage] as! UIImage
            let storage = Storage.storage().reference().child("UserPics/\(Auth.auth().currentUser!.uid)")
            var data = Data()
            data = image.jpegData(compressionQuality: 0.01)!
            storage.putData(data, metadata: nil) { (metadata, error) in
            if error != nil
            {
                print(error!)
            }
                else
            {
                self.myRealoaded = false
                print("ssssssssssss")
            }
             }

            
            if newPic == true
            {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageError) , nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
        

        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    // baraye #selector uiImageWrite ke az objc bayad komak begirim
    @objc func imageError(image : UIImage, didFinishSavingWithError error : NSErrorPointer, contextInfo : UnsafeRawPointer)
    {
        if (error != nil)
        {
           let alert = UIAlertController(title: "Saving Failed", message: "Faild to save image", preferredStyle: .alert)
           let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
        
    }


}

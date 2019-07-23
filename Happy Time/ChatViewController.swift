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
import MessageUI
import Photos

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,BlackListDelegate {
    
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
    
     var blockedUsers = [String]()
     let defaults = UserDefaults.standard

    let doesNotAllowed = ["fuck","Fuck","bitch","BITCH","nigga","NIGGA","niga","NIGA","fck","FCK","dick","DICK","ass","ASS"]
    
    var onlineUsers = OnlineUsers.singleton
    
    var pm = ""

    var pmControll = false
    
    var receiverID = ""
    
    let notificationButton = BadgeButton()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //controll karadan new pm
        let controllDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs")
        controllDB.observe(.childAdded) { (snapshot) in
            self.pmControll = true
            print("ggggggggg")
        }
        

    
    
//blacklist
        if let blackList = UserDefaults.standard.array(forKey: "Block") as? [String]{
            
            blockedUsers = blackList
            
        }
        
        
            
            let storage = Storage.storage().reference().child("UserPics/\(Auth.auth().currentUser!.uid)")
            storage.getData(maxSize: 1 * 1024 * 1024){(data, error) in
                if error != nil
                {
                    print(error!)
                }
                else
                {
                    self.saveImage(imageName: "userPic", image: UIImage(data: data!)!)
                   
                }
            }
            
        


        // taghire size keyboard be surate dynamic (stackflow)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/Username")
        usersDB.observe(.value){ (snapshot) in
            let snapshotValue = snapshot.value as? String
            self.user = snapshotValue!
        let onlineDB = Database.database().reference().child("OnlineUsers/\(Auth.auth().currentUser!.uid)")
            onlineDB.setValue(self.user)
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        //pm key with badge icon
        
        notificationButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        notificationButton.setImage(UIImage(named: "inbox")?.withRenderingMode(.alwaysTemplate), for: .normal)
        notificationButton.addTarget(self, action: #selector(rightButtonTouched), for: .touchUpInside)
        notificationButton.badgeEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 15)
        notificationButton.badge = ""
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationButton)
        
      pmController()

        
    }

//
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.isMovingFromParent {
            if let db = Auth.auth().currentUser?.uid {
             let onlineDB = Database.database().reference().child("OnlineUsers/\(db)")
            onlineDB.removeValue()
        
    }
        }
}

    @objc func rightButtonTouched() {
        performSegue(withIdentifier: "goToPV", sender: nil)
        print("right button touched")
    }
    
    
//*************************************************************************************************************************************
    // MARK:- local image save & load
    //copy paste stackflow
    func saveImage(imageName: String, image: UIImage) {
        
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        
    }
    
    
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
            
        }
        
        return nil
    }
//*************************************************************************************************************************************
    func pmController ()
    {
        let seenDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/seenDB")
        seenDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! String
            if snapshotValue == "false" {
                self.notificationButton.badge = "1"
                
            }
                
//            else
//            {
//                self.seen = ""
//                self.notificationButton.badge = self.seen
//            }
        
    }
        
        seenDB.observe(.childChanged) { (snapshot) in
            let snapshotValue = snapshot.value as! String
            if snapshotValue == "false" {
                
                self.notificationButton.badge = "1"

            }
                
//            else
//            {
//                self.seen = ""
//                self.notificationButton.badge = self.seen
//            }
        }
}

//*************************************************************************************************************************************
    
    //MARK: - TableView DataSource Methods
    
    
    
    // Declare cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
       if (messageArray[indexPath.row].sender == user)
       {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentMessageCell", for: indexPath) as! SentMessageCell
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender

        if login == true
        {
            
//        let storage = Storage.storage().reference().child("UserPics/\(Auth.auth().currentUser!.uid)")
//        storage.getData(maxSize: 1 * 1024 * 1024){(data, error) in
//            if error != nil
//            {
//               print(error!)
//            }
//            else
//            {
//                self.avatar["\(self.messageArray[indexPath.row].photoId)"] = UIImage(data: data!)
//                if !self.myRealoaded {
//                self.messageTableView.reloadData()
//                    self.myRealoaded = true
//                }
//            }
//        }
            
            self.avatar["\(self.messageArray[indexPath.row].photoId)"] = loadImageFromDiskWith(fileName: "userPic")
            
            if !self.myRealoaded {
                                self.messageTableView.reloadData()
                                    self.myRealoaded = true
                                }
            
            
            
           cell.avatarImageView.image = avatar["\(messageArray[indexPath.row].photoId)"]
    }
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
    
            pmController()
        
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

            pmController()
            
            return cell
            
        }
        
        

    }

    
    
    //tedad satrh haye table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
//*******************************************************************************************************************************
    // MARK:- Block & report
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            receiverID = messageArray[indexPath.row].photoId
        let receiverUser = messageArray[indexPath.row].sender
        
        if !(receiverID == Auth.auth().currentUser!.uid && self.blockedUsers.contains(receiverUser)){
        let alert = UIAlertController(title: "Select an action", message: "How can we help you", preferredStyle: .actionSheet)
            
        let block = UIAlertAction(title: "BLOCK", style: .default) { (action) in
            self.blockedUsers.append(receiverUser)
            self.defaults.set(self.blockedUsers, forKey: "Block")
            let blockReport = UIAlertController(title: "User blocked", message: "The user has been blocked.You can unblock him/her at any time.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            blockReport.addAction(ok)
            self.present(blockReport,animated: true)
        }
            block.setValue(UIColor.red, forKey: "titleTextColor")
            
            let report = UIAlertAction(title: "REPORT", style: .default) { (action) in
                self.sendEmail(reportedUser: "\(self.receiverID)")
            }
            report.setValue(UIColor.red, forKey: "titleTextColor")
            
            if !(self.blockedUsers.contains(receiverUser)) {
            let pm = UIAlertAction(title: "Private Message", style: .default) { (action) in
                if self.pmControll {
                let controllDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs")
                controllDB.observe(.childAdded, with: { (snapshot) in
                    let snapshotValue = snapshot.value as! String
                    let snapshotKey = snapshot.key
                    if snapshotValue.contains(receiverUser){
                        self.pm = snapshotKey
                        
                        let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs/\(self.pm)")
                        usersDB.setValue(receiverUser)
                        
                        let otherDB = Database.database().reference().child("Users/\(self.receiverID)/PMs/\(self.pm)")
                        otherDB.setValue(self.user)
                        
                        self.performSegue(withIdentifier: "PM", sender: nil)
                    }
                  
                })
                }
                
                else {
                    self.pm = "\(Auth.auth().currentUser!.uid)\(self.receiverID)"
                    
                    let usersDB = Database.database().reference().child("Users/\(Auth.auth().currentUser!.uid)/PMs/\(self.pm)")
                    usersDB.setValue(receiverUser)
                    
                    let otherDB = Database.database().reference().child("Users/\(self.receiverID)/PMs/\(self.pm)")
                    otherDB.setValue(self.user)
                   
                    self.performSegue(withIdentifier: "PM", sender: nil)
                    
                }
                

                
 
                
                
                
                
                
            }
                alert.addAction(pm)
            }
            
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            
        alert.addAction(block)
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
        messageTableView.deselectRow(at: indexPath, animated: true)
    }
    //****************************************************************************************************************************
    
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
    
    
    
//*************************************************************************************************************************************
    
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
    
//*************************************************************************************************************************************
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        //MARK : -bando basat ersal payam va zakhire shodaneshun dar firebase
        if (doesNotAllowed.contains(where: messageTextfield.text!.contains))  {
            
            messageTextfield.text = "***********"
            
        }
        
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
//*************************************************************************************************************************************
//retrieve kardan payam ha az firebase
    func retrieveMessages ()
    {

        

            let messageDB = Database.database().reference().child("Messages/\(self.rooms)")
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["sender"]!
            let photo = snapshotValue["photo"]!
            let message = Message()

            if !(self.blockedUsers.contains(sender)) {
            message.messageBody = text
            message.sender = sender
            message.photoId = photo
            self.messageArray.append(message)

            }
            self.configureTableView()
            self.messageTableView.reloadData()
            if (self.messageArray.count > 1 && !(self.blockedUsers.contains(sender))) {
            let ip = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: ip, at: .bottom, animated: true)
            }
            }
        
        
    }

//*************************************************************************************************************************************
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        login = false
        // amaliat do cath baraye inke age throw call emun be har dalili error dasht error toye catch handle she
        do
        {
            if let db = Auth.auth().currentUser?.uid {
                let onlineDB = Database.database().reference().child("OnlineUsers/\(db)")
                onlineDB.removeValue()
                
            }
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
//*************************************************************************************************************************************
    //MARK:- bando basat camera
    // bando basat permission gereftanam injas
    @IBAction func cameraPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Select Image From", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default){(action) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    //access granted
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
                else
                {
                 self.denied()
                }
            }
 
            }
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default){ (action) in
            let photoes = PHPhotoLibrary.authorizationStatus()
            
            switch photoes {
            
            case .authorized :
                
                self.picFromLib()
    
            case .denied :
                
                self.denied()
            
            case .notDetermined :
                
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized{
                        
                        self.picFromLib()
                        
                    }
                    else
                    {
                        self.denied()
                    }
                }
            default :
                break
                
            }
            
            

            
        }
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        self.present(alert, animated: true)
        
        }
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func picFromLib()
    {
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
    
    func denied()
    {
        let alert = UIAlertController(title: "Operation Failed", message: "Access denied", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
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
//*************************************************************************************************************************************
//MARK:- enteghal va daryaft etelaat az VCha
    }
    func updateBlackList(black :[String])
    {
        blockedUsers = black
        print(blockedUsers)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Black"{
        let blackListVC = segue.destination as! BlackList
            blackListVC.delegate = self
        blackListVC.blackList = blockedUsers
        }
        
        if segue.identifier == "PM" {
            
            let PMVC = segue.destination as! PMViewController
            PMVC.blockedUsers = blockedUsers
            PMVC.rooms = pm
            PMVC.otherUser = receiverID
            
            
            
        }
    }
//*************************************************************************************************************************************
    //MARK:- bando basat mail zadan az stackflow

    func sendEmail(reportedUser : String) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["software.developer.bsalehi@gmail.com"])
        composeVC.setSubject("Report")
        composeVC.setMessageBody("The following user has been reported because,he or she has been used objectionable content or is a abusive user and I have not included my personal feelings in this report decision.PLEASE DO NOT CHANGE THE FOLLOWING USER ID.Reported userID is: \(reportedUser)", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
     controller.dismiss(animated: true, completion: nil)
        if result.rawValue == MFMailComposeResult.sent.rawValue {
        let reportAlert = UIAlertController(title: "The user has been reported", message: "Thank you for contributing to make our community a safer place.We will check the problem and make any necessary actions within 24 hours. ", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        reportAlert.addAction(ok)
        self.present(reportAlert,animated: true)
        }
        
    }
    
    @IBAction func helpPressed(_ sender: UIBarButtonItem) {
            
            let alert = UIAlertController(title: "INFORMATION", message: "To block/report or send a private message to a user, hold your finger on their message for few seconds.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(ok)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    
}
extension UIViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

//
//  AppDelegate.swift
//  Happy Time Messenger
//
//  The App Delegate listens for events from the system. 
//  It recieves application level messages like did the app finish launching or did it terminate etc. 
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var user = ""

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
    
//Thread.sleep(forTimeInterval: 1.0)
        
        
        return true
    }

    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let db = Auth.auth().currentUser?.uid{
        let onlineDB = Database.database().reference().child("OnlineUsers/\(db)")
        onlineDB.removeValue()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if let db = Auth.auth().currentUser?.uid {
        let usersDB = Database.database().reference().child("Users/\(db)/Username")
        usersDB.observe(.value){ (snapshot) in
            let snapshotValue = snapshot.value as? String
            self.user = snapshotValue!
            let onlineDB = Database.database().reference().child("OnlineUsers/\(Auth.auth().currentUser!.uid)")
            onlineDB.setValue(self.user)
        }
   }
}

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let onlineDB = Database.database().reference().child("OnlineUsers/\(Auth.auth().currentUser!.uid)")
        onlineDB.removeValue()
    }

//MARK: - Uncomment this only once you've gotten to Step 14.
    /*
    
let APP_ID = "5H62DKM7JuG6kBBzVICydweQkSQTZD8vsFtoEEew"
let CLIENT_KEY = "UMkw6hwriImwSAEtwxlMbrJXtcccrTR6jdcRS9IN"
    
*/


}


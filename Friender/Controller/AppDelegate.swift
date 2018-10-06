//
//  AppDelegate.swift
//  Friender
//
//  Created by mac on 3/7/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var databaseRef: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GMSServices.provideAPIKey("AIzaSyBb0jIeePh65TPj4cBuzlYG3TvGTxA9eNk")
        GMSPlacesClient.provideAPIKey("AIzaSyBb0jIeePh65TPj4cBuzlYG3TvGTxA9eNk")
        setRootViewController()
        
        return true
    }
    
    func setRootViewController() {
        Auth.auth().addStateDidChangeListener { auth, user in
            
            if Auth.auth().currentUser != nil {
                // Set Your home view controller Here as root View Controller
                let myStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homePage = myStoryboard.instantiateViewController(withIdentifier: "TabBar") as! TabBarVC
                
                
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = homePage
                
            } else {
                let myStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let signInPage = myStoryboard.instantiateViewController(withIdentifier: "SignIn") as! SignInVC
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signInPage
                
            }

        }
    }

    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 11.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let err = error {
            print ("Failed to log in with Google: ", err)
            return
        }
        
        print ("Successfully logged in with Google", user)
        
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signInAndRetrieveData(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google: ", err)
                return
            } else {
                
                self.databaseRef = Database.database().reference()
                self.databaseRef.child("user_profiles").child(user!.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let snapshot = snapshot.value as? NSDictionary
                    if (snapshot == nil) {
                        
                    self.databaseRef.child("user_profiles").child(user!.user.uid).child("name").setValue(user!.user.displayName)
                    self.databaseRef.child("user_profiles").child(user!.user.uid).child("email").setValue(user!.user.email)
                    self.databaseRef.child("user_profiles").child(user!.user.uid).child("profile_picture").setValue(user!.user.photoURL?.absoluteString)
                        
                        let storage = Storage.storage()
                        
                        // Create a storage reference
                        let storageRef = storage.reference()
                        
                        //points to the child directory where the profile picture will be saved on firebase
                        let profilePicRef = storageRef.child("/User Profile Pictures/"+(Auth.auth().currentUser?.uid)!+"/profile_pic.jpg")
                        

                        
                        if (GIDSignIn.sharedInstance().currentUser != nil) {
                            
                            let imageUrl = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 400).absoluteString
                            let url  = NSURL(string: imageUrl)! as URL
                            let data = NSData(contentsOf: url)
                            
                            //upload image to storage
                            _ = profilePicRef.putData(data! as Data)
                        }
                        
                        
                    } else {
                        guard let uid = user?.user.uid else { return }
                        print("Sucessfully logged in to Firebase with Google", uid)
                        //sends user to homepage VC after a successful login
                        let myStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let homePage = myStoryboard.instantiateViewController(withIdentifier: "TabBar") as! TabBarVC
                        
                        
                        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = homePage
                    }
                })
                
            }
            
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//        // [START_EXCLUDE]
//        NotificationCenter.default.post(
//            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
//            object: nil,
//            userInfo: ["statusText": "User has disconnected."])
//        // [END_EXCLUDE]
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


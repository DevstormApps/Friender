//
//  EventsVC.swift
//  Friender
//
//  Created by mac on 7/13/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import GoogleSignIn

class EventsVC: UIViewController, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
 {
    
    let flowLayout = EventCollectionViewFlowLayout()
    let user = Auth.auth().currentUser
    
    // MARK: - Variables
    var ref: DatabaseReference!
    
    var events = [Event]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseStorage()
        collectionView.collectionViewLayout = flowLayout
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.bounds.size.width / 2
        profileImage.clipsToBounds = true
        ref = Database.database().reference()

        self.hideKeyboard()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.child("events").observe(.value) { snapshot in
            var events = [Event]()
            for unicornSnapshot in snapshot.children {
                let event = Event(snapshot: unicornSnapshot as! DataSnapshot)
                events.append(event)
            }
            self.events = events
        }
    }
    
    func firebaseStorage() {
        let user = Auth.auth().currentUser
      
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference
        let storageRef = storage.reference()
        
        //points to the child directory where the profile picture will be saved on firebase
        let profileImageRef = storageRef.child("/User Profile Pictures/"+(user?.uid)!+"/profile_pic.jpg")
        
        if (GIDSignIn.sharedInstance().currentUser != nil) {
            
            let imageUrl = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 400).absoluteString
            let url  = NSURL(string: imageUrl)! as URL
            let data = NSData(contentsOf: url)
            
            //upload image to storage
            _ = profileImageRef.putData(data! as Data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let size = metadata.size
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
                
            }
            
            self.profileImage.image = UIImage(data: data! as Data)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCell
        cell.event = events[indexPath.row]
        return cell
    }
    
  

    @IBAction func addEventButtonWasPressed(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupID") as! PopupViewVC
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}


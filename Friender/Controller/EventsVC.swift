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
    
    var images = [UIImage]()
    var myImage: UIImage?
    let flowLayout = EventCollectionViewFlowLayout()
    let user = Auth.auth().currentUser
    let ref = Database.database().reference(withPath: "events")
    var events: [EventHandler] = []
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseStorage()
        collectionView.collectionViewLayout = flowLayout
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.bounds.size.width / 2
        profileImage.clipsToBounds = true
        retrieveData()
        self.hideKeyboard()

    }
    
    func retrieveData() {
        // 1
        ref.observe(.value, with: { snapshot in
            // 2
            var newEventTitle: [EventHandler] = []
            
            // 3
            for child in snapshot.children {
                // 4
                if let snapshot = child as? DataSnapshot,
                    let eventTitle = EventHandler(snapshot: snapshot) {
                    newEventTitle.append(eventTitle)
                }
            }
            
            // 5
            self.events = newEventTitle
            self.collectionView.reloadData()
        })

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
        let eventTitle = events[indexPath.row]
        
        cell.eventTitle.text = eventTitle.title
        return cell
    }
    
    //MARK: - ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            myImage = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
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


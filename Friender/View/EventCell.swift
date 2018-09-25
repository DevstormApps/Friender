//
//  EventCell.swift
//  Friender
//
//  Created by mac on 7/13/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import GoogleSignIn

class EventCell: UICollectionViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!
    let color = UIColor(red:0.65, green:0.42, blue:0.95, alpha:1.0)
    
    var event: Event? {
        didSet {
            if let event = event {
                downloadImage(from: event.imagePath)
                eventTitle.text = event.title
                username.text = event.addedBy
                downloadProfileImage(from: event.key)
            }
        }
    }
    
    @IBAction func requestButtonWasPressed(_ sender: Any) {
            let ref = Database.database().reference()
        ref.child("requests").child((event?.key)!).child(user!.uid).child("isRequesterAccepted").setValue(false)
            let name = GIDSignIn.sharedInstance().currentUser.profile.name
        ref.child("requests").child((event?.key)!).child(user!.uid).child("name").setValue(name)
        ref.child("requests").child((event?.key)!).child(user!.uid).child("key").setValue(String(user!.uid))
        ref.child("requests").child((event?.key)!).child(user!.uid).child("profile_picture").setValue(String(user!.uid))
        }

    func downloadImage(from storageImagePath: String) {
        let path = storageRef.child("/events/"+(storageImagePath)+"/event_pic.jpg")
        
        path.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
            if let data = data {
                let image = UIImage(data: data)
                self.eventImage.image = image
            }
        }
              // self.eventImage.sd_setImage(with: path)
    }
    
    func downloadProfileImage(from profileImagePath: String) {
        let path = self.storageRef.child("/User Profile Pictures/"+(profileImagePath)+"/profile_pic.jpg")
        
        path.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
            if let data = data {
                let image = UIImage(data: data)
                self.profileImage.image = image
            }
        }
      //  self.eventImage.sd_setImage(with: path)

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storageRef = Storage.storage().reference()
        profileImage.layer.cornerRadius = profileImage.bounds.size.width / 2
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        requestButton.layer.borderWidth = 0.5
        requestButton.layer.borderColor = color.cgColor
        requestButton.layer.cornerRadius = 4
        requestButton.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImage.image = nil
        eventTitle.text = "title"
    }
    
}

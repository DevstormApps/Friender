//
//  RequestCell.swift
//  Friender
//
//  Created by mac on 8/29/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import GoogleSignIn


class RequestCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var accept: UIButton!
    
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!
    
    var request: Requests? {
        didSet {
            if let request = request {
                downloadImage(from: request.key)
                username.text = request.name
            }
        }
    }
    
    func downloadImage(from storageImagePath: String) {
        let path = storageRef.child("/User Profile Pictures/"+(storageImagePath)+"/profile_pic.jpg")
        userImage.sd_setImage(with: path)

//        storageDownloadTask = path.getData(maxSize: 1024 * 1024 * 12, completion: { (data, error) in
//            if let data = data {
//                self.userImage.image = UIImage(data: data)
//            }
//        })
//
        // 7. Finish download of image
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        storageRef = Storage.storage().reference()
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = userImage.bounds.size.width / 2
        userImage.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        username.text = "username"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func acceptButtonWasPressed(_ sender: Any) {
        let ref = Database.database().reference()
        
        ref.child("requests").child(user!.uid).child((request?.key)!).child("isRequesterAccepted").setValue(true)
        
        DatabaseService.instance.events.child((user?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
                let snapshotValue = snapshot.value as! Dictionary<String, AnyObject>
                let coordinateArray = snapshotValue["coordinate"] as! NSArray
                print(coordinateArray[0])
            ref.child("acceptedEventRequesters").child((self.request?.key)!).child((user?.uid)!).child("coordinate").setValue(coordinateArray)
                }
        }

}

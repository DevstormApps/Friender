//
//  AcceptedCell.swift
//  Friender
//
//  Created by mac on 9/25/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import GoogleSignIn

class AcceptedCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var getDirectionsButton: UIButton!
    
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!
    
    var acceptedEvents: AcceptedEvents? {
        didSet {
            if let acceptedEvents = acceptedEvents {
                downloadImage(from: acceptedEvents.image)
            }
        }
    }
    
    func downloadImage(from storageImagePath: String) {
        let path = storageRef.child("/User Profile Pictures/"+(storageImagePath)+"/profile_pic.jpg")
        image.sd_setImage(with: path)
        print("downloaded image!!!!!!! ^_^")
    }
    
    func openGoogleMaps() {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(acceptedEvents?.coordinate[0] ?? "can't find coord"),\(acceptedEvents?.coordinate[1] ?? "can't find coord")&directionsmode=driving")!)
        } else {
            print("Can't use comgooglemaps://")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        storageRef = Storage.storage().reference()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
    }

    
    @IBAction func getDirectionsButtonWasPressed(_ sender: Any) {
        openGoogleMaps()
        }

}

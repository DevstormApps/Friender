//
//  EventCell.swift
//  Friender
//
//  Created by mac on 7/13/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseStorage

class EventCell: UICollectionViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!
    
    var event: Event? {
        didSet {
            if let event = event {
                downloadImage(from: event.imagePath)
                eventTitle.text = event.title
            }
        }
    }
    
    func downloadImage(from storageImagePath: String) {
        let path = storageRef.child("/events/"+(storageImagePath)+"/event_pic.jpg")

                self.eventImage.sd_setImage(with: path)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storageRef = Storage.storage().reference()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImage.image = nil
        eventTitle.text = "title"
    }
    
}

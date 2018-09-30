//
//  AcceptedEvents.swift
//  Friender
//
//  Created by mac on 9/25/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AcceptedEvents {
    
    var image: String
    var coordinate: NSArray
    
    init(image: String, coordinate: NSArray) {
        self.image = image
        self.coordinate = coordinate
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        let coordinateDict = snapshot.value as! Dictionary<String, AnyObject>
        image = snapshotValue["imagePath"] as! String
        coordinate = coordinateDict["coordinate"] as! NSArray
    }
    
}
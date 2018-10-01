//
//  Requests.swift
//  Friender
//
//  Created by mac on 8/29/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class Requests {
    var name: String
    var profile_picture: String
    var key: String
    var eventKey:String
    
    init(name: String, profile_picture: String, key: String, eventKey:String) {
        self.name = name
        self.profile_picture = profile_picture
        self.key = key
        self.eventKey = eventKey
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        profile_picture = snapshotValue["profile_picture"] as! String
        name = snapshotValue["name"] as! String
        key = snapshotValue["key"] as! String
        eventKey = snapshotValue["eventKey"] as! String
    }
    
}

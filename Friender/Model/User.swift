//
//  User.swift
//  Friender
//
//  Created by mac on 9/7/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

struct User {
    let username: String
    // Standard init
    init(username: String) {
        self.username = username
     
    }
    
    // Init for reading from Database snapshot
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        username = snapshotValue["name"] as! String
      
    }
    
    // Func converting model for easier writing to database
    func toAnyObject() -> Any {
        return [
            "name": username,
        ]
    }
}

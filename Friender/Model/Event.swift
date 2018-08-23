//
//  EeventDataService.swift
//  Friender
//
//  Created by mac on 7/18/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

struct Event {
    let imagePath: String
    let title: String
    
    // Standard init
    init(imagePath: String, title: String) {
        self.imagePath = imagePath
        self.title = title
    }
    
    // Init for reading from Database snapshot
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        imagePath = snapshotValue["imagePath"] as! String
        title = snapshotValue["title"] as! String
    }
    
    // Func converting model for easier writing to database
    func toAnyObject() -> Any {
        return [
            "imagePath": imagePath,
            "title": title
        ]
    }
}

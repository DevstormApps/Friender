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
import Firebase

class EventHandler {
    let ref: DatabaseReference?
    let key: String
    let title: String
    var completed: Bool
    
    init(title: String, completed: Bool, key: String = "") {
        self.ref = nil
        self.key = key
        self.title = title
        self.completed = completed
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let title = value["title"] as? String,
            let completed = value["completed"] as? Bool else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.title = title
        self.completed = completed
    }
    
    func toAnyObject() -> Any {
        return [
            "title": title,
            "completed": completed
        ]
    }


}

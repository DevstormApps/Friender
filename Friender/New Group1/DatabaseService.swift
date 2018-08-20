//
//  DatabaseService.swift
//  Friender
//
//  Created by mac on 8/14/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DatabaseService {
    private static let _instance = DatabaseService()

    static var instance: DatabaseService {
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    // add event
    
    // remove event
    
    // request access to event
}

//
//  DatabaseService.swift
//  Friender
//
//  Created by mac on 8/23/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import Firebase

let ref = Database.database().reference()
let user = Auth.auth().currentUser
class DatabaseService {
    static var instance = DatabaseService()
    
    private var _ref = ref
    private var _events = ref.child("events").child(user!.uid)
    
    var events: DatabaseReference {
        return _events
    }
    
}

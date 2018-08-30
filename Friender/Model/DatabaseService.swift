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
    private var _events = ref.child("events")
    private var _users = ref.child("user_profiles")
    private var _accepted = ref.child("accepted")
    private var _accepter = ref.child("accepter")

    

    var events: DatabaseReference {
        return _events
        
    }
    
    var users: DatabaseReference {
        return _users
    }
    
    var accepted: DatabaseReference {
        return _accepted
        
    }
    
    var accepter: DatabaseReference {
        return _accepter
        
    }

    
}

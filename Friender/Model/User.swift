//
//  User.swift
//  Friender
//
//  Created by mac on 8/14/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation

class User {
    var username: String?
    var email: String?
    var friendlist = [String]()
    var currentLocation = [String: String]()
    
    
    init(username: String?, email: String?, friendlist: [String]? , current: [String:String]?){
        self.username = username
        self.email = email
        self.friendlist = friendlist!
        self.currentLocation = current!
    }

}

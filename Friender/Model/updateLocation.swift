//
//  updateLocation.swift
//  Friender
//
//  Created by mac on 8/23/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class updateLocation {
    static var instance = updateLocation()
    var shareLocation = false
    static var shareLocation = false
    
    func updateUserLocation(_ coordinate: CLLocationCoordinate2D) {
        DatabaseService.instance.events.observeSingleEvent(of: .value) { (snapshot) in                                    DatabaseService.instance.events.updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude] ])
        }
    }
    
}
    


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

class pushLocation {
    static var instance = pushLocation()
    
    func pushAnnotationLocation(_ coordinate: CLLocationCoordinate2D, key: String) {
        DatabaseService.instance.events.observe(.value) { (snapshot) in
                    DatabaseService.instance.events.child((user?.uid)!).child(key).updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude] ])
        }
        
    }

    

}

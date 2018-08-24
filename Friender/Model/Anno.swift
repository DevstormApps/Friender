//
//  Anno.swift
//  Friender
//
//  Created by mac on 8/22/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import MapKit

class Anno: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
    func update(_ annotation: Anno, _ coordinate: CLLocationCoordinate2D) {
        var location = self.coordinate
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
        }
    }
}

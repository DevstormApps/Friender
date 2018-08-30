//
//  Anno.swift
//  Friender
//
//  Created by mac on 8/22/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import MapKit
import GoogleSignIn

class Anno: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var key: String
    var image: UIImage
    
    init(coordinate: CLLocationCoordinate2D, key: String, image: UIImage) {
        self.coordinate = coordinate
        self.key = key
        self.image = image
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

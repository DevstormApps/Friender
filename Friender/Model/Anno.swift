//
//  Anno.swift
//  Friender
//
//  Created by mac on 8/22/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation

import Foundation
import MapKit

class Anno: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var pokemonNumber: Int
    
    init(coordinate: CLLocationCoordinate2D, pokemonNumber: Int) {
        self.coordinate = coordinate
        self.pokemonNumber = pokemonNumber
    }
}

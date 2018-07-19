//
//  EeventDataService.swift
//  Friender
//
//  Created by mac on 7/18/18.
//  Copyright © 2018 storm. All rights reserved.
//

import Foundation
import UIKit

class EventDataService {
    
    var date: Date
    var distance: Float
    var eventTitle: UILabel
    var eventImage: UIImage
    
    init(date: Date, distance: Float, eventTitle: UILabel, eventImage: UIImage) {
        self.date = date
        self.distance = distance
        self.eventTitle = eventTitle
        self.eventImage = eventImage
    }

}

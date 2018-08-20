//
//  EventCell.swift
//  Friender
//
//  Created by mac on 7/13/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit

class EventCell: UICollectionViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.eventImage.image = nil
        self.eventTitle.text = nil
    }
    
}

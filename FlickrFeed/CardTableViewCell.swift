//
//  CardTableViewCell.swift
//  FlickrFeed
//
//  Created by Max Tayler on 22/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet var cardView: UIView! // Container view for card item
    @IBOutlet var flickrImage: UIImageView! // Image view for card
    @IBOutlet var imageTitle: UILabel! // Image title label
    @IBOutlet var imageOwner: UILabel! // Image owner label
    @IBOutlet var imageViews: UILabel! // Number of image views label
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 5 // Rounded corners for each card
    }
    
}

//
//  CommentsTableViewCell.swift
//  FlickrFeed
//
//  Created by Max Tayler on 30/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet var buddyIcon: UIImageView! // User Avatar
    @IBOutlet var username: UILabel! // Username
    @IBOutlet var date: UILabel! // Date/Time for comment made
    @IBOutlet var comment: UILabel! // UILabel for comment text
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

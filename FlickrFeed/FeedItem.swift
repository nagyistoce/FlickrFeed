//
//  FlickrItem.swift
//  FlickrFeed
//
//  Created by Max Tayler on 24/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class FeedItem: NSObject {
    
    var imageURL: String! // Flickr image URL
    var imageDescription: String! // Description for image
    var imageOwner: String! // User who uploaded image
    var imageDate: String! // // Image upload date/time
    var imageTitle: String! // Title of image
    var imageViews: String! // Number of image views
    
    var commentText: String! // Text for image comment
    var commentAuthor: String! // User who wrote comment
    var commentDate: String! // Date comment was made
    
    var iconFarm: Int! // Buddy icon farm number
    var iconServer: String! // Buddy icon server
    var iconURL: String! // Buddy icon URL
    
    var userNSID: String! // User ID
    var photoID: String! // Flickr image ID
    var farm: Int! // Flickr image farm number
    var server: String! // Flickr image server
    var secret: String! // Flickr image secret
    
    override init() {
        super.init()
    }
    
}

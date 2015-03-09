//
//  FeedHelper.swift
//  FlickrFeed
//
//  Created by Max Tayler on 28/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class FeedHelper: NSObject {
    
    let apiKey: String = "57aa0a8b7255a41177e5b582dd9479e4"
    
    // Generate flickr url to search by tag
    func URLForSearch(searchString: String!, page: Int) -> String{
        let search: String = searchString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(search)&page=\(page)&per_page=20&sort=relevance&extras=description,owner_name,date_upload,views&format=json&nojsoncallback=1"
    }

    // Generate flickr url to get most interesting photos for current day
    func URLForFeatured(page: Int) -> String {
        return "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=\(apiKey)&page=\(page)&per_page=20&extras=description,owner_name,date_upload,views&format=json&nojsoncallback=1"
    }
    
    // Generate flickr url to get photo comments
    func URLForComments(photoID: String!) -> String{
        return "https://api.flickr.com/services/rest/?method=flickr.photos.comments.getList&api_key=\(apiKey)&photo_id=\(photoID)&format=json&nojsoncallback=1"
    }
    
    // Generate url for single flickr image
    func buildImageURL(_photo: FeedItem) -> String{
        return "http://farm\(_photo.farm).staticflickr.com/\(_photo.server)/\(_photo.photoID)_\(_photo.secret)_z.jpg"
    }
    
    // Generate url for user buddy icon
    func buildBuddyIconURL(_icon: FeedItem) -> String{
        return "http://farm\(_icon.iconFarm).staticflickr.com/\(_icon.iconServer)/buddyicons/\(_icon.userNSID).jpg"
    }
    
    // Search flickr for most interesting/featured photos for current day
    func searchForFeatured(page: Int, completion:(flickrPhotos: NSMutableArray!, error: NSError!)->()){
        let url: String = URLForFeatured(page)
        searchFlickrForPhotosWithUrl(url, completion)
    }
    
    // Search flickr for a given search string
    func searchForString(searchStr: String, page: Int, completion:(flickrPhotos:NSMutableArray!, error:NSError!)->()){
        let url: String = URLForSearch(searchStr, page: page)
        searchFlickrForPhotosWithUrl(url, completion)
    }
    
    // Seach flickr for comments for a given photoID
    func searchForComments(photoID: String, completion:(flickrPhotos:NSMutableArray!, error:NSError!)->()){
        let url: String = URLForComments(photoID)
        searchFlickrForCommentsWithUrl(url, completion)
    }
    
    // Convert a unix time stamp string to an NSDate
    // Format NSDate to produce a more human readable date, e.g. "1 Hour Ago"
    func convertUnixTimeStamp(unixTS: String) -> String{
        // Convert timestamp
        var timestampString = unixTS
        var timestamp = timestampString.toInt()
        var rawDate: NSDate = NSDate(timeIntervalSince1970:NSTimeInterval(timestamp!))
        
        return FormatDate.timeAgoSinceDate(rawDate, numericDates: true) // Format NSDate
    }
    
    // Preform a flickr search using a given url string
    func searchFlickrForPhotosWithUrl(url: String, completion:(flickrPhotos: NSMutableArray!, error: NSError!)->()){
        let queue: dispatch_queue_t  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            var error: NSError?
            // Encode given url string
            let urlString: String! = String(contentsOfURL: NSURL(string: url)!, encoding: NSUTF8StringEncoding, error: &error)
            
            if error != nil{
                completion(flickrPhotos: nil, error: error)
            }else{
                // Parse JSON Response
                let jsonData: NSData! = urlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                let resultDict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
                if error != nil{
                    completion(flickrPhotos: nil, error: error)
                }else{
                    // Check status of JSON Response
                    let status:String! = resultDict.objectForKey("stat") as String
                    // If connection to flickr failed, store reason for error
                    if(status == "fail"){
                        let messageString:String = resultDict.objectForKey("message") as String
                        let error:NSError? = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:messageString])
                        
                        completion(flickrPhotos: nil, error:error )
                    } else{
                        // Show structure of result
                        let flickrPhotosDict: NSDictionary = resultDict.objectForKey("photos") as NSDictionary
                        // Store each flickr photo object in an array
                        let flickrPhotoArray: NSArray = flickrPhotosDict.objectForKey("photo") as NSArray
                        
                        let flickrPhotos: NSMutableArray = NSMutableArray() // Array storing FeedItem objects from loop
                        for flickrObject in flickrPhotoArray {
                            let photoDict: NSDictionary = flickrObject as NSDictionary
                            let item: FeedItem = FeedItem()
                            
                            // Parse each object in flickrPhotoArray
                            item.farm = photoDict.objectForKey("farm") as Int
                            item.server = photoDict.objectForKey("server") as String
                            item.secret = photoDict.objectForKey("secret") as String
                            item.photoID = photoDict.objectForKey("id") as String
                            item.imageDescription = photoDict.objectForKey("description")!.objectForKey("_content") as String
                            item.imageOwner = photoDict.objectForKey("ownername") as String
                            item.imageDate = photoDict.objectForKey("dateupload") as String
                            item.imageViews = photoDict.objectForKey("views") as String
                            item.imageTitle = photoDict.objectForKey("title") as String
                            item.userNSID = photoDict.objectForKey("owner") as String
                            
                            item.imageOwner = item.imageOwner.capitalizedString // Captialise image owner string
                            // Check for empty strings
                            // Set default text if empty
                            item.imageTitle = item.imageTitle.capitalizedString
                            if (item.imageTitle.isEmpty){
                                item.imageTitle = "Untitled Image"
                            }
                            if (item.imageDescription.isEmpty){
                                item.imageDescription = "Sorry. No Image Description Available"
                            }
                            item.imageDescription = item.imageDescription.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                            item.imageViews = item.imageViews + " Views"
                            item.imageOwner = "by " + item.imageOwner
                            
                            let imageDate: String = self.convertUnixTimeStamp(item.imageDate)
                            let flickrItemURL: String = self.buildImageURL(item)
                            item.imageDate = imageDate
                            item.imageURL = flickrItemURL
                            flickrPhotos.addObject(item)
                        }
                        completion(flickrPhotos: flickrPhotos, error: nil)
                    }
                }
            }
        })
    }
    
    // Preform a flickr search using a given url string
    func searchFlickrForCommentsWithUrl(url: String, completion:(flickrComments: NSMutableArray!, error: NSError!)->()){
        let queue: dispatch_queue_t  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            var error: NSError?
            // Encode given url string
            let urlString: String! = String(contentsOfURL: NSURL(string: url)!, encoding: NSUTF8StringEncoding, error: &error)
            
            if error != nil{
                completion(flickrComments: nil, error: nil)
            }else{
                // Parse JSON Response
                let jsonData: NSData! = urlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                
                let resultDict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
                if error != nil{
                    completion(flickrComments: nil, error: nil)
                }else{
                    // Check status of JSON Response
                    let status:String! = resultDict.objectForKey("stat") as String
                    // If connection to flickr failed, store reason for error
                    if(status == "fail"){
                        let messageString:String = resultDict.objectForKey("message") as String
                        let error:NSError? = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:messageString])
                        
                        completion(flickrComments: nil, error: nil)
                    }else {
                        // Show structure of result
                        let flickrCommentsDict: NSDictionary = resultDict.objectForKey("comments") as NSDictionary
                        // If no comments for image, complete task with nil collection
                        if (flickrCommentsDict.objectForKey("comment"))==nil{
                            completion(flickrComments: nil, error:error )
                        }else {
                            // Store each image comment object in an array
                            let flickrCommentArray: NSArray = flickrCommentsDict.objectForKey("comment") as NSArray
                            
                            let photoComments: NSMutableArray = NSMutableArray()// Array storing FeedItem objects from loop
                            for commentObject in flickrCommentArray {
                                let commentDict: NSDictionary = commentObject as NSDictionary
                                let item: FeedItem = FeedItem()
                                
                                // Parse each object in flickrCommentArray
                                item.commentText = commentDict.objectForKey("_content") as String
                                item.commentAuthor = commentDict.objectForKey("authorname") as String
                                item.commentDate = commentDict.objectForKey("datecreate") as String
                                item.iconFarm = commentDict.objectForKey("iconfarm") as Int
                                item.iconServer = commentDict.objectForKey("iconserver") as String
                                item.userNSID = commentDict.objectForKey("author") as String
                                // Check if user has buddyicon
                                // If no icon, set to detault image
                                if(item.iconFarm <= 0){
                                    item.iconURL = "https://www.flickr.com/images/buddyicon.gif"
                                }else{
                                    let iconItemURL: String = self.buildBuddyIconURL(item)
                                    item.iconURL = iconItemURL
                                }
                                
                                let commentDate: String = self.convertUnixTimeStamp(item.commentDate)
                                item.commentDate = commentDate
                                item.commentText = item.commentText.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                                
                                photoComments.addObject(item)
                            }
                            completion(flickrComments: photoComments, error: nil)
                        }
                    }
                }
            }
        })
    }
}
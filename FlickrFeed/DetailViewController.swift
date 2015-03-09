//
//  DetailViewController.swift
//  FlickrFeed
//
//  Created by Max Tayler on 25/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit
import Social

class DetailViewController: UIViewController {
    
    @IBOutlet var largeImage: UIImageView! // UIImageView Main Image
    @IBOutlet var imageTitle: UILabel! // UILabel for Image title
    @IBOutlet var imageDesc: UITextView! // UITextView for Image description
    @IBOutlet var imageViews: UILabel! // UILabel for Number of image views
    @IBOutlet var imageOwner: UILabel! // UILabel for Image owner
    @IBOutlet var imageDate: UILabel! // UILabel for Image upload date/time
    
    var flickrImageURL: String! // URL for largeImage UIImageView
    var flickrImageTitle: String! // Title string for imageTitle label
    var flickrImageDesc: String! // Description string for imageDesc text view
    var flickrImageViews: String! // Number of image views for imageViews label
    var flickrImageOwner: String! // Image owner string for imageOwner label
    var flickrImageDate: String! // Image upload date/time string for imageDate label
    
    var flickrImageID: String! // ImageID for flickr image
    var flickrOwnerID: String! // OwnerID for flickr image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var err: NSError?
        var url = NSURL(string: flickrImageURL)
        var outUrl: String
        
        // Set content for view
        //Load image asynchronously
        ImageLoader.sharedLoader.imageForUrl(flickrImageURL, completionHandler:{(image: UIImage?, outUrl: String) in
            self.largeImage.image = image
        })
        flickrImageTitle = flickrImageTitle.capitalizedString
        imageTitle.text = flickrImageTitle
        imageDesc.text = flickrImageDesc
        imageViews.text = flickrImageViews
        imageOwner.text = flickrImageOwner
        imageDate.text = flickrImageDate

        var backButton =  UIBarButtonItem() //change the back button to only say "Back"
        backButton.title = "Back"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    // Load comments page when comments icon clicked
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let commentsViewController: CommentsTableViewController = segue.destinationViewController as CommentsTableViewController
        commentsViewController.photoID = flickrImageID
    }
    
    // Allow user to share image via social media or save to camera roll
    @IBAction func flickrImageActions(sender: AnyObject) {
        // Set text and image to share
        var textToShare:String = "Hey, checkout this image I found on Flickr \n\n" +
        webFlickrURL()
        let flickrImageToShare : UIImage = largeImage.image!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [textToShare, flickrImageToShare], applicationActivities: nil)
        
        // Exclude irrelevant actions
        activityViewController.excludedActivityTypes = [
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeMail
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // Generate url for image on the flickr main website
    func webFlickrURL() -> String{
        let flickrURL: String = "https://www.flickr.com/photos/\(flickrOwnerID)/\(flickrImageID)"
        return flickrURL
    }
    
}

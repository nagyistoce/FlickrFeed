//
//  FeaturedTableViewController.swift
//  FlickrFeed
//
//  Created by Max Tayler on 22/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class FeaturedTableViewController: UITableViewController {
    
    var flickrItems: NSMutableArray = NSMutableArray() //Array storing FeedItem objects to populate the UITableView
    var pageNumber : Int = 1 // Default page number
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFeaturedPhotos()
    }
    
    // Add most interesting photos for current day to the table view
    func loadFeaturedPhotos(){
        // If device is not connected to internet
        // Present user with error message
        if (!Reachability.isConnectedToNetwork()){
            let alert:UIAlertController = UIAlertController(title: "No Internet Connection", message: "FlickrFeed failed to load images because you are not connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                // Attempt to load photos again
                self.loadFeaturedPhotos()
            }))
            self.navigationItem.title = "Loading Failed"
            self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        // Load first page of photos
        // Add photos to array
        let flickr:FeedHelper = FeedHelper()
        
        // Create loading spinner while flickr items load
        var spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        flickr.searchForFeatured(1, completion: { (flickrPhotos:NSMutableArray!, error:NSError!) -> () in
            if error == nil{
                // Do this on the main queue
                dispatch_async(dispatch_get_main_queue(), {
                    self.flickrItems = NSMutableArray(array: flickrPhotos)
                    self.tableView.reloadData()
                    spinner.stopAnimating() // Dismiss loading spinner
                    self.navigationItem.title = "Popular Today on Flickr"
                })
            } else{
                // In case Flickr API is not responding
                // http://stackoverflow.com/a/17508717 (How to pretty-print an NSError object)
                let alert:UIAlertController = UIAlertController(title: "Flickr Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                    // Attempt to load photos again
                    self.navigationItem.title = "Loading Flickr..."
                    self.loadFeaturedPhotos()
                }))
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    //Add additonal photos to the table view
    func loadAdditionalFeaturedPhotos(){
        // If device is not connected to internet
        // Present user with error message
        if (!Reachability.isConnectedToNetwork()){
            let alert:UIAlertController = UIAlertController(title: "No Internet Connection", message: "FlickrFeed failed to load more images because you are not connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Load More", style: .Default, handler: { action in
                // Attempt to load more photos again
                self.loadAdditionalFeaturedPhotos()
            }))
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        // Load next page of photos
        // Add photos to array
        pageNumber++
        let flickr:FeedHelper = FeedHelper()
        flickr.searchForFeatured(pageNumber, completion: { (flickrPhotos:NSMutableArray!, error:NSError!) -> () in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.flickrItems.addObjectsFromArray(NSMutableArray(array: flickrPhotos))
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    // When refresh button is clicked, reload photos on page
    @IBAction func refreshButton(sender: AnyObject) {
        //Clear flickrItems Array
        flickrItems = NSMutableArray()
        self.tableView.reloadData()
        self.navigationItem.title = "Loading Flickr..."
        
        //Attempt to load photos again
        loadFeaturedPhotos()
    }
    
    // MARK: - Table View
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailView: DetailViewController = segue.destinationViewController as DetailViewController
        // For selected cell
        // Pass required meta data to the detail view
        if segue.identifier == "showDetail" {
            var indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
            let item = self.flickrItems[indexPath.row] as FeedItem
            detailView.flickrImageURL = item.imageURL
            detailView.flickrImageTitle = item.imageTitle
            detailView.flickrImageDesc = item.imageDescription
            detailView.flickrImageViews = item.imageViews
            detailView.flickrImageOwner = item.imageOwner
            detailView.flickrImageDate = item.imageDate
            detailView.flickrImageID = item.photoID
            detailView.flickrOwnerID = item.userNSID
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Card", forIndexPath: indexPath) as CardTableViewCell
        let item = self.flickrItems[indexPath.row] as FeedItem
        var err: NSError?
        var url = item.imageURL
        
        // Set content for each cell in table view
        // Asynchronously load image in table view cells
        cell.flickrImage.image = nil
        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
            cell.flickrImage.image = image
        })
        cell.imageTitle.text = item.imageTitle
        cell.imageViews.text = item.imageViews
        cell.imageOwner.text = item.imageOwner
        
        // At last photo on page load additional photos
        if flickrItems.count - 1 == indexPath.row && flickrItems.count > 19 {
            loadAdditionalFeaturedPhotos()
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flickrItems.count
    }
}


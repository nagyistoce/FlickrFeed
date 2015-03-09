//
//  SearchResultsViewController.swift
//  FlickrFeed
//
//  Created by Max Tayler on 22/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class SearchResultsViewController: UITableViewController, UIActionSheetDelegate {
    
    var searchItems: NSMutableArray = NSMutableArray()
    var searchTerm: String!
    var pageNumber : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSearchPhotos()
    }
    
    // Add list of photos matching search to the table view
    func loadSearchPhotos(){
        // If device is not connected to internet
        // Present user with error message
        if (!Reachability.isConnectedToNetwork()){
            let alert:UIAlertController = UIAlertController(title: "No Internet Connection", message: "FlickrFeed failed to load images because you are not connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                // Return to previous page
                self.navigationController?.popToRootViewControllerAnimated(true)
                return
            }))
            alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                // Attempt to load photos again
                self.loadSearchPhotos()
            }))
            self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            self.navigationItem.title = "Loading Failed"
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
        
        flickr.searchForString(searchTerm, page: 1, completion: { (flickrPhotos:NSMutableArray!, error:NSError!) -> () in
            if error == nil{
                // Do this on the main queue
                dispatch_async(dispatch_get_main_queue(), {
                    self.searchItems = NSMutableArray(array: flickrPhotos)
                    self.tableView.reloadData()
                    spinner.stopAnimating() // Dismiss loading spinner
                    // If no images were found by search, present user with an error message
                    if(self.searchItems.count < 1){
                        let alert:UIAlertController = UIAlertController(title: "Sorry!", message: "There are no photos matching your search", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                            // Return to previous search page
                            self.navigationController?.popToRootViewControllerAnimated(true)
                            return
                        }))
                        self.navigationItem.title = "No Images Found"
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else{
                        // Set to relevant title
                        self.navigationItem.title = self.searchTerm.capitalizedString
                    }
                })
            }else{
                // In case Flickr API is not responding
                // http://stackoverflow.com/a/17508717 (How to pretty-print an NSError object)
                let alert:UIAlertController = UIAlertController(title: "Flickr Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                    // Attempt to load photos again
                    self.loadSearchPhotos()
                }))
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    //Add additonal photos to the table view
    func loadAdditionalSearchPhotos(){
        // If device is not connected to internet
        // Present user with error message
        if (!Reachability.isConnectedToNetwork()){
            let alert:UIAlertController = UIAlertController(title: "No Internet Connection", message: "FlickrFeed failed to load more images because you are not connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Load More", style: .Default, handler: { action in
                // Attempt to load more photos again
                self.loadAdditionalSearchPhotos()
            }))
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            self.navigationItem.title = "Loading Failed"
            return
        }
        // Load next page of photos
        // Add photos to array
        pageNumber++
        let flickr:FeedHelper = FeedHelper()
        flickr.searchForString(searchTerm, page: pageNumber, completion: { (flickrPhotos:NSMutableArray!, error:NSError!) -> () in
            if error == nil{
                // Do this on the main queue
                dispatch_async(dispatch_get_main_queue(), {
                    self.searchItems.addObjectsFromArray(NSMutableArray(array: flickrPhotos))
                    self.tableView.reloadData()
                    // Set to relevant title
                    self.navigationItem.title = self.searchTerm.capitalizedString
                })
            }else{
                // In case Flickr API is not responding
                // http://stackoverflow.com/a/17508717 (How to pretty-print an NSError object)
                let alert:UIAlertController = UIAlertController(title: "Flickr Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Load More", style: .Default, handler: { action in
                    // Attempt to load more photos again
                    self.loadAdditionalSearchPhotos()
                }))
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    // Present action sheet when safari bar button clicked
    @IBAction func openWithBrowser(sender: AnyObject) {
        var actionSheet: UIActionSheet = UIActionSheet();
        let title: String = "Open with";
        actionSheet.title  = title;
        actionSheet.delegate = self;
        // Add user options to action sheet
        actionSheet.addButtonWithTitle("Cancel");
        actionSheet.addButtonWithTitle("Google Images");
        actionSheet.addButtonWithTitle("Wikipedia");
        actionSheet.cancelButtonIndex = 0;
        actionSheet.showInView(self.view);
    }
    
    // Preform search by action sheet title selection
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        let searchString: String = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        switch buttonIndex{
        case 0:
            NSLog("Cancel")
            break
        case 1:
            // Search via google images
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.google.com/search?q=\(searchString)&tbm=isch")!)
            break
        case 2:
            // Search via wikipedia
            UIApplication.sharedApplication().openURL( NSURL(string: "http://en.wikipedia.org/wiki/\(searchString)")!)
            break
        default:
            break
        }
    }
    
    // MARK: - Table View
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailView: DetailViewController = segue.destinationViewController as DetailViewController
        // For selected cell
        // Pass required meta data to the detail view
        if segue.identifier == "showDetail" {
            var indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
            let item = self.searchItems[indexPath.row] as FeedItem
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
        let item = self.searchItems[indexPath.row] as FeedItem
        var err: NSError?
        var url = item.imageURL as NSString
        
        // Set content for each cell in table view
        // Asynchronously load image in table view cells
        cell.flickrImage.image = nil
        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
            cell.flickrImage.image = image
        })
        cell.imageTitle.text = item.imageTitle
        cell.imageViews.text = "\(item.imageViews) Views"
        cell.imageOwner.text = item.imageOwner
        
        // At last photo on page load additional photos
        if searchItems.count - 1 == indexPath.row && searchItems.count > 19 {
            loadAdditionalSearchPhotos()
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }
}
//
//  CommentsTableViewController.swift
//  FlickrFeed
//
//  Created by Max Tayler on 30/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    var commentItems: NSMutableArray = NSMutableArray() //Array storing FeedItem objects to populate the UITableView
    var photoID: String! // PhotoID for comments
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up variable tableView height & ensure correct background color
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(red: 0.937, green:0.937, blue:0.957, alpha:1)
        
        loadComments()
    }
    
    // Add list of comments for photo to the table view
    func loadComments(){
        // If device is not connected to internet
        // Present user with error message
        if (!Reachability.isConnectedToNetwork()){
            let alert:UIAlertController = UIAlertController(title: "No Internet Connection", message: "FlickrFeed failed to load images because you are not connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                // Return to previous page
                self.navigationController?.popViewControllerAnimated(true)
                return
            }))
            alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                // Attempt to load comments again
                self.loadComments()
            }))
            self.navigationItem.title = "Loading Failed"
            self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        // Load comments for photo
        // Add comments to array
        let flickr:FeedHelper = FeedHelper()
        
        // Create loading spinner while flickr items load
        var spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        flickr.searchForComments(photoID, completion: { (flickrComments:NSMutableArray!, error:NSError!) -> () in
            if error == nil{
                // Do this on the main queue
                dispatch_async(dispatch_get_main_queue(), {
                    // If no comments were found, present user with an error message
                    if flickrComments == nil {
                        let alert:UIAlertController = UIAlertController(title: "Sorry!", message: "There are no comments for this photo", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                            // Return to previous page
                            self.navigationController?.popViewControllerAnimated(true)
                            return
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else{
                        var sortedFlickrComments: NSArray = flickrComments.reverseObjectEnumerator().allObjects // Sort comments to most recent first
                        self.commentItems = NSMutableArray(array: sortedFlickrComments)
                        self.tableView.reloadData()
                        spinner.stopAnimating()
                    }
                    self.navigationItem.title = "Comments (\(self.commentItems.count))"
                })
            }else{
                // In case Flickr API is not responding
                // http://stackoverflow.com/a/17508717 (How to pretty-print an NSError object)
                let alert:UIAlertController = UIAlertController(title: "Flickr Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                    // Attempt to load photos again
                    self.loadComments()
                }))
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as CommentsTableViewCell
        let item = self.commentItems[indexPath.row] as FeedItem
        var err: NSError?
        var url = item.iconURL as NSString
        
        // Set content for each cell in table view
        // Asynchronously load buddy icon in table view cells
        cell.buddyIcon.image = nil
        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
            cell.buddyIcon.image = image
        })
        cell.username.text = item.commentAuthor
        cell.date.text = item.commentDate
        cell.comment.text = item.commentText
        return cell
    }
}

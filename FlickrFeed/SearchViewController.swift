//
//  SearchViewController.swift
//  FlickrFeed
//
//  Created by Max Tayler on 27/12/2014.
//  Copyright (c) 2014 Max Tayler. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // Set up tap recognizer. 
        // When user clicks anywhere on view which is not the search bar, dismiss keyboard.
        let tapToDismiss = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapToDismiss)
    }
    
    // Remove all text from search bar when cancel button is clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    // Dismiss keyboard when user taps away from the search bar
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    // Preform search when search button on keyboard is clicked
    func searchBarSearchButtonClicked(searchBar: UISearchBar!){
        let searchResultsController : SearchResultsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchResults") as SearchResultsViewController
        
        searchResultsController.searchTerm = searchBar.text
        self.showViewController(searchResultsController as SearchResultsViewController, sender: nil)// open results view controller
    }
    
    // Preform search when bar button item is clicked
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Ensure text is not empty
        // Preform search
        if !(searchBar.text.isEmpty){
            let destinationViewController : SearchResultsViewController = segue.destinationViewController as SearchResultsViewController
            destinationViewController.searchTerm = searchBar.text
        }else {
            // If text is empty
            // Present user with error message
            let alert:UIAlertController = UIAlertController(title: "Error", message: "Please enter a search term", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

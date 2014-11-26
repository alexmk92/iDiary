//
//  EntryListViewController.swift
//  Diary
//
//  Created by Alex Sims on 24/11/2014.
//  Copyright (c) 2014 Alexander Sims. All rights reserved.
//

import UIKit
import CoreData

class EntryListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var _fetchedResultsController: NSFetchedResultsController?
    private var _entryCell = THEntryCell()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.fetchedResultsController().performFetch(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if self.fetchedResultsController().sections!.count >= 0 {
            return self.fetchedResultsController().sections!.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        // Get the amount of rows from the fetch request controller and return them.
        let rows: NSFetchedResultsSectionInfo = self.fetchedResultsController().sections![section] as NSFetchedResultsSectionInfo

        return rows.numberOfObjects
    }
    
    func entryListFetchRequest() -> NSFetchRequest {
        
        // Build the fetch request object
        let fr:NSFetchRequest = NSFetchRequest(entityName: "THDiaryEntry")
        
        // Array of sort descriptors
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        fr.sortDescriptors = [sortByDate]
        return fr
    }
    
    // The delegate allow us to refresh table view - we override the default instanciation with our own constructor here.
    func fetchedResultsController() -> NSFetchedResultsController {
        // Check if we already have an fetchedRequestsController
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        // Build a new fetchedRequest controller
        var dataStack:CoreDataStack = CoreDataStack.sharedInstance
        var fr:NSFetchRequest = self.entryListFetchRequest()
        
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: dataStack.managedObjectContext!, sectionNameKeyPath: "sectionName", cacheName: nil)
        
        // Set the delegate of the controller.
        _fetchedResultsController?.delegate = self

        return _fetchedResultsController!
    }
    

    // Provide a custom animation - begin update, commit update, end update - this replaces controllerDidChangeContent implementation?
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    // Provide an insertion and deletion animation
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
            case .Insert:
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            case .Update:
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            default:
                return
        }
    }
    
    // Stop app from crashing when deleting last row
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        // Create an index set and then set up the animations
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch(type) {
            case .Insert:
                self.tableView.insertSections(indexSet, withRowAnimation: .Automatic)
            case .Delete:
                self.tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
            default:
                return
        }
    }
    
    // Once a NSFetchedResultsController Delegate has been returned, this method is called and reloads the table data
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> THEntryCell {
        
        // Create the cell and entry objects
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as THEntryCell
        let entry = self.fetchedResultsController().objectAtIndexPath(indexPath) as DiaryEntry
        
        // Configure the cell...
        cell.configureCellForEntry(entry)

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo:NSFetchedResultsSectionInfo = self.fetchedResultsController().sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    
    // The two fucntions below handle the deletion of a cell from the list
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let entry:DiaryEntry = self.fetchedResultsController().objectAtIndexPath(indexPath) as DiaryEntry
        
        let dataStack = CoreDataStack.sharedInstance
        
        // Delete the object and commit the changes
        dataStack.managedObjectContext?.deleteObject(entry)
        dataStack.saveContext()
    }
    
    // Return the height of the cell based on the entry we have provided
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let entry = self.fetchedResultsController().objectAtIndexPath(indexPath) as DiaryEntry
        let height = _entryCell.getHeightForEntry(entry)
        
        return height
    }
    

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Perform checking on which segue we are using
        if segue.identifier == "edit" {
            let cell = sender as THEntryCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let navigationController = segue.destinationViewController as UINavigationController
            
            // Returns a THEntryViewController from the UINavigationController object as it gets the top child
            let viewController = navigationController.topViewController as THEntryViewController
            
            // Send the information to the controller
            viewController.entry = self.fetchedResultsController().objectAtIndexPath(indexPath!) as DiaryEntry
        }
    }
    

}

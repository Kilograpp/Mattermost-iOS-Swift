//
//  ChatViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 25.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import SlackTextViewController
import RealmSwift
import SwiftFetchedResultsController

class ChatViewController: SLKTextViewController {
    private var channel : Channel?
    lazy var fetchedResultsController: FetchedResultsController<Post> = self.setupFetchedResultsController()
    var realm: Realm?
    
    //MARK: Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Grouped
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.fetchedResultsController.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "asdas"//self.fetchedResultsController.titleForHeaderInSection(section)
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.transform = tableView.transform
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath)
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "cell")
        }
        
        // Configure the cell...
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)! as Post
        
        cell!.textLabel?.text = object.message
        cell!.transform = tableView.transform
        
        return cell!
    }

    
    func setupFetchedResultsController() -> FetchedResultsController<Post> {
        let predicate = NSPredicate(format: "privateChannelId = %@", self.channel?.identifier ?? "")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Post>(realm: realm, predicate: predicate)
        
        let sortDescriptorSection = SortDescriptor(property: "createdAt", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptorSection]
        
        let fetchedResultsController = FetchedResultsController<Post>(fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: "testCache")
        
        fetchedResultsController.delegate = self
        
        fetchedResultsController.performFetch()
        
        return fetchedResultsController

    }
    
    
    
}


// MARK: - FetchedResultsControllerDelegate

extension ChatViewController: FetchedResultsControllerDelegate {
    func controllerWillChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        self.tableView!.beginUpdates()
    }
    
    func controllerDidChangeObject<T : Object>(controller: FetchedResultsController<T>, anObject: SafeObject<T>, indexPath: NSIndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let tableView = self.tableView
        
        switch changeType {
            
        case .Insert:
            
            tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Delete:
            
            tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Update:
            
            tableView!.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Move:
            
            tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controllerDidChangeSection<T : Object>(controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
        
        let tableView = self.tableView
        
        if changeType == NSFetchedResultsChangeType.Insert {
            
            let indexSet = NSIndexSet(index: Int(sectionIndex))
            
            tableView!.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if changeType == NSFetchedResultsChangeType.Delete {
            
            let indexSet = NSIndexSet(index: Int(sectionIndex))
            
            tableView!.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controllerDidChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        self.tableView!.endUpdates()
    }
    
    func controllerWillPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}
    func controllerDidPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}
}



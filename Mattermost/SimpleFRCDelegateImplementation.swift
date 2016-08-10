//
//  SimpleFRCDelegateImplementation.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftFetchedResultsController

final class SimpleFRCDelegateImplementation: FetchedResultsControllerDelegate{
    private let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {return nil}
    
    
    func controllerWillChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeObject<T : Object>(controller: FetchedResultsController<T>, anObject: SafeObject<T>, indexPath: NSIndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch changeType {
            
        case .Insert:
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .None)
            
        case .Delete:
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            
        case .Update:
            
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            
        case .Move:
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .None)
        }
    }
    
    func controllerDidChangeSection<T : Object>(controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
        
        let tableView = self.tableView
        
        if changeType == .Insert {
            
            let indexSet = NSIndexSet(index: Int(sectionIndex))
            
            tableView.insertSections(indexSet, withRowAnimation: .None)
        }
        else if changeType == .Delete {
            
            let indexSet = NSIndexSet(index: Int(sectionIndex))
            
            tableView.deleteSections(indexSet, withRowAnimation: .None)
        }
    }
    
    func controllerDidChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}
    func controllerDidPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}

    
}
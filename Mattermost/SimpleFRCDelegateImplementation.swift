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
    
    private var insertedSections = NSMutableIndexSet()
    private var deletedSections = NSMutableIndexSet()
    private var updatedRows = [NSIndexPath]()
    private var deletedRows = [NSIndexPath]()
    private var insertedRows = [NSIndexPath]()
    private var movedRows = [NSIndexPath]()
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {return nil}
    
    
    func controllerWillChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        insertedSections = NSMutableIndexSet()
        deletedSections = NSMutableIndexSet()
        insertedRows.removeAll()
        deletedRows.removeAll()
        updatedRows.removeAll()
        movedRows.removeAll()
    }
    
    func controllerDidChangeObject<T : Object>(controller: FetchedResultsController<T>, anObject: SafeObject<T>, indexPath: NSIndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        
        switch changeType {
            
        case .Insert:
            self.insertedRows.append(newIndexPath!)
            
        case .Delete:
            self.deletedRows.append(indexPath!)
            
        case .Update:
            self.updatedRows.append(indexPath!)
            
        case .Move: break
        }
    }
    
    func controllerDidChangeSection<T : Object>(controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
        
        
        if changeType == .Insert {
            self.insertedSections.addIndex(Int(sectionIndex))
        } else if changeType == .Delete {
            self.deletedSections.addIndex(Int(sectionIndex))
        }
    }
    
    func controllerDidChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        
        let totalChanges = self.deletedSections.count + self.insertedSections.count + self.insertedRows.count + self.deletedRows.count
        print(totalChanges)
        
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()

        self.tableView.deleteSections(self.deletedSections, withRowAnimation: .None)
        self.tableView.insertSections(self.insertedSections, withRowAnimation: .None)
        self.tableView.deleteRowsAtIndexPaths(self.deletedRows, withRowAnimation: .None)
        self.tableView.insertRowsAtIndexPaths(self.insertedRows, withRowAnimation: .None)
        
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func controllerWillPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}
    func controllerDidPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}

    
}
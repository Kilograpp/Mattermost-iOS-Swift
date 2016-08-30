//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


// FIXME: Code Review: Расставить MARK по всему файлу
import Foundation
import RealmSwift
// FIXME: Code Review: Убрать контроллер
import SwiftFetchedResultsController

// FIXME: Code Review: Финальный класс
// FIXME: Code Review: Опечатка MoreChannelS
class MoreChannelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    // FIXME: Code Review: Заменить на обычный results
    lazy var fetchedResultsController: FetchedResultsController<Channel> = self.realmFetchedResultsController()
    // FIXME: Code Review: Убрать
    var realm: Realm?
    // FIXME: Code Review: Опечатка
    // FIXME: Code Review: Убрать internal
    // FIXME: Code Review: Сделать Bool не optional
    // FIXME: Code Review: Вынести в приватный протокол интерфейсных методов
    internal var isPriviteChannel : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        realmFetchedResultsController()
        setupTableView()
    }
    
    // FIXME: Code Review: В приватные методы с приватным протоколом(Configuration), который объявляется после класса
    func setupNavigationBar() {
        // FIXME: Code Review: Локализовать
        self.title = "More Channel"
    }
    
    // FIXME: Code Review: В приватные методы
    func setupTableView () {
        // FIXME: Code Review: Если таблица формируется из Storyboard, то делегаты там же надо ставить
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
    }
    
}


extension MoreChannelViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // FIXME: Code Review: Сегу константой
        // FIXME: Code Review: Вынести в отдельный метод говорящий
        performSegueWithIdentifier("showChatViewController", sender: self.fetchedResultsController.objectAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // FIXME: Code Review: Сегу константой
        // FIXME: Code Review: Условие гардом
        // FIXME: Code Review: Нужно ли вообще условие?
        if (segue.identifier == "showChatViewController") {
            guard let selectedChannel = sender as? Channel else { return }
            ChannelObserver.sharedObserver.selectedChannel = selectedChannel
        }
    }
}

extension MoreChannelViewController : UITableViewDataSource {

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // FIXME: Code Review: Reuse identifier вынести в ячейку
        // FIXME: Code Review: Как насчет доставать из очереди?
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        // FIXME: Code Review: Конфигурация должна быть внутри ячейки
        cell.backgroundView?.tintColor = ColorBucket.whiteColor
        cell.textLabel?.tintColor = ColorBucket.blackColor
        configureCellAtIndexPath(cell, indexPath: indexPath)
        
        return cell
    }
    
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        // FIXME: Code Review: Сделать на уровне фильтра
        if (self.isPriviteChannel != nil && self.isPriviteChannel == true) {
            if (indexPath.section == 1) {
                let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
                cell.textLabel?.text = channel?.displayName
            }

        } else {
            if (indexPath.section == 0) {
                let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
                cell.textLabel?.text = channel?.displayName
            }
        }
    }
}

extension MoreChannelViewController  {
    
    func realmFetchedResultsController() -> FetchedResultsController<Channel> {
        // FIXME: CodeReview: Заменить identifier на attribute из enum
        
        let predicate = NSPredicate(format: "identifier != %@ ", "fds")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Channel>(realm: realm, predicate: predicate)
        fetchRequest.predicate = nil

        let sortDescriptorSection = SortDescriptor(property: ChannelAttributes.privateType.rawValue, ascending: false)
        let sortDescriptorName = SortDescriptor(property: ChannelAttributes.displayName.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorSection, sortDescriptorName]
        let fetchedResultsController = FetchedResultsController<Channel>(fetchRequest: fetchRequest,
                                                                         sectionNameKeyPath: ChannelAttributes.privateType.rawValue,
                                                                         cacheName: nil)
        fetchedResultsController.delegate = nil
        fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
}

//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class MoreChannelsViewController: UIViewController {
    
    // CODEREVIEW: Лишняя марка
//MARK: Property
    
    @IBOutlet weak var tableView: UITableView!
    
    // CODEREVIEW: Реалму нечего делать в контроллере
    var realm: Realm?
    fileprivate lazy var builder: MoreCellBuilder = MoreCellBuilder(tableView: self.tableView)
    // CODEREVIEW: Переменная названа странно, не понятно за что отвечает. И если это костанта, то имеет смысл вынести в статичные переменные.
    fileprivate let showChatViewController = "showChatViewController"
    
    // CODEREVIEW: Избыточная инициализация
    fileprivate var results: Results<Channel>! = nil
    fileprivate var filteredResults: Results<Channel>! = nil
    
    // CODEREVIEW: Если это внутренние переменные, то они должны быть fileprivate
    var isPrivateChannel: Bool = false
    var isSearchActive: Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
}


// CODEREVIEW: Протоколы должны быть FilePrivate
// CODEREVIEW: Названия должны быть коротки: LifeCycle
// CODEREVIEW: viewDidLoad избыточно объявлять в протоколе, это уже существующий метод.
private protocol MoreChannelsViewControllerLifeCycle {
    func viewDidLoad()
}

private protocol MoreChannelsViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
}

private protocol MoreChannelsViewControllerConfiguration : class {
    var isPrivateChannel : Bool {get set}
    func prepareResults()
}

private protocol MoreChannelsViewControllerRequests {
    func loadChannels()
}

private protocol MoreChannelsViewControllerAction {
    func backAction()
    func addDoneAction()
}

private protocol MoreChannelsViewControllerNavigation {
    func returnToChannel()
}

//MARK: LifeCycle

// CODEREVIEW: viewDidLoad должны быть внутри класса. override в extension часто вокусы крутит в релизе
extension MoreChannelsViewController: MoreChannelsViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        prepareResults()
        loadChannels()
    }
}


//MARK: Setup
// CODEREVIEW: Сетапы должны быть приватными(fileprivate)
extension MoreChannelsViewController: MoreChannelsViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        self.title = self.isPrivateChannel ? "Add Users".localized : "More Channel".localized
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let addDoneTitle = self.isPrivateChannel ? "Done".localized : "Add".localized
        let addDoneButton = UIBarButtonItem.init(title: addDoneTitle, style: .done, target: self, action: #selector(addDoneAction))
        self.navigationItem.rightBarButtonItem = addDoneButton
    }
    
    func setupTableView() {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.register(ChannelsMoreTableViewCell.self, forCellReuseIdentifier: ChannelsMoreTableViewCell.reuseIdentifier, cacheSize: 10)
    }
}


//MARK: Configuration

extension  MoreChannelsViewController: MoreChannelsViewControllerConfiguration  {
    func prepareResults() {
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        // CODEREVIEW: Нужно использовать аттрибут канала, а не константу privateType
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
        // CODEREVIEW: Лишние логи
        print("channels = ", self.results.count)
        
        let users = RealmUtils.realmForCurrentThread().objects(User.self)
        // CODEREVIEW: Лишнее логи
        print("users = ", users.count)
    }
}


extension MoreChannelsViewController: MoreChannelsViewControllerRequests {
    func loadChannels() {
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
}


// CODEREVIEW: Новой строки между маркой и extension быть не должно. И далее тоже.
//MARK: Action

extension MoreChannelsViewController: MoreChannelsViewControllerAction {
    // CODEREVIEW: Мертвый код внутри метода
    func backAction() {
        //loadChannels()
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
         //   self.prepareResults()
         //   self.tableView.reloadData()
            self.returnToChannel()
        }
    }
    
    // CODEREVIEW: Название не понятное. Нужно как-то переименовать, либо поправить синтаксис.
    func addDoneAction() {
        // CODEREVIEW: Лишний пробел после self
        for channel in self .results {
            RealmUtils.save(channel)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
    }
}


//MARK: Navigation

extension MoreChannelsViewController: MoreChannelsViewControllerNavigation {
    // CODEREVIEW: Вместо return лучше moveBack
    // CODEREVIEW: Метод должен быть fileprivate, так как не используется снаружи.
    func returnToChannel() {
        // CODEREVIEW: Поджопник избыточен
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: UITableViewDataSource

extension MoreChannelsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isSearchActive) ? self.filteredResults.count : self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // CODEREVIEW: Скобочки избыточны
        let channel = (self.isSearchActive) ? self.filteredResults[indexPath.row] : self.results[indexPath.row]
        let cell = self.builder.cellFor(channel: channel)

        return cell
    }
}


//MARK: UITableViewDelegate

extension MoreChannelsViewController : UITableViewDelegate {
    // CODEREVIEW: Пустой метод, смерть ему.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
}


//MARK: UISearchBarDelegate

extension MoreChannelsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // CODEREVIEW: Точка с запятой лишняя
        self.isSearchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // CODEREVIEW: Точка с запятой лишняя
        self.isSearchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // CODEREVIEW: Точка с запятой лишняя
        self.isSearchActive = false;
        self.tableView.reloadData()
        self.filteredResults = nil;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // CODEREVIEW: Точка с запятой лишняя
        self.isSearchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate = NSPredicate(format: "displayName BEGINSWITH[c] %@", searchText)
        self.filteredResults = self.results.filter(predicate)
        self.tableView.reloadData()
    }
}

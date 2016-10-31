//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

// CODEREVIEW: Foundation избыточен, он уже есть в RealmSwift
import Foundation
import RealmSwift

// CODEREVIEW: Если тупль содержит в себе user или channel, то значит надо выявить общее в них, сделать для этого протокол, которому должны отвечать оба класса и уже работать с ними как с генериками
typealias ResultTuple = (object: RealmObject, checked: Bool)

final class MoreChannelsViewController: UIViewController {
    
    // CODEREVIEW: Лишняя марка
//MARK: Property
    
    @IBOutlet weak var tableView: UITableView!
    
    // CODEREVIEW: Здесь не должен быть realm
    var realm: Realm?
    fileprivate lazy var builder: MoreCellBuilder = MoreCellBuilder(tableView: self.tableView)
    fileprivate let showChatViewController = "showChatViewController"
    
    fileprivate var results: Array<ResultTuple>! = Array()
    fileprivate var filteredResults: Array<ResultTuple>! = Array()
    
   // CODEREVIEW: Мертвый код
   // fileprivate var results: Results<Channel>! = nil
    //fileprivate var filteredResults: Results<Channel>! = nil
    
    // CODEREVIEW: Переменные должны быть fileprivate
    var isPrivateChannel: Bool = false
    var isSearchActive: Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
}

// CODEREVIEW: Протоколы должны быть fileprivate внутренние
// CODEREVIEW: Для viewDidLoad не нужен протокол, это стандартнйы метод
// CODEREVIEW: Все протоколы слишком длинные. Так как они приватные, то достаточно Setup, Configuration, Actions и тп.
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

/*private protocol MoreChannelsViewControllerRequests {
    func loadChannels()
}*/

private protocol MoreChannelsViewControllerAction {
    func backAction()
    func addDoneAction()
}

private protocol MoreChannelsViewControllerNavigation {
    // CODEREVIEW: Лучше назвать moveBackToChannel
    func returnToChannel()
}

private protocol MoreChannelsViewControllerRequest {
    func loadChannels()
    func loadAllChannels()
    func joinTo(channel: Channel)
    func leave(channel: Channel)
    func createDirectChannelWith(result: ResultTuple)
    func updatePreferencesSave(result: ResultTuple)
}

//MARK: LifeCycle
// CODEREVIEW: viewDidLoad не должен быть в extension.
extension MoreChannelsViewController: MoreChannelsViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        // CODEREVIEW: Нарушение абстракции
        if self.isPrivateChannel {
            loadChannels()
            // CODEREVIEW: Скобка не на том уровне
        }
        else {
            loadAllChannels()
        }
        // CODEREVIEW: Мертвый код
        
       // loadChannels()
    }
}


//MARK: Setup
// CODEREVIEW: Методы внутренние должны быть private/fileprivate
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
        // CODEREVIEW: Лишние скобочки
        if (self.isPrivateChannel) {
            prepareUserResults()
        }
        else {
            prepareChannelResults()
        }
        
        // CODEREVIEW: Мертвый код
        /*
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
        
        print(self.results[0])
        
        let users = RealmUtils.realmForCurrentThread().objects(User.self)
        
        for user in users {
            
        }
        
        print("users = ", users.count)*/
    }


    func prepareChannelResults() {
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        // CODEREVIEW: Должен быть атрибут
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
     //   self.results.removeAll()
        for channel in channels {
            self.results?.append((channel, channel.currentUserInChannel))
        }
    }
    
    func prepareUserResults() {
        let sortName = UserAttributes.username.rawValue
        // CODEREVIEW: Должен быть атрибут
        let predicate =  NSPredicate(format: "identifier != %@", Constants.Realm.SystemUserIdentifier)
        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
     //   self.results.removeAll()
        for user in users {
            self.results?.append((user, user.hasChannel()))
        }
    }
    
    func saveResults() {
        if self.isPrivateChannel {
            saveUserResults()
            // CODEREVIEW: Скобочки должны быть на уровне с else
        }
        else {
            saveChannelResults()
        }
    }
    
    func saveChannelResults() {
        for resultTuple in self.results {
            let channel = (resultTuple.object as! Channel)
            // CODEREVIEW: Лишние скобочки
            guard (channel.currentUserInChannel != resultTuple.checked) else { continue }
            
            if resultTuple.checked {
                joinTo(channel: channel)
                // CODEREVIEW: Скобочки должны быть на уровне с else
            }
            else {
                leave(channel: channel)
            }
        }
    }
    
    func saveUserResults() {
        for resultTuple in self.results {
            if !(resultTuple.object as! User).hasChannel() {
                // CODEREVIEW: createDirectChannel(withResult)
                createDirectChannelWith(result: resultTuple)
                // CODEREVIEW: Скобочка не на том уровне
            }
            else {
                updatePreferencesSave(result: resultTuple)
            }
        }
    }
}
// CODEREVIEW: Мертвый код

/*
extension MoreChannelsViewController: MoreChannelsViewControllerRequests {
    func loadChannels() {
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
}*/


//MARK: Action

extension MoreChannelsViewController: MoreChannelsViewControllerAction {
    // CODEREVIEW: Мертвый код
    func backAction() {
        //loadChannels()
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            // CODEREVIEW: Мертвый код
         //   self.prepareResults()
         //   self.tableView.reloadData()
            self.returnToChannel()
        }
    }
    
    // CODEREVIEW: Мертвый код
    // CODEREVIEW: Странное название, не получается перевести.
    func addDoneAction() {
      //  for channel in self.results {
       //     RealmUtils.save(channel)
//        }
        
        saveResults()
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
    }
}


//MARK: Navigation

extension MoreChannelsViewController: MoreChannelsViewControllerNavigation {
    func returnToChannel() {
        // CODEREVIEW: Нужен ли здесь _?
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: MoreChannelsViewControllerRequest
// CODEREVIEW: Если это все внутренние методы, то они должны быть fileprivate
extension MoreChannelsViewController: MoreChannelsViewControllerRequest {
    func loadChannels() {
        Api.sharedInstance.loadChannels { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
    
    func loadAllChannels() {
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
    
    // CODEREVIEW: Достаточно join(channel)
    func joinTo(channel: Channel) {
        Api.sharedInstance.joinChannel(channel) { (error) in
            // CODEREVIEW: Скобочки лишние
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
        }
    }
    
    func leave(channel: Channel) {
        Api.sharedInstance.leaveChannel(channel) { (error) in
            // CODEREVIEW: Лишние скобочки
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
        }
    }
    
    func createDirectChannelWith(result: ResultTuple) {
        // CODEREVIEW: Лишние скобочки. Короче, надо все привести к тому, что не надо было кастовать к юзеру или каналу. Должна быть какая-то общность у них через протокол
        guard  (result.checked != (result.object as! User).hasChannel()) else { return }
        
        Api.sharedInstance.createDirectChannelWith((result.object as! User)) { (channel, error) in
            // CODEREVIEW: Лишняя скобочка
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            
            self.updatePreferencesSave(result: result)
            // CODEREVIEW: Лишние логи
            print(channel)
        }
    }
    
    // CODEREVIEW: Название не по-русски какое-то. Либо словое save избыточно, либо еще как-то переименовать нужно
    func updatePreferencesSave(result: ResultTuple) {
        
        let user = (result.object as! User)
        // CODEREVIEW: Должна быть не константа, а атрибут класса
        let predicate =  NSPredicate(format: "displayName == %@", user.username!)
        let channel = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).first
        
        try! RealmUtils.realmForCurrentThread().write {
            // CODEREVIEW: Если checked уже булевая переменная, то зачем тернарный оператор?
            channel?.currentUserInChannel = result.checked ? true : false
        }
        
        // CODEREVIEW: Тип избыточно тут указывать. А словари в swift делаются как [String : String]
        // CODEREVIEW: Все значения должны быть с новой строки. Сейчас категория выбивается
        let preferences: Dictionary<String, String> = [ "category" : "direct_channel_show",
                            "name" : (result.object as! User).identifier,
                            "user_id" : (DataManager.sharedInstance.currentUser?.identifier)!,
                            "value" : result.checked ? "true" : "false"
        ]
        
        Api.sharedInstance.savePreferencesWith(preferences) { (error) in
            // CODEREVIEW: Лишние скобочки и мертвйы код
            guard (error == nil) else {
                //AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
        }
    }
}


//MARK: UITableViewDataSource

extension MoreChannelsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // CODEREVIEW: Лишние логи
        print("count = ", self.results.count)
        print("countFiltered = ", self.filteredResults.count)
        // CODEREVIEW: Лишние скобочки
        return (self.isSearchActive) ? self.filteredResults.count : self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var resultTuple = self.isSearchActive ? self.filteredResults[indexPath.row] : self.results[indexPath.row]
        // CODEREVIEW: Название метода должно быть cell(forTuple)
        let cell = self.builder.cellFor(resultTuple: resultTuple)
        // CODEREVIEW: Есть же билдер, это должно быть там.
        (cell as! ChannelsMoreTableViewCell).checkBoxHandler = {
            resultTuple.checked = !resultTuple.checked
            if self.isSearchActive {
                self.filteredResults[indexPath.row] = resultTuple
                let realIndex = self.results.index(where: { return ($0.object == resultTuple.object) })
                self.results[realIndex!] = resultTuple
                // CODEREVIEW: Скобочки на уровне с els
            }
            else {
                self.results[indexPath.row] = resultTuple
            }
        }

        return cell
    }
}


//MARK: UITableViewDelegate

extension MoreChannelsViewController : UITableViewDelegate {
    // CODEREVIEW:  Gecnjq vvtnjl
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
}


//MARK: UISearchBarDelegate
// CODEREVIEW: Удалить везде лишние ;
extension MoreChannelsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearchActive = false;
        self.tableView.reloadData()
        self.filteredResults = nil;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.isSearchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredResults = self.results.filter({
            if self.isPrivateChannel {
                // CODEREVIEW: Нужно сделать протокол displayable(или около того), который объединяет в себе displayName. Чтобы не делать такие условия.
                return (($0.object as! User).displayName?.hasPrefix(searchText))!
            }
            else {
                return (($0.object as! Channel).displayName?.hasPrefix(searchText))!
            }
        })
        self.tableView.reloadData()
    }
}

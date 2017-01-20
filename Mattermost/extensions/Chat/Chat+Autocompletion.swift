//
//  Chat+Autocompletion.swift
//  Mattermost
//
//  Created by TaHyKu on 12.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

//MARK: AutoCompletionView
extension ChatViewController {
    func setupTableViewForAutocompletion() {
        self.autoCompletionView.register(EmojiTableViewCell.classForCoder(), forCellReuseIdentifier: EmojiTableViewCell.reuseIdentifier)
        let nib = UINib(nibName: "MemberLinkTableViewCell", bundle: nil)
        self.autoCompletionView.register(nib, forCellReuseIdentifier: "memberLinkTableViewCell")
        self.registerPrefixes(forAutoCompletion: ["@", ":"])
    }
    
    func didSelectAutocompleteRowAt(indexPath: IndexPath) {
        var item=""
        guard let emojiResult = self.emojiResult else {
            switch indexPath.section {
            case autoCompletionSectionIndexes[0]:
                item = self.commandsResult[indexPath.row]
            case autoCompletionSectionIndexes[1]:
                item = self.usersInChannelResult[indexPath.row].username!
            case autoCompletionSectionIndexes[2]:
                item = self.usersOutOfChannelResult[indexPath.row].username!
            default:
                break
            }
            item  += " "
            self.acceptAutoCompletion(with: item, keepPrefix: true)
            return
        }
        item = emojiResult[indexPath.row]
        if (self.foundPrefix == ":") { item += ":" }
        item += " "
        
        self.acceptAutoCompletion(with: item, keepPrefix: true)
    }
    
    func autoCompletionEmojiCellForRowAtIndexPath(_ indexPath: IndexPath) -> EmojiTableViewCell {
        let cell = self.autoCompletionView.dequeueReusableCell(withIdentifier: EmojiTableViewCell.reuseIdentifier) as! EmojiTableViewCell
        cell.selectionStyle = .default
        
        guard let searchResult = self.emojiResult else { return cell }
        guard self.foundPrefix != nil else { return cell }
        
        let text = searchResult[indexPath.row]
        let originalIndex = Constants.EmojiArrays.mattermost.index(of: text)
        cell.configureWith(index: originalIndex)
        
        return cell
    }
    
    func autoCompletionMembersCellForRowAtIndexPath(_ indexPath: IndexPath) -> MemberLinkTableViewCell {
        let cell = self.autoCompletionView.dequeueReusableCell(withIdentifier: "memberLinkTableViewCell") as! MemberLinkTableViewCell
        cell.selectionStyle = .default
        guard  (self.usersInChannelResult != [] || self.usersOutOfChannelResult != [] || self.commandsResult != []) else { return cell }
        guard self.foundPrefix != nil else { return cell }
        
        switch indexPath.section {
        case autoCompletionSectionIndexes[0]:
            let commandIndex = Constants.LinkCommands.name.index(of: commandsResult[indexPath.row])
            cell.configureWithIndex(index: commandIndex!)
        case autoCompletionSectionIndexes[1]:
            let member = self.usersInChannelResult[indexPath.row]
            cell.configureWithUser(user: member)
        case autoCompletionSectionIndexes[2]:
            let member = self.usersOutOfChannelResult[indexPath.row]
            cell.configureWithUser(user: member)
        default:
            break
        }
        return cell
    }
    
    override func shouldProcessText(forAutoCompletion text: String) -> Bool {
        return true
    }
    
    //NEEDREFACTORING
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        if isNeededAutocompletionRequest {
            Api.sharedInstance.autocompleteUsersIn(channel: self.channel, completion: {(error, usersInChannel, usersOutOfChannel) in
                
                self.usersInChannel = usersInChannel!
                self.usersOutOfChannel = usersOutOfChannel!
                
                var array:Array<String> = []
                self.emojiResult = nil
                self.usersInChannelResult = []
                self.usersOutOfChannelResult = []
                self.commandsResult = []
                self.autoCompletionSectionIndexes = [0, 1, 2]
                self.numberOfSection = 3
                
                if (prefix == ":") && word.characters.count > 0 {
                    array = Constants.EmojiArrays.mattermost.filter { NSPredicate(format: "self BEGINSWITH[c] %@", word).evaluate(with: $0) };
                }
                
                if (prefix == "@") {
                    self.commandsResult = Constants.LinkCommands.name.filter {
                        return $0.hasPrefix(word.lowercased())
                    }
                    if self.commandsResult == [] {
                        self.autoCompletionSectionIndexes[0] = -1
                        self.autoCompletionSectionIndexes[1] -= 1
                        self.autoCompletionSectionIndexes[2] -= 1
                        self.numberOfSection -= 1
                    }
                    
                    self.usersInChannelResult = usersInChannel!.filter({
                        ($0.username?.lowercased().hasPrefix(word.lowercased()))! || word==""
                    }).sorted { $0.username! < $1.username! }
                    if self.usersInChannelResult == [] {
                        self.autoCompletionSectionIndexes[1] = -1
                        self.autoCompletionSectionIndexes[2] -= 1
                        self.numberOfSection -= 1
                    }
                    
                    self.usersOutOfChannelResult = usersOutOfChannel!.filter({
                        ($0.username?.lowercased().hasPrefix(word.lowercased()))! || word==""
                    }).sorted { $0.username! < $1.username! }
                    if self.usersInChannelResult == [] {
                        self.autoCompletionSectionIndexes[2] = -1
                        self.numberOfSection -= 1
                    }
                }
                
                var show = false
                if array.count > 0 {
                    let sortedArray = array.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                    self.emojiResult = sortedArray
                    show = sortedArray.count > 0
                } else {
                    show = self.usersInChannelResult != [] || self.usersOutOfChannelResult != [] || self.commandsResult != []
                }
                
                self.showAutoCompletionView(show)
            })
        } else {
            var array:Array<String> = []
            self.emojiResult = nil
            self.usersInChannelResult = []
            self.usersOutOfChannelResult = []
            self.commandsResult = []
            self.autoCompletionSectionIndexes = [0, 1, 2]
            self.numberOfSection = 3
            
            if (prefix == ":") && word.characters.count > 0 {
                array = Constants.EmojiArrays.mattermost.filter { NSPredicate(format: "self BEGINSWITH[c] %@", word).evaluate(with: $0) };
            }
            
            if (prefix == "@") {
                self.commandsResult = Constants.LinkCommands.name.filter {
                    return $0.hasPrefix(word.lowercased())
                }
                if self.commandsResult == [] {
                    self.autoCompletionSectionIndexes[0] = -1
                    self.autoCompletionSectionIndexes[1] -= 1
                    self.autoCompletionSectionIndexes[2] -= 1
                    self.numberOfSection -= 1
                }
                
                self.usersInChannelResult = usersInChannel.filter({
                    ($0.username?.lowercased().hasPrefix(word.lowercased()))! || word==""
                }).sorted { $0.username! < $1.username! }
                if self.usersInChannelResult == [] {
                    self.autoCompletionSectionIndexes[1] = -1
                    self.autoCompletionSectionIndexes[2] -= 1
                    self.numberOfSection -= 1
                }
                
                self.usersOutOfChannelResult = usersOutOfChannel.filter({
                    ($0.username?.lowercased().hasPrefix(word.lowercased()))! || word==""
                }).sorted { $0.username! < $1.username! }
                if self.usersInChannelResult == [] {
                    self.autoCompletionSectionIndexes[2] = 1
                    self.numberOfSection -= 1
                }
            }
            
            var show = false
            if array.count > 0 {
                let sortedArray = array.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                self.emojiResult = sortedArray
                show = sortedArray.count > 0
            } else {
                show = self.usersInChannelResult != [] || self.usersOutOfChannelResult != [] || self.commandsResult != []
            }
            
            self.showAutoCompletionView(show)
        }
    }
    //NEEDREFACTORING
    
    override func heightForAutoCompletionView() -> CGFloat {
        guard let smilesResult = self.emojiResult else {
            guard (self.usersInChannelResult != [] || self.usersOutOfChannelResult != [] || self.commandsResult != []) else { return 0 }
            
            let cellHeight = (self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0)))!
            return cellHeight * CGFloat(self.usersInChannelResult.count+self.usersOutOfChannelResult.count+self.commandsResult.count) + 25
        }
        let cellHeight = (self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0)))!
        
        return cellHeight * CGFloat(smilesResult.count)
    }
}

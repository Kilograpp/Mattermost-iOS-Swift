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
        guard let emojiResult = self.emojiResult else {
            var item = (indexPath.row < self.commandsResult.count) ? self.commandsResult[indexPath.row]
                : self.membersResult[indexPath.row - self.commandsResult.count].username!
            item  += " "
            self.acceptAutoCompletion(with: item, keepPrefix: true)
            return
        }
        var item = emojiResult[indexPath.row]
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
        
        guard  (self.membersResult != [] || self.commandsResult != []) else { return cell }
        guard self.foundPrefix != nil else { return cell }
        if indexPath.row < self.commandsResult.count{
            let commandIndex = Constants.LinkCommands.name.index(of: commandsResult[indexPath.row])
            cell.configureWithIndex(index: commandIndex!)
        } else {
            let member = self.membersResult[indexPath.row - self.commandsResult.count]
            cell.configureWithUser(user: member)
        }
        
        return cell
    }
    
    override func shouldProcessText(forAutoCompletion text: String) -> Bool {
        return true
    }
    
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        var array:Array<String> = []
        self.emojiResult = nil
        self.membersResult = []
        self.commandsResult = []
        
        if (prefix == ":") && word.characters.count > 0 {
            array = Constants.EmojiArrays.mattermost.filter { NSPredicate(format: "self BEGINSWITH[c] %@", word).evaluate(with: $0) };
        }
        
        if (prefix == "@") {
            self.membersResult = usersInTeam.filter({
                ($0.username?.lowercased().hasPrefix(word.lowercased()))! || word==""
            }).sorted { $0.username! < $1.username! }
            
            self.commandsResult = Constants.LinkCommands.name.filter {
                return $0.hasPrefix(word.lowercased())
            }
        }
        
        var show = false
        if array.count > 0 {
            let sortedArray = array.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            self.emojiResult = sortedArray
            show = sortedArray.count > 0
        } else {
            show = self.membersResult != [] || self.commandsResult != []
        }
        
        self.showAutoCompletionView(show)
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        guard let smilesResult = self.emojiResult else {
            guard (self.membersResult != [] || self.commandsResult != []) else { return 0 }
            
            let cellHeight = (self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0)))!
            return cellHeight * CGFloat(self.membersResult.count+self.commandsResult.count)
        }
        let cellHeight = (self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0)))!
        
        return cellHeight * CGFloat(smilesResult.count)
    }
}

//
//  NewChatViewController.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 20/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftSpinner
import Haneke
import EZSwiftExtensions
import RealmSwift

class ChatViewController: SLKTextViewController, UINavigationBarDelegate {
    
    var currentUser: User?
    var messages: [Message] = []
    var usersArray: [String] = []
    var searchResult: [AnyObject]?
    var editingMessage: Message?
    var tappedNick: String?
    var deleteID = Int()
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Chat init...", animated: true)
        self.UI()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.navigationController?.navigationBar.hidden = true
        socket.connect()
        socket.on("connect") {data, ack in
            print("socket connected")
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.login()
            }
        }
    }
    
    func UI() {
        
        self.autoCompletionView.snp_remakeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view)
        }
        
        self.leftButton.setImage(UIImage(named: "mark.png"), forState: .Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView?.backgroundView?.backgroundColor = UIColor.whiteColor()
        self.tableView!.backgroundColor = UIColor.whiteColor()
        
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        self.registerPrefixesForAutoCompletion(["@"])
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = false
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.inverted = false
        
        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .Split
        self.textInputbar.counterPosition = .Top
        
        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        if let tableView = self.tableView {
            tableView.separatorStyle = .None
            tableView.registerClass(ChatCell.classForCoder(), forCellReuseIdentifier: "ChatCell")
        }
        self.autoCompletionView.registerClass(AutoCompletionCell.classForCoder(), forCellReuseIdentifier: "AutoCompletionCell")
        self.registerPrefixesForAutoCompletion(["@", "#", ":", "+:", "/"])
        
        self.textView.placeholder = "Это чат. Поиск выше!"
        
        //        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        //        self.textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
        //        self.textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        //        self.textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        //        self.textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        //        self.textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func didPressRightButton(sender: AnyObject?) {
        
        self.textInputbar.resignFirstResponder()
        self.textInputbar.textView.refreshFirstResponder()
        
        let message = self.textView.text.copy()
        
        self.sendMessage(message as! String)
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView!.reloadData()
            if self.messages.count > 0 {
                
            }
        }
        
        super.didPressRightButton(sender)
    }
    
    override func didPressLeftButton(sender: AnyObject?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.modalPresentationStyle = .Popover
        alertController.popoverPresentationController?.sourceView = view.superview
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        if self.currentUser?.userlevel == 20 || self.currentUser?.userlevel == 3 || self.currentUser?.userlevel == 2 || self.currentUser?.userlevel == 1 {
            
            alertController.addAction(UIAlertAction(title: "Chat Archive", style: .Default, handler: { [unowned self] (action) -> Void in
                self.pushVC(ArchiveViewController())
                }))
            
        }
        
        alertController.addAction(UIAlertAction(title: "Donate", style: .Default, handler: { [unowned self] (action) -> Void in
            print(self)
            UIApplication.sharedApplication().openURL(NSURL(string : "https://rocketbank.ru/gleb.karpushkin")!)
            }))
        
        alertController.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { [unowned self] (action) -> Void in
            KeyChain().logout()
            self.navigationController?.popToRootViewControllerAnimated(true)
            }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { [unowned self] (action) -> Void in
            print(self)
            }))
        
        
        self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        super.didPressLeftButton(sender)
    }
    
    func login() {
        
        let user = KeyChain().userID()
        let tok = KeyChain().token()
        
        socket.emitWithAck("app_verification", ["method": "login", "userid": user, "token": tok, "appid": appid])(timeoutAfter: 1) {data in
            guard (data.count > 0) else {print(" token_verification empty answer ") ; return}
            print(JSON(rawValue: data[0]))
            if let json = JSON(rawValue: data[0]) {
                
                if json == "NO ACK" {
                    
                } else {
                    
                    let token = json["token"].stringValue
                    KeyChain().saveToken(token)
                    
                    if let success = json["success"].int {
                        if success > 0 {
                            print("success")
                            SwiftSpinner.showWithDuration(0.5, title: "Success", animated: true)
                            self.api()
                            
                        } else {
                            print(" login unsuccessful ")
                            if let reason = json["reason"].string {
                                print(" reason is \(reason) ")
                                if reason == "INVALID_TOKEN" {
                                    SwiftSpinner.showWithDuration(1.0, title: "Session invalid", animated: false)
                                    
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                } else {
                                    SwiftSpinner.showWithDuration(1.0, title: "Error", animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func api() {
        socket.on("api") {data, ack in
            if let json = JSON(rawValue: data[0]) {
                if let method = json["method"].string {
                    switch method {
                    case "auth":
                        if let item: JSON = json["client"] {
                            self.currentUser = User.parseFromJson(item)
                            
                        }
                        
                    case "history":
                        if let list = json["list"].array {
                            for item in list {
                                if let message = Message.parseFromJson(item) {
                                    self.messages.append(message)
                                    if !self.usersArray.contains(message.username) {
                                        self.usersArray.append(message.username)
                                    }
                                }
                                self.tableView!.reloadData()
                            }
                        }
                        
                    case "message_new":
                        print(json)
                        if let message = Message.parseFromJson(json) {
                            
                            if !self.usersArray.contains(message.username) {
                                self.usersArray.append(message.username)
                            }
                            
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
                            
                            self.tableView!.beginUpdates()
                            self.messages.append(message)
                            self.tableView!.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
                            self.tableView!.endUpdates()
                            self.tableView!.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            
                            ez.runThisInBackground({ 
                                let realm = try! Realm()
                                let messageDB = ChatMessage()
                                
                                try! realm.write {
                                    messageDB.user = message.username
                                    messageDB.userId = message.userid
                                    messageDB.text = message.text
                                    messageDB.time = message.time!
                                    messageDB.id = message.id
                                    realm.add(messageDB, update: true)
                                }
                                
                            })
                        }
                        
                    case "message_writes":
                        let status = json["status"].intValue
                        let username = json["username"].stringValue
                        if status == 1 {
                            
                            self.typingIndicatorView!.insertUsername("\(username)")
                        }
                        
                    case "message_delete":
                        if let id = json["id"].string, let username = json["username"].string {
                            if let index = self.messages.indexOf({$0.id == id}) {
                                
                                self.messages.removeAtIndex(index)
                                
                                print("deleted message with id:\(id) of:\(username) at index: \(index)")
                                
                                self.tableView!.reloadData()
                            }
                        }
                        
                    case "message_edit":
                        if let id = json["id"].string, let message = json["msg"].string {
                            if let index = self.messages.indexOf({$0.id == id}) {
                                if json["live"].bool == false {
                                    self.messages[index].text = NSMutableString(string: message) as String
                                    
                                    self.tableView?.reloadData()
                                }
                            }
                        }
                        print(json)
                        print("mesage Editing")
                        
                    default: print(" [\(method)] method received ")
                        
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return self.messages.count
        }
        else {
            if let searchResult = self.searchResult {
                return searchResult.count
            }
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            return self.messageCellForRowAtIndexPath(indexPath)
        }
        else {
            return self.autoCompletionCellForRowAtIndexPath(indexPath)
        }
    }
    
    func messageCellForRowAtIndexPath(indexPath: NSIndexPath) -> ChatCell {
        
        let message = self.messages[indexPath.row]
        
        let cell = self.tableView?.dequeueReusableCellWithIdentifier("ChatCell") as! ChatCell
        
        if message.isPrivate == false {
            cell.privateLabel.hidden = true
        }
        
        if message.isPrivate == true {
            cell.privateLabel.hidden = false
        }
        
        cell.indexPath = indexPath
        
        cell.avatarImage.hnk_setImageFromURL(NSURL(string: message.userAvatar)!, placeholder: UIImage(named: "noavatar.png"))
        
        
        cell.bodyLabel.attributedText = TextFormatter().completeText(message.text)
        
        switch (message.userlevel) {
        case 20:
            cell.nameLabel.textColor = UIColor(red: 216.0 / 255.0, green: 108.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
            cell.nameLabel.text = message.username
        case 3:
            cell.nameLabel.textColor = UIColor(red: 29.0 / 255.0, green: 112.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            cell.nameLabel.text = message.username
        case 2:
            cell.nameLabel.textColor = UIColor(red: 29.0 / 255.0, green: 112.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            cell.nameLabel.text = message.username
        case 1:
            cell.nameLabel.textColor = UIColor(red: 243.0 / 255.0, green: 0.0 / 255.0, blue: 6.0 / 255.0, alpha: 1.0)
            cell.nameLabel.text = message.username
        default:
            cell.nameLabel.textColor = UIColor(red: 50.0 / 255.0, green: 117.0 / 255.0, blue: 181.0 / 255.0, alpha: 1.0)
            cell.nameLabel.text = message.username
        }
        
        //time
        let format  = NSDateFormatter()
        format.timeStyle = NSDateFormatterStyle.ShortStyle
        format.dateStyle = NSDateFormatterStyle.NoStyle
        let formatedTime = NSAttributedString(string: format.stringFromDate(message.time!), attributes: [NSFontAttributeName : UIFont.systemFontOfSize(9.0)])
        cell.timeLabel.attributedText = formatedTime
        cell.transform = self.tableView!.transform
        
        return cell
        
    }
    
    func autoCompletionCellForRowAtIndexPath(indexPath: NSIndexPath) -> AutoCompletionCell {
        
        let cell = self.autoCompletionView.dequeueReusableCellWithIdentifier("AutoCompletionCell") as! AutoCompletionCell
        
        cell.indexPath = indexPath
        cell.selectionStyle = .Default
        
        let text = self.searchResult![indexPath.row]
        
        //        else if prefix == ":" || prefix == "+:" {
        //            text = ":\(text):"
        //        }
        
        cell.nameLabel.text = text as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == self.tableView {
            return UITableViewAutomaticDimension
        }else {
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = self.messages[indexPath.row]
        
        if tableView == self.autoCompletionView {
            
            guard let searchResult = self.searchResult as? [String] else {
                return
            }
            
            var item = searchResult[indexPath.row]
            
            if self.foundPrefix == "@" && self.foundPrefixRange.location == 0 {
                item += ""
            }
            else if self.foundPrefix == ":" || self.foundPrefix == "+:" {
                item += ""
            }
            
            item += " "
            
            self.acceptAutoCompletionWithString("[b]\(item)[/b]:", keepPrefix: false)
        } else {
            let text = self.textInputbar.textView.text
            let newText = text + "[b]\(message.username)[/b],"
            self.textInputbar.textView.text = newText
            
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = self.messages[indexPath.row]
        if self.messages[indexPath.row].username == self.currentUser?.username {
            
            if editingStyle == UITableViewCellEditingStyle.Delete {
                
                socket.emitWithAck("api", ["method": "message_delete", "id": message.id])(timeoutAfter: 0) {data in}
                
                let id = message.id
                if let index = self.messages.indexOf({$0.id == id}) {
                    
                    print("deleted message with id:\(id) of:\(self.currentUser?.username) at index: \(index)")
                }
                
            } else {
                let alertController = UIAlertController(title: "Fail :)", message:
                    "Вы не можете удалять чужие сообщения", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ну ладно...", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    override func didChangeAutoCompletionPrefix(prefix: String, andWord word: String) {
        
        
        var array: [AnyObject]?
        
        self.searchResult = nil
        
        if prefix == "@" {
            if word.characters.count > 0 {
                array = (self.usersArray as NSArray).filteredArrayUsingPredicate(NSPredicate(format: "self BEGINSWITH[c] %@", word))
            }
            else {
                array = self.usersArray
            }
        }
        
        var show = false
        
        if  array?.count > 0 {
            self.searchResult = (array! as NSArray).sortedArrayUsingSelector(#selector(NSString.localizedCaseInsensitiveCompare(_:)))
            show = (self.searchResult?.count > 0)
        }
        
        self.showAutoCompletionView(show)
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        
        guard let searchResult = self.searchResult else {
            return 0
        }
        
        let cellHeight = self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        guard let height = cellHeight else {
            return 0
        }
        return height * CGFloat(searchResult.count)
    }
    
    
    func editCellMessage(gesture: UIGestureRecognizer) {
        
        guard let cell = gesture.view as? ChatCell else {
            
            return
        }
        
        self.editingMessage = self.messages[cell.indexPath!.row]
        self.editText(self.editingMessage!.text)
        
        self.tableView!.scrollToRowAtIndexPath(cell.indexPath!, atScrollPosition: .Bottom, animated: true)
    }
    
    func deleteCellMessage(id: Int?) {
        socket.emitWithAck("api", ["method": "message_delete", "id": "\(id)"])(timeoutAfter: 0) {data in}
        
        let id = id
        if let index = self.messages.indexOf({$0.id == "\(id)"}) {
            
            self.messages.removeAtIndex(index)
            
            print("deleted message with id:\(id)")
            
            self.tableView!.reloadData()
        }
        
        
    }
    
    func sendMessage( message: String) {
        var message = message
        guard (!message.isEmpty) else {return}
        
        let replacements = ["<b>" : "[b]", "</b>" : "[/b]", "<u>" : "[u]", "</u>" : "[/u]", "<s>" : "[s]", "</s>" : "[/s]"]
        for (originalWord, newWord) in replacements {
            message = message.stringByReplacingOccurrencesOfString(originalWord, withString: newWord, options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        
        socket.emitWithAck("api", ["method": "message_new", "msg": message])(timeoutAfter: 0) {data in
            
            guard (data.count > 0) else {print("message_new empty answer") ; return}
            
            if let json = JSON(rawValue: data[0]) {
                if let success = json["success"].int {
                    if success > 0 {
                        
                    } else {
                        print("Failed to send message")
                    }
                }
            }
            
        }
    }
    
}

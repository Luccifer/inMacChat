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


class ChatViewController: SLKTextViewController, UINavigationBarDelegate {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")

    var currentUser: User?
    var messages: [Message] = []
    var usersArray: [String] = []
    var searchResult: [AnyObject]?
    var editingMessage: Message?
    var tappedNick: String?
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.hidden = true
        
        SwiftSpinner.show("Chat init...", animated: true)
        self.commonInit()
        self.UI()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.socket.connect()
        self.socket.on("connect") {data, ack in
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

        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        self.textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
        self.textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        self.textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        self.textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        self.textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
    }

    func commonInit() {
        //
        //        NSNotificationCenter.defaultCenter().addObserver(self.tableView!, selector: #selector(UITableView.reloadData), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageViewController.textInputbarDidMove(_:)), name: SLKTextInputbarDidMoveNotification, object: nil)
        //        self.registerClassForTextView(MessageTextView.classForCoder())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.socket.on("api") {data, ack in
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
                        if let message = Message.parseFromJson(json) {

                            self.messages.append(message)

                            if !self.usersArray.contains(message.username) {
                                self.usersArray.append(message.username)
                            }

                            let index = NSIndexPath(forRow: self.tableView!.numberOfRowsInSection(0) - 1, inSection: 0)
                            self.tableView!.beginUpdates()
                            self.tableView!.insertRowsAtIndexPaths([index], withRowAnimation: .Automatic)
                            self.tableView!.endUpdates()
                        }


                    case "message_writes":
                        let status = json["status"].intValue
                        let username = json["username"].stringValue
                        if status == 1 {

                            self.typingIndicatorView!.insertUsername("\(username)")
                        }




                        //                    case "message_delete":
                        //                        if let id = json["id"].string, let username = json["username"].string {
                        //                            if let index = self.messages.indexOf({$0.id == id}) {
                        //
                        //                                self.messages.removeAtIndex(index)
                        //
                        //                                print("deleted message with id:\(id) of:\(username) at index: \(index)")
                        //
                        //                                //                                self.tableView.reloadData()
                        //                            }
                        //                        }
                        //
                        //                    case "message_edit":
                        //                        if let id = json["id"].string, let message = json["msg"].string {
                        //                            if let index = self.messages.indexOf({$0.id == id}) {
                        //                                self.messages[index].text = NSMutableString(string: message)
                        //
                        //                            }
                        //                        }
                        //                        print("mesage Editing")
                        //                        //                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(60.0 * Double(NSEC_PER_SEC)))
                        //                        //                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                        //                        //                            self.tableView.reloadData()
                        //                        //                        }
                        //                        //
                    //                    //
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
        
        cell.indexPath = indexPath
        
        if cell.gestureRecognizers?.count == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.didLongPressCell(_:)))
            let shortPress = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.didShortPressCell(_:)))
            self.tappedNick = cell.nameLabel.text
            cell.addGestureRecognizer(shortPress)
            cell.addGestureRecognizer(longPress)
        }
        
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
        
        if tableView == self.autoCompletionView {
            
            guard let searchResult = self.searchResult as? [String] else {
                return
            }
            
            var item = searchResult[indexPath.row]
            
            if self.foundPrefix == "@" && self.foundPrefixRange.location == 0 {
                item += ":"
            }
            else if self.foundPrefix == ":" || self.foundPrefix == "+:" {
                item += ":"
            }
            
            item += " "
            
            self.acceptAutoCompletionWithString("[b]\(item)[/b]:", keepPrefix: false)
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
    
    func didLongPressCell(gesture: UIGestureRecognizer) {
        
        guard let view = gesture.view else {
            return
        }
        
        if gesture.state != .Began {
            return
        }
        
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertController.modalPresentationStyle = .Popover
            alertController.popoverPresentationController?.sourceView = view.superview
            alertController.popoverPresentationController?.sourceRect = view.frame
            
            alertController.addAction(UIAlertAction(title: "Edit Message", style: .Default, handler: { [unowned self] (action) -> Void in
                self.editCellMessage(gesture)
                }))
        
        alertController.addAction(UIAlertAction(title: "Delete Message", style: .Destructive, handler: { [unowned self] (action) -> Void in
            self.editCellMessage(gesture)
            }))

        
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func didShortPressCell(gesture: UIGestureRecognizer) {
        let text = self.textInputbar.textView.text
        let newText = text + "[b]\(self.tappedNick)[/b],"
        self.textInputbar.textView.text = newText
    }


    func editCellMessage(gesture: UIGestureRecognizer) {
        
        guard let cell = gesture.view as? ChatCell else {
            
            return
        }
        
        self.editingMessage = self.messages[cell.indexPath!.row]
        self.editText(self.editingMessage!.text)
        
        self.tableView!.scrollToRowAtIndexPath(cell.indexPath!, atScrollPosition: .Bottom, animated: true)
    }
    
    func deleteCellMessage() {
        
    }
    
    
}

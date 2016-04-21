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

class ChatViewController: SLKTextViewController, UINavigationBarDelegate {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")
    var currentUser: User?

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.registerPrefixesForAutoCompletion(["@"])
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = false
        self.shouldScrollToBottomAfterKeyboardShows = true

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.counterStyle = .Split
        self.textInputbar.counterPosition = .Top

        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)

        if let tableView = self.tableView {
            tableView.separatorStyle = .None
            tableView.registerClass(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: MessengerCellIdentifier)
        }
        self.autoCompletionView.registerClass(MessageTableViewCell.classForCoder(), forCellReuseIdentifier: AutoCompletionCellIdentifier)
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
                                print(item)
//                                if let message = MessageNew.parseFromJson(item) {
//                                    self.messages.append(message)
                                }
                            }
                            //
                            //                            dispatch_async(dispatch_get_main_queue()) {
                            //                                () -> Void in
                            //                                self.tableView.reloadData()
                            //                                if self.messages.count > 0 {
                            //
                            //                                }
                            //                            }
                            //
                            //                        }

                            //                    case "loggedin":
                            //                        if let item: JSON = json["client"] {
                            //                            if let user = User.parseFromJson(item) {
                            //                                print(user.isMember)
                            //                            }
                            //                        }
                            //
                            //
                            //                    case "history":
                            //                        if let list = json["list"].array {
                            //                            for item in list {
                            //                                if let message = MessageNew.parseFromJson(item) {
                            //                                    self.messages.append(message)
                            //                                }
                            //                            }
                            //
                            //                            dispatch_async(dispatch_get_main_queue()) {
                            //                                () -> Void in
                            //                                self.tableView.reloadData()
                            //                                if self.messages.count > 0 {
                            //
                            //                                }
                            //                            }
                            //
                            //                        }
                            //
                            //                    case "message_writes":
                            //                        let status = json["status"].intValue
                            //                        let username = json["username"].stringValue
                            //                        if status == 1 {
                            //
                            //                            self.typingIndicatorView.insertUsername("\(username)")
                            //                        }
                            //
                            //                    case "message_new":
                            //                        if let message = MessageNew.parseFromJson(json) {
                            //
                            //                            self.messages.append(message)
                            //                            self.usersArray.append(message.username)
                            //                            self.usersArray = self.uniq(self.usersArray)
                            //                            print(self.usersArray)
                            //
                            //                            let index = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1,
                            //                                                    inSection: 0)
                            //
                            //                            self.tableView.insertRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
                            //                            //                            self.scrollToBottomMessage()
                            //                        }
                            //
                            //                        //                        dispatch_async(dispatch_get_main_queue()) {
                            //                        //                            () -> Void in
                            //                        //                            self.tableView.reloadData()
                            //                        //                            if self.messages.count > 0 {
                            //                        //
                            //                        //                            }
                            //                        //                             self.scrollToBottomMessage()
                            //                        //                        }
                            //
                            //
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
}



//extension ChatViewController {
//
//    func configureDataSource() {
//
//        var array = [Message]()
//
//        for _ in 0..<100 {
//            let words = Int((arc4random() % 40)+1)
//
//            message.username = LoremIpsum.name()
//            message.text = LoremIpsum.wordsWithNumber(words)
//            array.append(message)
//        }
//
//        let reversed = array.reverse()
//
//        self.messages.appendContentsOf(reversed)
//    }
//}

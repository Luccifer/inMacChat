//
//  NewChatViewController.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 20/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatViewController: SLKTextViewController {

    let socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.socket.connect()
        self.commonInit()
        self.UI()
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

        NSNotificationCenter.defaultCenter().addObserver(self.tableView!, selector: #selector(UITableView.reloadData), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageViewController.textInputbarDidMove(_:)), name: SLKTextInputbarDidMoveNotification, object: nil)
        self.registerClassForTextView(MessageTextView.classForCoder())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}



extension ChatViewController {

    func configureDataSource() {

        var array = [Message]()

        for _ in 0..<100 {
            let words = Int((arc4random() % 40)+1)

            message.username = LoremIpsum.name()
            message.text = LoremIpsum.wordsWithNumber(words)
            array.append(message)
        }

        let reversed = array.reverse()

        self.messages.appendContentsOf(reversed)
    }
}

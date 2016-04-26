//
//  ArchiveChatViewController.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 26/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ArchiveViewController: UITableViewController {
    
    var messages: Results<(ChatMessage)>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView!.estimatedRowHeight = 100
        self.tableView!.rowHeight = UITableViewAutomaticDimension

        self.navigationController?.navigationBar.hidden = false
        
        self.tableView.registerClass(ArchiveCell.classForCoder(), forCellReuseIdentifier: "ArchiveCell")
        
        let realm = try! Realm()
        self.messages = realm.objects(ChatMessage)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = self.messages![indexPath.row]
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ArchiveCell") as! ArchiveCell
        
        cell.bodyLabel.text = message.text
        cell.nameLabel.text = message.user
        let format  = NSDateFormatter()
        
        format.timeStyle = NSDateFormatterStyle.ShortStyle
        format.dateStyle = NSDateFormatterStyle.NoStyle
        let formatedTime = NSAttributedString(string: format.stringFromDate(message.time), attributes: [NSFontAttributeName : UIFont.systemFontOfSize(9.0)])
        cell.timeLabel.attributedText = formatedTime
        cell.transform = self.tableView!.transform
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}
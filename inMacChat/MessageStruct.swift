//
//  Message.swift
//  inMac.Chat
//
//  Created by Gleb Karpushkin on 01/12/15.
//  Copyright © 2015 Gleb Karpushkin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Message {

    let userid: Int
    let id: String
    let username: String
    var text: NSMutableString
    let isPrivate: Bool
    let userlevel: Int
    let userAvatar: String
    let status: Int? = nil
    let time: NSDate?

    var separator: String {
        return ": "
    }

    static func parseFromJson(item: JSON) -> Message? {
        let
        userid = item["userid"].intValue,
        id = item["id"].stringValue,
        username = item["username"].stringValue,
        msg = item["msg"].stringValue,
        isPrivate = item["private"].intValue,
        Avatar = item["useravatar"].stringValue,
        userlevel = item["userlevel"].intValue,
        time = NSDate(timeIntervalSince1970: NSNumber(double: item["time"].doubleValue).doubleValue)
        
        return Message(userid: userid, id: id, username: username, text: NSMutableString(string: msg), isPrivate: isPrivate > 0, userlevel: userlevel, userAvatar: Avatar, time: time)
        }

}

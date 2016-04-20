//
//  Message.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 20/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Message {


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

        if let id = item["id"].string,
            username = item["username"].string,
            msg = item["msg"].string,
            isPrivate = item["private"].int,
            Avatar = item["useravatar"].string,
            userlevel = item["userlevel"].int,
            time = item["time"].int {
            return Message(id: id, username: username, text: NSMutableString(string: msg), isPrivate: isPrivate > 0, userlevel: userlevel, userAvatar: Avatar, time: NSDate(timeIntervalSince1970: NSNumber(double: Double(time)).doubleValue))
        }

        return nil
    }
}

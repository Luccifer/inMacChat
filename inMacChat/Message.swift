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
    var text: String
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
        userAvatar = item["useravatar"].stringValue,
        userlevel = item["userlevel"].intValue,
        time = item["time"].intValue

        return Message(userid: userid, id: id, username: username, text: msg, isPrivate: isPrivate > 0, userlevel: userlevel, userAvatar: "http://st.inmac.org/images/avatars/\(userAvatar)", time: NSDate(timeIntervalSince1970: NSNumber(double: Double(time)).doubleValue))
    }

}

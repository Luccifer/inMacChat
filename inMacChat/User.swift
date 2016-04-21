//
//  User.swift
//  inMacRadio
//
//  Created by Gleb Karpushkin on 11/12/15.
//  Copyright © 2015 Gleb Karpushkin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {

    let userid: Int
    let username: String
    let userlevel: Int
    let active: Bool
    let ses: String
    let ses_count: Int
    let useravatar: String
    let isAdmin: Bool
    let isModerator: Bool
    let isMember: Bool
    let isDeveloper: Bool

    static func parseFromJson(item: JSON) -> User? {
        let
        useravatar = item["useravatar"].stringValue,
        isAdmin = item["isAdmin"].boolValue,
        active = item["active"].boolValue,
        userid = item["userid"].intValue,
        ses = item["ses"].stringValue,
        ses_count = item["ses_count"].intValue,
        isModerator = item["isModerator"].boolValue,
        isMember = item["isMember"].boolValue,
        username = item["username"].stringValue,
        userlevel = item["userlevel"].intValue,
        isDeveloper = item["isDeveloper"].boolValue

        return User(userid: userid, username: username, userlevel: userlevel, active: active, ses: ses, ses_count: ses_count, useravatar: "http://st.inmac.org/images/avatars/\(useravatar)", isAdmin: isAdmin, isModerator: isModerator, isMember: isMember, isDeveloper: isDeveloper)

    }

}

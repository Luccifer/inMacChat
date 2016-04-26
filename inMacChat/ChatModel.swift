//
//  ChatModel.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 26/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import RealmSwift

class ChatMessage: Object {
    dynamic var user = String()
    dynamic var userId = Int()
    dynamic var text = String()
    dynamic var time = NSDate()
    
    dynamic var id = String()
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
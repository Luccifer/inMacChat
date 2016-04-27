//
//  KeyChain.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 20/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import KeychainAccess

public var uuid = NSUUID().UUIDString
public var socket = SocketIOClient(socketURL: "https://inmac.org/chat/socket.io/")
public var appid = ""
public var userid: Int?
struct KeyChain {
    
    //Save
    func saveUsername(username: String) {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        keychain["username"] = username
    }
    
    func savePassword(password: String) {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        keychain["password"] = password
    }
    
    func saveToken(token: String) {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        keychain["token"] = token
    }
    
    func saveUUID(UUID: String) {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        keychain["UUID"] = UUID
    }
    
    func saveUserID(userID: String) {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        keychain["userID"] = userID
    }
    
    
    // Load
    func username() -> String {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        if keychain["username"] != nil {
            return keychain["username"]!
        } else {
            return String()
        }
    }
    
    func password() -> String {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        if keychain["password"] != nil {
            return keychain["password"]!
        } else {
            return String()
        }
    }
    
    func UUID() -> String {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        if keychain["UUID"] != nil {
            return keychain["UUID"]!
        } else {
            return String()
        }
    }
    
    func token() -> String {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        if keychain["token"] != nil {
            return keychain["token"]!
        } else {
            return String()
        }
    }
    
    func userID() -> String {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        if keychain["userID"] != nil {
            return keychain["userID"]!
        } else {
            return String()
        }
    }
    
    func logout() {
        let keychain = Keychain(service: "com.eyerise.inMacChat")
        keychain["username"] = nil
        keychain["password"] = nil
        keychain["UUID"] = nil
        keychain["token"] = nil
        keychain["userID"] = nil
        
    }
}

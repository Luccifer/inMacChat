//
//  KeyChain.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 20/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation
import KeychainAccess

struct KeyChain {

    //Save
    func saveUsername(username: String) {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        keychain["username"] = username
    }

    func savePassword(password: String) {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        keychain["password"] = password
    }

    func saveToken(token: String) {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        keychain["token"] = token
    }

    func saveUUID(UUID: String) {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        keychain["UUID"] = UUID
    }

    func saveUserID(userID: String) {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        keychain["userID"] = userID
    }


    // Load
    func username() -> String {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        return keychain["username"]!
    }

    func password() -> String {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        return keychain["password"]!
    }

    func UUID() -> String {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        return keychain["UUID"]!
    }

    func token() -> String {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        return keychain["token"]!
    }

    func userID() -> String {
        let keychain = Keychain(service: "com.eyerise.InMacChat")
        return keychain["userID"]!
    }
}

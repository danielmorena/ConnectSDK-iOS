//
//  Keychain.swift
//  IFTTT SDK
//
//  Created by Siddharth Sathyam on 4/8/20.
//  Copyright © 2020 IFTTT. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let ConnectionsChangedNotification = NSNotification.Name("ConnectionsChangedNotification")
}

final class Keychain {
    struct Key {
        static let UserToken = "KeychainKey.IFTTTUserToken"
        static let InviteCode = "KeychainKey.PlatformInviteCode"
    }

    class func set(value: String?, for key: String) {
        guard let value = value else {
            removeValue(for: key)
            return
        }
        guard let valueData = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    class func getValue(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == noErr else { return nil }
        
        guard let data = dataTypeRef as? Data else { return nil }
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        
        return string
    }


    class func removeValue(for key: String) {
        // Only remove the value for the key if it exists in the keychain
        if getValue(for: key) == nil { return }
            
        // Instantiate a new default keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        // Delete any existing items
        let status = SecItemDelete(query as CFDictionary)
        
        if (status != errSecSuccess) {
            if #available(iOS 11.3, *) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Keychain Remove failed: \(err)")
                }
            }
        }
    }
}
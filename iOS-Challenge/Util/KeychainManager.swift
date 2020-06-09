//
//  KeychainManager.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation
import Security

// see https://stackoverflow.com/a/37539998/1694526
// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

let service = "com.digipay.iOS_challenge"
let account = "digipay.iOS_challenge.token"


public class KeychainManager: NSObject {

    class func updateToken(data: String) {
        if let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {

            // Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])

            let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueDataValue:dataFromString] as CFDictionary)

            if (status != errSecSuccess) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Read failed: \(err)")
                }
            }
        }
    }


    class func removeToken() {

        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, true], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue])

        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Remove failed: \(err)")
            }
        }

    }


    class func saveToken(data: String) {
        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {

            // Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])

            // Add the new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)

            if (status != errSecSuccess) {    // Always check the status
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Write failed: \(err)")
                }
            }
        }
    }

    class func loadToken() -> String? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, true, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

        var dataTypeRef :AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String?

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return contentsOfKeychain
    }

}

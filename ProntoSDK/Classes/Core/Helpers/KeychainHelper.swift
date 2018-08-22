//
//  KeychainHelper.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 22/08/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
#if !targetEnvironment(simulator)
import KeychainAccess
#endif

// MARK: - Store
// --------------------------------------------------------

class KeychainHelper {
    
    #if !targetEnvironment(simulator)
    fileprivate static let keychain = Keychain(service: "com.esites.pronto")
    #endif
    
    static func store(data: Data?, `for` key: String) {
        guard let data = data else {
            remove(for: key)
            return
        }
        
        #if targetEnvironment(simulator)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
        #else
        keychain[data: key] = data
        #endif
    }
    
    static func store(string: String?, `for` key: String) {
        guard let string = string else {
            remove(for: key)
            return
        }
        #if targetEnvironment(simulator)
        UserDefaults.standard.set(string, forKey: key)
        UserDefaults.standard.synchronize()
        #else
        keychain[string: key] = string
        #endif
    }
}

// MARK: - Get
// --------------------------------------------------------

extension KeychainHelper {
    static func data(`for` key: String) -> Data? {
        #if targetEnvironment(simulator)
        return UserDefaults.standard.data(forKey: key)
        #else
        return keychain[data: key]
        #endif
    }
    
    static func string(`for` key: String) -> String? {
        #if targetEnvironment(simulator)
        return UserDefaults.standard.string(forKey: key)
        #else
        return keychain[string: key]
        #endif
    }
}

// MARK: - Remove
// --------------------------------------------------------

extension KeychainHelper {
    static func remove(`for` key: String) {
        #if targetEnvironment(simulator)
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
        #else
        do {
            try keychain.remove(key)
        } catch { }
        #endif
    }
    
    static func removeAll() {
        #if !targetEnvironment(simulator)
        do {
            try keychain.removeAll()
        } catch { }
        #endif
    }
}

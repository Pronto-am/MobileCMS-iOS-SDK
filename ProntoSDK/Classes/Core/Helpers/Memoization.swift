//
//  Memoization.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 19/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// Memoizes the the `lazyCreateClosure`
///
/// [Read this](https://nl.wikipedia.org/wiki/Memoization) for more information about memoization:
///
/// Memoization will be stored alongside the &key and the `object`.
///
/// - Parameters:
///   - object: `Any` The object to store the key in
///   - key: The `UnsafeRawPointer` to store the memoized outcome in.
///   - lazyCreateClosure: The closure which creates the object
///
/// - Returns: The object itself
func memoize<T>(_ object: Any, key: UnsafeRawPointer, lazyCreateClosure: () -> T) -> T {
    objc_sync_enter(object); defer { objc_sync_exit(object) }
    if let instance = objc_getAssociatedObject(object, key) as? T {
        return instance
    }

    let instance = lazyCreateClosure()
    objc_setAssociatedObject(object, key, instance, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return instance
}

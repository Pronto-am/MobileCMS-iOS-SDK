//
//  ProntoFilterable.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 25/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

/// ProntoFilterable protocol.
/// These implemtentation can be used in `ProntoCollection<_>().list(filterBy:)`
public protocol ProntoFilterable {

    /// The filter value of the object
    var filterValue: String { get }
}

extension ProntoFilterable {
    /// :nodoc:
    public var filterValue: String {
        return String(describing: self)
    }
}

extension Int: ProntoFilterable { }
extension Bool: ProntoFilterable { }
extension String: ProntoFilterable { }
extension Float: ProntoFilterable { }
extension Double: ProntoFilterable { }

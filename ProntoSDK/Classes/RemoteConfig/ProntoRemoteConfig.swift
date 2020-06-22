//
//  ProntoRemoteConfig.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 24/10/2019.
//  Copyright © 2019 E-sites. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// Remote Config plugin
///
/// The remote config items are stored in the `UserDefaults`.
public class ProntoRemoteConfig: PluginBase {
    internal enum Keys {
        static let items = "ProntoRemoteConfigItems"
    }

    private var _items: [RemoteConfigItem] = [] {
        didSet {
            _store()
        }
    }

    /// Return all Remote Config items
    ///
    /// This will keep the `releaseDate` in mind.
    ///
    /// - Returns: `[RemoteConfigItem]`
    public var items: [RemoteConfigItem] {
        let nowDate = Date()
        return _items.filter { item in
            guard let date = item.releaseDate else {
                return true
            }

            return date >= nowDate
        }
    }

    /// :nodoc:
    public func configure() {

    }

    /// Default constructor
    public init() {
        guard let data = UserDefaults.standard.data(forKey: Keys.items), !data.isEmpty else {
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_clear),
                                               name: ProntoSDK.Constant.clearNotificationName,
                                               object: nil)

        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            _items = try jsonDecoder.decode([RemoteConfigItem].self, from: data)
        } catch {
            UserDefaults.standard.removeObject(forKey: Keys.items)
        }
    }

    /// :nodoc:
    public var requiredPlugins: [ProntoPlugin] {
        return [ .remoteConfig ]
    }

    /// Fetch the current Remote Config
    ///
    /// - Returns: `Single<[RemoteConfigItem]>`
    @discardableResult
    public func fetch() -> Single<[RemoteConfigItem]> {
        return ProntoAPIClient.default.remoteConfig.fetch().map { [weak self] items -> [RemoteConfigItem] in
            self?._items = items
            guard let self = self else {
                return []
            }
            return self.items
        }
    }

    /// Returns a RemoteConfigItem for a specific identifier
    ///
    /// - Parameters:
    ///   - identifier: String
    ///
    /// - Returns: `RemoteConfigItem?`
    public func get(_ identifier: String) -> RemoteConfigItem? {
        return items.first { $0.identifier == identifier }
    }

    /// Subscript. The same as `get(_:)`
    ///
    /// - Paramaters:
    ///   - identifier: String
    ///
    /// - Returns: `RemoteConfigItem?`
    public subscript(_ identifier: String) -> RemoteConfigItem? {
        return get(identifier)
    }

    private func _store() {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        do {
            let data = try jsonEncoder.encode(_items)
            UserDefaults.standard.setValue(data, forKey: Keys.items)
        } catch {
            UserDefaults.standard.removeObject(forKey: Keys.items)
        }
    }

    @objc
    private func _clear() {
        _items.removeAll()
        UserDefaults.standard.removeObject(forKey: Keys.items)
    }
}

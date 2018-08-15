//
//  ProntoPlugin.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 29/06/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation

protocol PluginBase {
    func configure()
    var requiredPlugins: [ProntoPlugin] { get }
}

/// Enum for all the available pronto plugins for that specific pronto project
public enum ProntoPlugin: String {
    /// Push notifications plugin
    case notifications

    /// (App) user authentication plugin
    case authentication

    /// Collections plugin
    case collections
}

extension PluginBase {
    func checkPlugin() {
        requiredPlugins.forEach {
            if !ProntoSDK.config.plugins.contains($0) {
                fatalError("Cannot use \(self), it's not configured in the ProntoSDK. Use .\($0) ProntoPlugin")
            }
        }
        configure()
    }
}

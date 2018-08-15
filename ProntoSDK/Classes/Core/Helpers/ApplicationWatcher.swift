//
//  ApplicationWatcher.swift
//  ProntoSDK
//
//  Created by Bas van Kuijck on 26/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import Einsteinium
import UIKit

class ApplicationWatcher {

    static var shared = ApplicationWatcher()

    var apiClient = ProntoAPIClient.default
    private var _watchMapping: [ProntoPlugin: ((ProntoAPIClient) throws -> Void)] = [:]

    private init() {
        if !Bundle.main.isUnitTesting() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(becomeActive),
                                                   name: .UIApplicationWillEnterForeground,
                                                   object: nil)
            becomeActive()
        }

    }

    func configure() {
        
    }

    func add(plugin: ProntoPlugin, _ closure: @escaping ((ProntoAPIClient) throws -> Void)) {
        _watchMapping[plugin] = closure
    }

    @objc
    func becomeActive() {
        do {
            for (_, closure) in _watchMapping {
                try closure(apiClient)
            }
        } catch { }
    }
}

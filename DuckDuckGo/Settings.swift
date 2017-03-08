//
//  Settings.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

struct Settings {
    
    private let suit = "settingsSuit"
    
    private struct Keys {
        static let showOnboarding = "showOnBoarding"
    }
    
    public var showOnboarding: Bool {
        get {
            return userDefaults()?.bool(forKey: Keys.showOnboarding) ?? true
        }
        set(newValue) {
            userDefaults()?.set(newValue, forKey: Keys.showOnboarding)
        }
    }
    
    private func userDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: suit)
    }
}

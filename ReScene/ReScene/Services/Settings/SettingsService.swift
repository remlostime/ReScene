//
//  SettingsService.swift
//  ReScene
//

import Foundation
import Observation

/// Production implementation of `SettingsServiceProtocol`.
///
/// Persists configuration in `UserDefaults` and exposes observable
/// properties so SwiftUI views react to changes automatically.
@Observable
final class SettingsService: SettingsServiceProtocol, @unchecked Sendable {

    private static let apiEnvironmentKey = "app.apiEnvironment"

    private let defaults: UserDefaults

    var apiEnvironment: APIEnvironment {
        didSet {
            defaults.set(apiEnvironment.rawValue, forKey: Self.apiEnvironmentKey)
        }
    }

    var apiBaseURL: URL {
        apiEnvironment.baseURL
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let stored = defaults.string(forKey: Self.apiEnvironmentKey),
           let env = APIEnvironment(rawValue: stored) {
            self.apiEnvironment = env
        } else {
            self.apiEnvironment = .google
        }
    }
}

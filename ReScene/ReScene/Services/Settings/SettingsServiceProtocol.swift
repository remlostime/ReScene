//
//  SettingsServiceProtocol.swift
//  ReScene
//

import Foundation

/// Defines the contract for accessing and modifying app-wide configuration.
///
/// Conforming types persist user preferences (e.g. API environment) and
/// expose derived values such as the resolved API base URL.
protocol SettingsServiceProtocol: AnyObject, Sendable {

    /// The currently selected backend API environment.
    var apiEnvironment: APIEnvironment { get set }

    /// The resolved base URL derived from the current `apiEnvironment`.
    var apiBaseURL: URL { get }
}

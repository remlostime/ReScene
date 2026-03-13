//
//  MockSettingsService.swift
//  ReScene
//

import Foundation
import Observation

/// In-memory implementation of `SettingsServiceProtocol` for previews and testing.
@Observable
final class MockSettingsService: SettingsServiceProtocol, @unchecked Sendable {

    var apiEnvironment: APIEnvironment = .google

    var apiBaseURL: URL {
        apiEnvironment.baseURL
    }
}

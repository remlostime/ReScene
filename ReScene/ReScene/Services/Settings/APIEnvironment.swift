//
//  APIEnvironment.swift
//  ReScene
//

import Foundation

/// Represents the available backend API environments.
enum APIEnvironment: String, Codable, CaseIterable, Sendable {
    case dev
    case prod

    var baseURL: URL {
        switch self {
        case .dev:
            URL(string: "http://localhost:8080")!
        case .prod:
            URL(string: "https://rescene-api-568316754281.us-west1.run.app")!
        }
    }

    var displayName: String {
        switch self {
        case .dev: "Dev"
        case .prod: "Prod"
        }
    }
}

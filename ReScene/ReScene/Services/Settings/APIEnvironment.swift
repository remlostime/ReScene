//
//  APIEnvironment.swift
//  ReScene
//

import Foundation

/// Represents the available backend API environments.
enum APIEnvironment: String, Codable, CaseIterable, Sendable {
    case dev
    case google
    case aws

    var baseURL: URL {
        switch self {
        case .dev:
            URL(string: "http://localhost:8080")!
        case .google:
            URL(string: "https://rescene-api-568316754281.us-west1.run.app")!
        case .aws:
            URL(string: "https://twybjyvj4w.us-east-1.awsapprunner.com")!
        }
    }

    var displayName: String {
        switch self {
        case .dev: "Dev"
        case .google: "Google"
        case .aws: "AWS"
        }
    }
}

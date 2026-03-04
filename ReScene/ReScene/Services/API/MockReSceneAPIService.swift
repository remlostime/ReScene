//
//  MockReSceneAPIService.swift
//  ReScene
//

import Foundation

/// Mock implementation of `ReSceneAPIServiceProtocol` for previews and testing.
///
/// Simulates a network delay and returns four placeholder remastered image URLs
/// with location-inspired style descriptions.
final class MockReSceneAPIService: ReSceneAPIServiceProtocol {

    /// When `true`, `remaster(photo:)` will throw `AppError.apiRequestFailed`.
    var shouldFail = false

    /// Simulated network latency.
    var simulatedDelay: Duration = .seconds(3)

    // MARK: - ReSceneAPIServiceProtocol

    func remaster(photo: PhotoData) async throws -> RemasteredResult {
        if shouldFail {
            throw AppError.apiRequestFailed(underlying: "Mock network failure")
        }

        try await Task.sleep(for: simulatedDelay)

        let mockURLs = (1...RemasteredResult.variantCount).map { index in
            URL(string: "https://picsum.photos/seed/rescene\(index)/800/600")!
        }

        let styles = [
            "Golden Hour Glow",
            "Cinematic Noir",
            "Vibrant Local Palette",
            "Dreamy Watercolor"
        ]

        return RemasteredResult(
            originalPhoto: photo,
            remasteredImageURLs: mockURLs,
            styleDescriptions: styles
        )
    }
}

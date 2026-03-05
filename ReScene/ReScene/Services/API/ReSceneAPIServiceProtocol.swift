//
//  ReSceneAPIServiceProtocol.swift
//  ReScene
//

import Foundation

/// Defines the contract for communicating with the ReScene AI backend.
///
/// Conforming types send a photo with location context to the Fastify
/// backend and return three AI-generated remastering options.
protocol ReSceneAPIServiceProtocol: Sendable {

    /// Analyzes a photo and returns creative remastering suggestions.
    ///
    /// - Parameters:
    ///   - imageData: Raw JPEG image bytes to be Base64-encoded for the request.
    ///   - latitude: Optional GPS latitude extracted from the photo's EXIF.
    ///   - longitude: Optional GPS longitude extracted from the photo's EXIF.
    ///   - locationName: Optional human-readable place name for location-aware suggestions.
    /// - Throws: `AppError` variants for network, decoding, or server-side failures.
    /// - Returns: An array of exactly 3 `RemasterOption` items.
    func analyzeImage(
        imageData: Data,
        latitude: Double?,
        longitude: Double?,
        locationName: String?
    ) async throws -> [RemasterOption]
}

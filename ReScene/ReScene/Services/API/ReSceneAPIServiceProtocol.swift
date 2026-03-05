//
//  ReSceneAPIServiceProtocol.swift
//  ReScene
//

import Foundation

/// Defines the contract for communicating with the ReScene AI backend.
///
/// Conforming types handle the two-step workflow:
/// 1. Analyze a photo to get remastering options and a server-side `imageId`.
/// 2. Render a selected option using the `imageId` to produce a final image URL.
protocol ReSceneAPIServiceProtocol: Sendable {

    /// Analyzes a photo and returns creative remastering suggestions.
    ///
    /// - Parameters:
    ///   - imageData: Raw JPEG image bytes to be Base64-encoded for the request.
    ///   - latitude: Optional GPS latitude extracted from the photo's EXIF.
    ///   - longitude: Optional GPS longitude extracted from the photo's EXIF.
    ///   - locationName: Optional human-readable place name for location-aware suggestions.
    /// - Throws: `AppError` variants for network, decoding, or server-side failures.
    /// - Returns: A tuple of the server-assigned `imageId` and exactly 3 `RemasterOption` items.
    func analyzeImage(
        imageData: Data,
        latitude: Double?,
        longitude: Double?,
        locationName: String?
    ) async throws -> (imageId: String, options: [RemasterOption])

    /// Renders a previously uploaded image with the selected style prompt.
    ///
    /// - Parameters:
    ///   - imageId: The UUID returned from `analyzeImage`, referencing the server-side image.
    ///   - prompt: The opaque `nano_prompt` string from the user's selected option.
    /// - Throws: `AppError` variants for network, decoding, or server-side failures.
    /// - Returns: A publicly accessible URL of the generated image.
    func renderImage(imageId: String, prompt: String) async throws -> URL
}

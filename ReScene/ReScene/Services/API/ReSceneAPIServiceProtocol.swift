//
//  ReSceneAPIServiceProtocol.swift
//  ReScene
//

import Foundation

/// Defines the contract for communicating with the ReScene AI backend.
///
/// Conforming types send a photo with location context to the Gemini/Imagen
/// backend and return four distinct AI-generated remastered variants.
protocol ReSceneAPIServiceProtocol: Sendable {

    /// Submits a photo and its geographic context for AI remastering.
    ///
    /// - Parameter photo: The photo data including image bytes and optional GPS coordinate.
    /// - Throws: `AppError.apiRequestFailed` on network or server errors,
    ///           `AppError.invalidResponse` if the response format is unexpected.
    /// - Returns: A `RemasteredResult` containing 4 remastered image URLs and style descriptions.
    func remaster(photo: PhotoData) async throws -> RemasteredResult
}

//
//  RemasteredResult.swift
//  ReScene
//

import Foundation

/// Holds the AI-generated remastering output for a single photo session.
///
/// Contains the original photo reference alongside four distinct
/// remastered variations, each with a style description and image URL.
struct RemasteredResult: Hashable, Sendable {

    /// The original photo that was submitted for remastering.
    let originalPhoto: PhotoData

    /// URLs pointing to the four AI-generated remastered images.
    ///
    /// The array is guaranteed to contain exactly 4 elements by the API contract.
    let remasteredImageURLs: [URL]

    /// Human-readable descriptions of each remastering style (e.g., "Golden Hour", "Noir").
    ///
    /// Index-aligned with `remasteredImageURLs`.
    let styleDescriptions: [String]

    /// Number of remastered variants (always 4 per design spec).
    static let variantCount = 4
}

//
//  AnalysisResult.swift
//  ReScene
//

import Foundation

/// Bundles the original photo with the AI-generated remastering options
/// returned by the analyze endpoint.
///
/// Replaces the former `RemasteredResult` that held image URLs.
struct AnalysisResult: Hashable, Sendable {

    /// The photo that was submitted for analysis.
    let originalPhoto: PhotoData

    /// The three creative-direction options returned by the backend.
    let options: [RemasterOption]

    /// Expected number of options per the API contract.
    static let optionCount = 3
}

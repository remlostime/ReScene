//
//  AnalysisResult.swift
//  ReScene
//

import Foundation

/// Bundles the original photo with the AI-generated remastering options
/// returned by the analyze endpoint.
///
/// The `imageId` is a server-side reference to the uploaded image,
/// required by `POST /api/render` to avoid re-uploading.
struct AnalysisResult: Hashable, Sendable {

    /// Server-assigned identifier for the uploaded image, used by `/api/render`.
    let imageId: String

    /// The photo that was submitted for analysis.
    let originalPhoto: PhotoData

    /// The three creative-direction options returned by the backend.
    let options: [RemasterOption]

    /// Expected number of options per the API contract.
    static let optionCount = 3
}

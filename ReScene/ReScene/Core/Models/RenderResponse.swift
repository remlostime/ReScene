//
//  RenderResponse.swift
//  ReScene
//

import Foundation

/// Response wrapper for `POST /api/render`.
///
/// Contains the publicly accessible URL of the AI-generated image.
struct RenderResponse: Decodable {
    let status: String
    let resultUrl: String
}

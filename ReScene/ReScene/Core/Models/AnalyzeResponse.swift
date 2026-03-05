//
//  AnalyzeResponse.swift
//  ReScene
//

import Foundation

/// Top-level response wrapper for `POST /api/analyze`.
///
/// Mirrors the JSON envelope: `{ "status": "success", "data": { "options": [...] } }`.
struct AnalyzeResponse: Decodable {
    let status: String
    let data: AnalyzeData

    struct AnalyzeData: Decodable {
        let options: [RemasterOption]
    }
}

/// Decodes the error body returned by the backend on 500 responses.
///
/// Shape: `{ "status": "error", "message": "..." }`
struct APIErrorResponse: Decodable {
    let status: String?
    let message: String?
    let error: String?
    let statusCode: Int?
}

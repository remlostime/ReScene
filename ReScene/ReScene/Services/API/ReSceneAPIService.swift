//
//  ReSceneAPIService.swift
//  ReScene
//

import CoreLocation
import Foundation

/// Production implementation of `ReSceneAPIServiceProtocol`.
///
/// Sends the photo and location context to the Gemini/Imagen backend
/// and decodes the response into a `RemasteredResult`.
///
/// - Note: The actual API endpoint is not yet configured. This skeleton
///   constructs the request structure and will be connected to the real
///   backend in a future iteration.
final class ReSceneAPIService: ReSceneAPIServiceProtocol {

    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://api.rescene.ai/v1")!
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    // MARK: - ReSceneAPIServiceProtocol

    func remaster(photo: PhotoData) async throws -> RemasteredResult {
        let endpoint = baseURL.appendingPathComponent("remaster")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = RemasterRequest(
            imageBase64: photo.imageData.base64EncodedString(),
            latitude: photo.coordinate?.latitude,
            longitude: photo.coordinate?.longitude
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw AppError.apiRequestFailed(underlying: "Server returned an error status code")
        }

        let decoded = try JSONDecoder().decode(RemasterResponse.self, from: data)

        guard decoded.imageURLs.count == RemasteredResult.variantCount,
              decoded.styleDescriptions.count == RemasteredResult.variantCount
        else {
            throw AppError.invalidResponse
        }

        return RemasteredResult(
            originalPhoto: photo,
            remasteredImageURLs: decoded.imageURLs,
            styleDescriptions: decoded.styleDescriptions
        )
    }
}

// MARK: - Request / Response DTOs

private struct RemasterRequest: Encodable {
    let imageBase64: String
    let latitude: Double?
    let longitude: Double?
}

private struct RemasterResponse: Decodable {
    let imageURLs: [URL]
    let styleDescriptions: [String]
}

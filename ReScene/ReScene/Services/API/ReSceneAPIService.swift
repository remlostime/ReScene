//
//  ReSceneAPIService.swift
//  ReScene
//

import Foundation

/// Production implementation of `ReSceneAPIServiceProtocol`.
///
/// Sends the photo and location context to the Fastify backend's
/// `/api/analyze` endpoint and decodes the remastering options.
final class ReSceneAPIService: ReSceneAPIServiceProtocol {

    private let session: URLSession
    private let settingsService: any SettingsServiceProtocol

    init(
        settingsService: any SettingsServiceProtocol,
        session: URLSession = .shared
    ) {
        self.settingsService = settingsService
        self.session = session
    }

    // MARK: - ReSceneAPIServiceProtocol

    func analyzeImage(
        imageData: Data,
        latitude: Double?,
        longitude: Double?,
        locationName: String?
    ) async throws -> [RemasterOption] {
        let endpoint = settingsService.apiBaseURL.appendingPathComponent("api/analyze")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let payload = AnalyzeRequest(
            imageBase64: imageData.base64EncodedString(),
            latitude: latitude,
            longitude: longitude,
            locationName: locationName
        )

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            throw AppError.decodingError(underlying: "Failed to encode request body")
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AppError.networkError(underlying: error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            let errorBody = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw AppError.badRequest(message: errorBody?.message ?? "Bad request")
        case 500...599:
            let errorBody = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw AppError.serverError(message: errorBody?.message ?? "Internal server error")
        default:
            throw AppError.apiRequestFailed(underlying: "HTTP \(httpResponse.statusCode)")
        }

        let decoded: AnalyzeResponse
        do {
            decoded = try JSONDecoder().decode(AnalyzeResponse.self, from: data)
        } catch {
            throw AppError.decodingError(underlying: error.localizedDescription)
        }

        guard decoded.data.options.count == AnalysisResult.optionCount else {
            throw AppError.invalidResponse
        }

        return decoded.data.options
    }
}

// MARK: - Request DTO

private struct AnalyzeRequest: Encodable {
    let imageBase64: String
    let latitude: Double?
    let longitude: Double?
    let locationName: String?
}

//
//  ReSceneAPIService.swift
//  ReScene
//

import Foundation

/// Production implementation of `ReSceneAPIServiceProtocol`.
///
/// Sends requests to the Fastify backend's `/api/analyze` and `/api/render`
/// endpoints and decodes the responses.
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
    ) async throws -> (imageId: String, options: [RemasterOption]) {
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

        let (data, httpResponse) = try await performRequest(request)

        try validateHTTPStatus(httpResponse, data: data)

        let decoded: AnalyzeResponse
        do {
            decoded = try JSONDecoder().decode(AnalyzeResponse.self, from: data)
        } catch {
            throw AppError.decodingError(underlying: error.localizedDescription)
        }

        guard decoded.data.options.count == AnalysisResult.optionCount else {
            throw AppError.invalidResponse
        }

        return (imageId: decoded.imageId, options: decoded.data.options)
    }

    func chat(
        imageId: String,
        message: String,
        history: [ChatHistoryMessage]
    ) async throws -> ChatResponseData {
        let endpoint = settingsService.apiBaseURL
            .appendingPathComponent("api/chat")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let payload = ChatRequest(
            imageId: imageId,
            message: message,
            history: history
        )

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            throw AppError.decodingError(
                underlying: "Failed to encode chat request body"
            )
        }

        let (data, httpResponse) = try await performRequest(request)

        try validateHTTPStatus(httpResponse, data: data)

        let decoded: ChatResponse
        do {
            decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        } catch {
            throw AppError.decodingError(underlying: error.localizedDescription)
        }

        return decoded.data
    }

    func renderImage(imageId: String, prompt: String) async throws -> URL {
        let endpoint = settingsService.apiBaseURL.appendingPathComponent("api/render")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let payload = RenderRequest(imageId: imageId, nanoPrompt: prompt)

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            throw AppError.decodingError(underlying: "Failed to encode request body")
        }

        let (data, httpResponse) = try await performRequest(request)

        try validateHTTPStatus(httpResponse, data: data)

        let decoded: RenderResponse
        do {
            decoded = try JSONDecoder().decode(RenderResponse.self, from: data)
        } catch {
            throw AppError.decodingError(underlying: error.localizedDescription)
        }

        guard let url = URL(string: decoded.resultUrl) else {
            throw AppError.invalidResponse
        }

        return url
    }

    // MARK: - Private Helpers

    private func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
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

        return (data, httpResponse)
    }

    private func validateHTTPStatus(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            break
        case 400:
            let errorBody = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw AppError.badRequest(message: errorBody?.message ?? "Bad request")
        case 500...599:
            let errorBody = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw AppError.serverError(message: errorBody?.message ?? "Internal server error")
        default:
            throw AppError.apiRequestFailed(underlying: "HTTP \(response.statusCode)")
        }
    }
}

// MARK: - Request DTOs

private struct AnalyzeRequest: Encodable {
    let imageBase64: String
    let latitude: Double?
    let longitude: Double?
    let locationName: String?
}

private struct ChatRequest: Encodable {
    let imageId: String
    let message: String
    let history: [ChatHistoryMessage]
}

private struct RenderRequest: Encodable {
    let imageId: String
    let nanoPrompt: String

    enum CodingKeys: String, CodingKey {
        case imageId
        case nanoPrompt = "nano_prompt"
    }
}

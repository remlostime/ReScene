//
//  AppError.swift
//  ReScene
//

import Foundation

/// Centralized error type for all domain-specific failures in the ReScene app.
///
/// Each case maps to a specific failure scenario across services, providing
/// user-facing descriptions via `LocalizedError` conformance.
enum AppError: LocalizedError, Equatable {

    // MARK: - Location Errors

    case locationPermissionDenied
    case locationFetchFailed(underlying: String)

    // MARK: - Photo Picker Errors

    case photoPickerCancelled
    case photoLoadFailed
    case noGPSData

    // MARK: - API Errors

    case invalidURL
    case networkError(underlying: String)
    case decodingError(underlying: String)
    case serverError(message: String)
    case badRequest(message: String)
    case apiRequestFailed(underlying: String)
    case invalidResponse

    // MARK: - Generic

    case unknown(String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            "Location access was denied. Please enable it in Settings to get location-aware remasters."
        case .locationFetchFailed(let underlying):
            "Failed to fetch your location: \(underlying)"
        case .photoPickerCancelled:
            "Photo selection was cancelled."
        case .photoLoadFailed:
            "Unable to load the selected photo. Please try a different image."
        case .noGPSData:
            "The selected photo does not contain GPS data. Location context will be unavailable."
        case .invalidURL:
            "The server URL is invalid. Please contact support."
        case .networkError(let underlying):
            "A network error occurred: \(underlying)"
        case .decodingError(let underlying):
            "Failed to read the server response: \(underlying)"
        case .serverError(let message):
            "Server error: \(message)"
        case .badRequest(let message):
            "Invalid request: \(message)"
        case .apiRequestFailed(let underlying):
            "The remastering request failed: \(underlying)"
        case .invalidResponse:
            "Received an invalid response from the server. Please try again."
        case .unknown(let message):
            "An unexpected error occurred: \(message)"
        }
    }
}

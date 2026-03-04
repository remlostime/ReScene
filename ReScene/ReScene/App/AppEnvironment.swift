//
//  AppEnvironment.swift
//  ReScene
//

import Foundation

/// Centralized dependency injection container for the ReScene app.
///
/// Holds protocol-typed references to all services, enabling seamless
/// swapping between live and mock implementations for production use,
/// SwiftUI previews, and unit testing.
struct AppEnvironment: Sendable {

    /// Service for device location access and coordinate retrieval.
    let locationService: any LocationServiceProtocol

    /// Service for photo selection and EXIF metadata extraction.
    let photoPickerService: any PhotoPickerServiceProtocol

    /// Service for communicating with the AI remastering backend.
    let apiService: any ReSceneAPIServiceProtocol

    // MARK: - Factory Methods

    /// Creates an environment wired with production service implementations.
    static func live() -> AppEnvironment {
        AppEnvironment(
            locationService: LocationService(),
            photoPickerService: PhotoPickerService(),
            apiService: ReSceneAPIService()
        )
    }

    /// Creates an environment wired with mock services for previews and testing.
    static func mock() -> AppEnvironment {
        AppEnvironment(
            locationService: MockLocationService(),
            photoPickerService: MockPhotoPickerService(),
            apiService: MockReSceneAPIService()
        )
    }
}

//
//  MockLocationService.swift
//  ReScene
//

import CoreLocation

/// Mock implementation of `LocationServiceProtocol` for previews and testing.
///
/// Returns a configurable static coordinate (defaults to San Francisco)
/// without requiring actual device location hardware.
final class MockLocationService: LocationServiceProtocol {

    /// The coordinate this mock will return. Defaults to San Francisco.
    var mockCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    /// Simulated authorization status.
    var mockAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse

    /// When `true`, `fetchCurrentLocation()` will throw `AppError.locationPermissionDenied`.
    var shouldFail = false

    // MARK: - LocationServiceProtocol

    @discardableResult
    func requestPermission() async -> CLAuthorizationStatus {
        mockAuthorizationStatus
    }

    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D {
        if shouldFail {
            throw AppError.locationPermissionDenied
        }
        try await Task.sleep(for: .milliseconds(300))
        return mockCoordinate
    }
}

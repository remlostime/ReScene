//
//  LocationService.swift
//  ReScene
//

import CoreLocation

/// Production implementation of `LocationServiceProtocol` backed by `CLLocationManager`.
///
/// Uses Swift Concurrency continuations to bridge CLLocationManager's
/// delegate-based API into async/await.
final class LocationService: NSObject, LocationServiceProtocol {

    private let manager = CLLocationManager()

    /// Continuation used to bridge the delegate callback for authorization changes.
    private var permissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    /// Continuation used to bridge the delegate callback for location updates.
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, any Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - LocationServiceProtocol

    @discardableResult
    func requestPermission() async -> CLAuthorizationStatus {
        let currentStatus = manager.authorizationStatus
        guard currentStatus == .notDetermined else { return currentStatus }

        return await withCheckedContinuation { continuation in
            permissionContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = await requestPermission()

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw AppError.locationPermissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        Task { @MainActor in
            permissionContinuation?.resume(returning: manager.authorizationStatus)
            permissionContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let coordinate = locations.first?.coordinate else {
                locationContinuation?.resume(throwing: AppError.locationFetchFailed(underlying: "No locations returned"))
                locationContinuation = nil
                return
            }
            locationContinuation?.resume(returning: coordinate)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: AppError.locationFetchFailed(underlying: error.localizedDescription))
            locationContinuation = nil
        }
    }
}

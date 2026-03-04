//
//  LocationServiceProtocol.swift
//  ReScene
//

import CoreLocation

/// Defines the contract for a service that manages device location access.
///
/// Conforming types handle permission requests and coordinate retrieval,
/// abstracting `CLLocationManager` behind a testable interface.
protocol LocationServiceProtocol: Sendable {

    /// Requests the user's authorization to access location when the app is in use.
    ///
    /// - Returns: The resulting authorization status after the user responds.
    @discardableResult
    func requestPermission() async -> CLAuthorizationStatus

    /// Fetches the device's current geographic coordinate.
    ///
    /// - Throws: `AppError.locationPermissionDenied` if authorization is insufficient,
    ///           `AppError.locationFetchFailed` if the underlying system call fails.
    /// - Returns: The device's current latitude/longitude.
    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D
}

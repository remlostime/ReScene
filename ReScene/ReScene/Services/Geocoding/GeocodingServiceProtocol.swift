//
//  GeocodingServiceProtocol.swift
//  ReScene
//

import CoreLocation

/// Defines the contract for a service that converts geographic coordinates
/// into human-readable place names via reverse geocoding.
protocol GeocodingServiceProtocol: Sendable {

    /// Attempts to resolve a coordinate into a place name (e.g., "Reykjavik, Iceland").
    ///
    /// This is a best-effort operation; returns `nil` when geocoding fails
    /// or no meaningful placemark is available.
    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async -> String?
}

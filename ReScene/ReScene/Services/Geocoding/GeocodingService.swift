//
//  GeocodingService.swift
//  ReScene
//

import CoreLocation

/// Production implementation of `GeocodingServiceProtocol` backed by `CLGeocoder`.
///
/// Combines the placemark's locality and country into a readable label.
/// Falls back gracefully to `nil` on any failure.
final class GeocodingService: GeocodingServiceProtocol {

    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        guard let placemark = try? await CLGeocoder()
            .reverseGeocodeLocation(location)
            .first
        else {
            return nil
        }

        let components = [placemark.locality, placemark.country].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

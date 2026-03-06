//
//  MockGeocodingService.swift
//  ReScene
//

import CoreLocation

/// Test / preview stub that returns a fixed place name.
final class MockGeocodingService: GeocodingServiceProtocol {

    var stubbedName: String? = "Tokyo, Japan"

    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async -> String? {
        stubbedName
    }
}

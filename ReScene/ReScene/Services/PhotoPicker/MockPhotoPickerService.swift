//
//  MockPhotoPickerService.swift
//  ReScene
//

import CoreLocation
import Foundation
import UIKit

/// Mock implementation of `PhotoPickerServiceProtocol` for previews and testing.
///
/// Returns a synthetic `PhotoData` with a solid-color placeholder image
/// and a predefined GPS coordinate (Paris, France).
final class MockPhotoPickerService: PhotoPickerServiceProtocol {

    /// When `true`, `loadPhoto(from:)` will throw `AppError.photoLoadFailed`.
    var shouldFail = false

    // MARK: - PhotoPickerServiceProtocol

    func loadPhoto(from imageData: Data?) async throws -> PhotoData {
        if shouldFail {
            throw AppError.photoLoadFailed
        }

        try await Task.sleep(for: .milliseconds(200))

        let placeholderImage = UIImage(systemName: "photo.fill")!
        let data = placeholderImage.pngData()!

        return PhotoData(
            id: UUID(),
            imageData: data,
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            locationName: "Paris, France"
        )
    }
}

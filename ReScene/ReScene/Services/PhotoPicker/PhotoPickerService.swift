//
//  PhotoPickerService.swift
//  ReScene
//

import CoreLocation
import Foundation
import ImageIO
import UIKit

/// Production implementation of `PhotoPickerServiceProtocol`.
///
/// Handles image data loading and EXIF GPS metadata extraction using
/// `ImageIO`'s `CGImageSource` API.
final class PhotoPickerService: PhotoPickerServiceProtocol {

    // MARK: - PhotoPickerServiceProtocol

    func loadPhoto(from imageData: Data?) async throws -> PhotoData {
        guard let imageData, !imageData.isEmpty else {
            throw AppError.photoLoadFailed
        }

        guard UIImage(data: imageData) != nil else {
            throw AppError.photoLoadFailed
        }

        let coordinate = extractGPSCoordinate(from: imageData)

        return PhotoData(
            id: UUID(),
            imageData: imageData,
            coordinate: coordinate,
            locationName: nil
        )
    }

    // MARK: - Private

    /// Extracts GPS latitude/longitude from EXIF metadata embedded in the image data.
    ///
    /// Uses `CGImageSource` to read the `{GPS}` dictionary from the image properties,
    /// then combines latitude, longitude, and their reference directions into a coordinate.
    private func extractGPSCoordinate(from data: Data) -> CLLocationCoordinate2D? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double
        else {
            return nil
        }

        let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String ?? "N"
        let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String ?? "E"

        let signedLat = latRef == "S" ? -latitude : latitude
        let signedLon = lonRef == "W" ? -longitude : longitude

        return CLLocationCoordinate2D(latitude: signedLat, longitude: signedLon)
    }
}

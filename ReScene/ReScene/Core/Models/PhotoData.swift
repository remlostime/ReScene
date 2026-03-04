//
//  PhotoData.swift
//  ReScene
//

import CoreLocation
import Foundation
import UIKit

/// Represents a user-selected photo along with its extracted geographic metadata.
///
/// `PhotoData` is the primary data object that flows through the app's pipeline:
/// photo selection -> processing -> result display.
struct PhotoData: Hashable, Sendable {

    /// Unique identifier for this photo selection session.
    let id: UUID

    /// Raw image data (JPEG/PNG) of the selected photo.
    let imageData: Data

    /// GPS coordinate extracted from the photo's EXIF metadata, if available.
    let coordinate: CLLocationCoordinate2D?

    /// Reverse-geocoded place name derived from the coordinate (e.g., "Paris, France").
    let locationName: String?

    // MARK: - Computed

    /// Convenience accessor to construct a `UIImage` from the stored data.
    var uiImage: UIImage? {
        UIImage(data: imageData)
    }

    // MARK: - Hashable

    /// CLLocationCoordinate2D is not natively Hashable, so we hash its components.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(imageData)
        hasher.combine(coordinate?.latitude)
        hasher.combine(coordinate?.longitude)
        hasher.combine(locationName)
    }

    static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        lhs.id == rhs.id
            && lhs.imageData == rhs.imageData
            && lhs.coordinate?.latitude == rhs.coordinate?.latitude
            && lhs.coordinate?.longitude == rhs.coordinate?.longitude
            && lhs.locationName == rhs.locationName
    }
}

//
//  PhotoPickerServiceProtocol.swift
//  ReScene
//

import UIKit

/// Defines the contract for a service that presents a photo picker and
/// extracts image data along with EXIF GPS metadata.
///
/// Conforming types wrap `PhotosUI`'s `PHPickerViewController` or equivalent,
/// handling the full lifecycle of image selection and metadata extraction.
protocol PhotoPickerServiceProtocol: Sendable {

    /// Loads a photo from picker results, extracting the image data and any embedded GPS coordinate.
    ///
    /// - Parameter pickerResult: The raw data from a `PhotosPicker` selection.
    /// - Throws: `AppError.photoPickerCancelled` if the user dismisses without selecting,
    ///           `AppError.photoLoadFailed` if image data cannot be read,
    ///           `AppError.noGPSData` as a recoverable warning (not necessarily thrown).
    /// - Returns: A `PhotoData` instance with the image bytes and optional coordinate.
    func loadPhoto(from imageData: Data?) async throws -> PhotoData
}

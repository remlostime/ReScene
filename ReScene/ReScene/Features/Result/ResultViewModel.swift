//
//  ResultViewModel.swift
//  ReScene
//

import Observation
import UIKit

/// Drives the result screen, exposing the original photo and four
/// AI-generated remastered variants for display and selection.
@Observable
final class ResultViewModel {

    // MARK: - Published State

    /// Index of the currently highlighted/selected remastered variant (0-3), if any.
    var selectedVariantIndex: Int?

    // MARK: - Dependencies

    private let result: RemasteredResult
    private let coordinator: AppCoordinator

    // MARK: - Init

    init(result: RemasteredResult, coordinator: AppCoordinator) {
        self.result = result
        self.coordinator = coordinator
    }

    // MARK: - Computed Properties

    /// The original photo's `UIImage` for display.
    var originalImage: UIImage? {
        result.originalPhoto.uiImage
    }

    /// Location label from the original photo, if available.
    var locationLabel: String? {
        if let name = result.originalPhoto.locationName {
            return name
        }
        if let coord = result.originalPhoto.coordinate {
            return String(format: "%.4f, %.4f", coord.latitude, coord.longitude)
        }
        return nil
    }

    /// The four remastered image URLs.
    var remasteredURLs: [URL] {
        result.remasteredImageURLs
    }

    /// The four style descriptions, index-aligned with URLs.
    var styleDescriptions: [String] {
        result.styleDescriptions
    }

    // MARK: - Actions

    /// Selects a specific remastered variant by index.
    func selectVariant(at index: Int) {
        selectedVariantIndex = index
    }

    /// Returns to the home screen to start a new remastering session.
    func startOver() {
        coordinator.popToRoot()
    }
}

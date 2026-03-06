//
//  ResultViewModel.swift
//  ReScene
//

import CoreLocation
import Observation
import UIKit

/// Drives the result screen, exposing the original photo and
/// AI-generated remastering options for display in a horizontal grid.
@Observable
final class ResultViewModel {

    // MARK: - Dependencies

    private let result: AnalysisResult
    private let coordinator: AppCoordinator
    private let geocodingService: any GeocodingServiceProtocol

    // MARK: - State

    /// Human-readable location label, initially populated with coordinates
    /// and lazily resolved to a place name via reverse geocoding.
    var locationLabel: String?

    // MARK: - Init

    init(
        result: AnalysisResult,
        coordinator: AppCoordinator,
        geocodingService: any GeocodingServiceProtocol
    ) {
        self.result = result
        self.coordinator = coordinator
        self.geocodingService = geocodingService

        if let name = result.originalPhoto.locationName {
            self.locationLabel = name
        } else if let coord = result.originalPhoto.coordinate {
            self.locationLabel = String(format: "%.4f, %.4f", coord.latitude, coord.longitude)
        }
    }

    // MARK: - Computed Properties

    /// The original photo's `UIImage` for display.
    var originalImage: UIImage? {
        result.originalPhoto.uiImage
    }

    /// The remastering options.
    var options: [RemasterOption] {
        result.options
    }

    // MARK: - Actions

    /// Navigates to the vibe detail screen for the given option.
    func showVibeDetail(option: RemasterOption) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        coordinator.showVibeDetail(option: option)
    }

    /// Pops back to the previous screen.
    func goBack() {
        coordinator.popToRoot()
    }

    /// Reverse-geocodes the photo's coordinate into a human-readable name.
    ///
    /// Skips the network call when a name is already available (e.g., from EXIF).
    func resolveLocationName() async {
        guard result.originalPhoto.locationName == nil,
              let coordinate = result.originalPhoto.coordinate
        else { return }

        if let name = await geocodingService.reverseGeocode(coordinate) {
            locationLabel = name
        }
    }
}

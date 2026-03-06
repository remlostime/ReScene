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

    // MARK: - Init

    init(result: AnalysisResult, coordinator: AppCoordinator) {
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
        coordinator.pop()
    }
}

//
//  ResultViewModel.swift
//  ReScene
//

import CoreLocation
import Observation
import UIKit

/// Drives the result screen, exposing the original photo and three
/// AI-generated remastering options for display and selection.
@Observable
final class ResultViewModel {

    // MARK: - Published State

    /// The option the user has tapped, if any.
    var selectedOption: RemasterOption?

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

    /// The three remastering options.
    var options: [RemasterOption] {
        result.options
    }

    /// Whether a vibe is selected and the user can proceed to rendering.
    var canProceed: Bool {
        selectedOption != nil
    }

    // MARK: - Actions

    /// Selects a remastering option by reference.
    func selectOption(_ option: RemasterOption) {
        selectedOption = option
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Navigates to the rendering screen with the currently selected option.
    func proceedToRendering() {
        guard let option = selectedOption else { return }
        coordinator.startRendering(option: option)
    }

    /// Returns to the home screen to start a new session.
    func startOver() {
        coordinator.popToRoot()
    }
}

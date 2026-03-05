//
//  ProcessingViewModel.swift
//  ReScene
//

import CoreLocation
import Foundation
import Observation

/// Drives the processing screen's state during the AI remastering operation.
///
/// Manages the API call lifecycle, updates progress for the animation layer,
/// and navigates to the result screen upon completion.
@Observable
final class ProcessingViewModel {

    // MARK: - Published State

    /// Normalized progress value (0.0 to 1.0) for the loading animation.
    var progress: Double = 0

    /// Human-readable status message shown during processing.
    var statusMessage = "Preparing your photo..."

    /// Set when the API call fails; triggers an alert in the view.
    var error: AppError?

    /// Controls visibility of the error alert.
    var showError = false

    /// Indicates whether processing has completed (success or failure).
    var isComplete = false

    // MARK: - Dependencies

    private let apiService: any ReSceneAPIServiceProtocol
    private let coordinator: AppCoordinator

    // MARK: - Init

    init(
        apiService: any ReSceneAPIServiceProtocol,
        coordinator: AppCoordinator
    ) {
        self.apiService = apiService
        self.coordinator = coordinator
    }

    // MARK: - Actions

    /// Kicks off the remastering pipeline.
    ///
    /// Runs a simulated progress animation in parallel with the actual API call,
    /// then navigates to the result screen on success.
    func startProcessing() async {
        guard let photo = coordinator.selectedPhoto else {
            presentError(.unknown("No photo selected for processing"))
            return
        }

        async let progressAnimation: Void = animateProgress()
        async let apiResult = callAPI(with: photo)

        await progressAnimation

        do {
            let result = try await apiResult
            progress = 1.0
            statusMessage = "Done!"
            isComplete = true

            try await Task.sleep(for: .milliseconds(400))
            coordinator.showResults(result)
        } catch let appError as AppError {
            presentError(appError)
        } catch {
            presentError(.unknown(error.localizedDescription))
        }
    }

    /// Allows the user to go back from the processing screen on error.
    func goBack() {
        coordinator.pop()
    }

    // MARK: - Private

    private func callAPI(with photo: PhotoData) async throws -> AnalysisResult {
        let (imageId, options) = try await apiService.analyzeImage(
            imageData: photo.imageData,
            latitude: photo.coordinate?.latitude,
            longitude: photo.coordinate?.longitude,
            locationName: photo.locationName
        )
        return AnalysisResult(imageId: imageId, originalPhoto: photo, options: options)
    }

    /// Drives a smooth progress animation over ~3 seconds with staged status messages.
    private func animateProgress() async {
        let stages: [(Double, String, Duration)] = [
            (0.15, "Analyzing geographic context...", .milliseconds(600)),
            (0.35, "Extracting visual features...", .milliseconds(700)),
            (0.55, "Crafting creative directions...", .milliseconds(800)),
            (0.75, "Curating remaster options...", .milliseconds(600)),
            (0.90, "Finalizing suggestions...", .milliseconds(500))
        ]

        for (stageProgress, message, delay) in stages {
            try? await Task.sleep(for: delay)
            progress = stageProgress
            statusMessage = message
        }
    }

    private func presentError(_ appError: AppError) {
        error = appError
        showError = true
        isComplete = true
    }
}

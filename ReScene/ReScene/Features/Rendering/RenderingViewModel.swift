//
//  RenderingViewModel.swift
//  ReScene
//

import Foundation
import Observation
import UIKit

/// Drives the rendering screen, calling `/api/render` and cycling through
/// dynamic loading messages while the server generates the final image.
@Observable
final class RenderingViewModel {

    // MARK: - Published State

    /// The cycling status message displayed during the render wait.
    var dynamicLoadingText = "Preparing your scene..."

    /// Set when the render call or image download fails.
    var error: AppError?

    /// Controls visibility of the error alert.
    var showError = false

    // MARK: - Computed

    /// The original image for the blurred background.
    var originalImage: UIImage? {
        coordinator.analysisResult?.originalPhoto.uiImage
    }

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

    /// Kicks off the render pipeline: calls the API, downloads the image, and navigates forward.
    func startRendering() async {
        guard let imageId = coordinator.analysisResult?.imageId,
              let prompt = coordinator.selectedOption?.nanoPrompt else {
            presentError(.unknown("Missing rendering context"))
            return
        }

        async let textCycling: Void = cycleLoadingText()

        do {
            let resultUrl = try await apiService.renderImage(imageId: imageId, prompt: prompt)
            let image = try await downloadImage(from: resultUrl)

            _ = await textCycling

            coordinator.showFinalResult(renderedImage: image)
        } catch let appError as AppError {
            presentError(appError)
        } catch {
            presentError(.unknown(error.localizedDescription))
        }
    }

    /// Allows the user to go back on error.
    func goBack() {
        coordinator.pop()
    }

    // MARK: - Private

    private static let loadingMessages = [
        "Extracting environment...",
        "Applying AI lighting...",
        "Blending color palette...",
        "Rendering final pixels...",
        "Adding finishing touches..."
    ]

    private func cycleLoadingText() async {
        for message in Self.loadingMessages {
            try? await Task.sleep(for: .seconds(2))
            dynamicLoadingText = message
        }
    }

    private func downloadImage(from url: URL) async throws -> UIImage {
        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw AppError.networkError(underlying: "Failed to download rendered image")
        }

        guard let image = UIImage(data: data) else {
            throw AppError.invalidResponse
        }

        return image
    }

    private func presentError(_ appError: AppError) {
        error = appError
        showError = true
    }
}

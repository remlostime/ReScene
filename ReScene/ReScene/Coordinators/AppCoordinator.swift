//
//  AppCoordinator.swift
//  ReScene
//

import Observation
import SwiftUI
import UIKit

// MARK: - Route

/// Navigation destinations within the ReScene workflow.
///
/// Routes are lightweight enum cases; the coordinator holds the actual
/// data payloads so we avoid `Hashable` conformance issues with complex types.
enum Route: Hashable {
    case processing
    case result
    case vibeDetail
    case rendering
    case finalResult
    case agentChat
}

// MARK: - AppCoordinator

/// Manages the app's navigation state and shared workflow data.
///
/// `AppCoordinator` owns the `NavigationPath` driving the root `NavigationStack`
/// and acts as the single source of truth for data that flows between screens
/// (selected photo, processing results, rendering output).
///
/// ViewModels receive a reference to the coordinator so they can trigger
/// navigation without coupling Views to navigation logic.
@Observable
final class AppCoordinator {

    /// The navigation path powering the root `NavigationStack`.
    var navigationPath = NavigationPath()

    /// The photo currently selected by the user, set by `HomeViewModel`.
    var selectedPhoto: PhotoData?

    /// The AI-generated analysis result containing remastering options, set by `ProcessingViewModel`.
    var analysisResult: AnalysisResult?

    /// The vibe option the user selected on the result screen, consumed by `RenderingViewModel`.
    var selectedOption: RemasterOption?

    /// The AI-rendered image downloaded after a successful render call.
    var renderedImage: UIImage?

    /// The DI container holding all service instances.
    let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    // MARK: - Navigation Actions

    /// Transitions to the processing screen after a photo has been selected.
    func startProcessing(with photo: PhotoData) {
        selectedPhoto = photo
        navigationPath.append(Route.processing)
    }

    /// Transitions to the result screen after AI analysis completes.
    func showResults(_ result: AnalysisResult) {
        analysisResult = result
        navigationPath.append(Route.result)
    }

    /// Transitions to the vibe detail screen after the user taps a vibe card.
    func showVibeDetail(option: RemasterOption) {
        selectedOption = option
        navigationPath.append(Route.vibeDetail)
    }

    /// Transitions to the rendering screen after the user picks a vibe.
    func startRendering(option: RemasterOption) {
        selectedOption = option
        navigationPath.append(Route.rendering)
    }

    /// Transitions to the final result screen after the rendered image is ready.
    func showFinalResult(renderedImage: UIImage) {
        self.renderedImage = renderedImage
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(Route.finalResult)
    }

    /// Transitions to the agent chat screen for freeform scene crafting.
    func showAgentChat() {
        navigationPath.append(Route.agentChat)
    }

    /// Pops one level back in the navigation stack.
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    /// Returns to the home screen, clearing all intermediate state.
    func popToRoot() {
        navigationPath = NavigationPath()
        selectedPhoto = nil
        analysisResult = nil
        selectedOption = nil
        renderedImage = nil
    }
}

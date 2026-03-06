//
//  ReSceneApp.swift
//  ReScene
//
//  Created by Kai Chen on 3/3/26.
//

import SwiftUI

/// The app's entry point, responsible for constructing the dependency graph
/// and wiring the coordinator-driven `NavigationStack`.
@main
struct ReSceneApp: App {

    /// The root coordinator managing navigation and shared workflow state.
    ///
    /// Swap `.live()` for `.mock()` in the initializer during development or testing.
    @State private var coordinator: AppCoordinator

    init() {
        let environment = AppEnvironment.live()
        _coordinator = State(initialValue: AppCoordinator(environment: environment))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.navigationPath) {
                HomeView(
                    viewModel: HomeViewModel(
                        locationService: coordinator.environment.locationService,
                        photoPickerService: coordinator.environment.photoPickerService,
                        coordinator: coordinator
                    )
                )
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .processing:
                        ProcessingView(
                            viewModel: ProcessingViewModel(
                                apiService: coordinator.environment.apiService,
                                coordinator: coordinator
                            )
                        )

                    case .result:
                        if let result = coordinator.analysisResult {
                            ResultView(
                                viewModel: ResultViewModel(
                                    result: result,
                                    coordinator: coordinator,
                                    geocodingService: coordinator.environment.geocodingService
                                )
                            )
                        }

                    case .vibeDetail:
                        if let option = coordinator.selectedOption,
                           let result = coordinator.analysisResult {
                            VibeDetailView(
                                option: option,
                                originalImage: result.originalPhoto.uiImage,
                                coordinator: coordinator
                            )
                        }

                    case .rendering:
                        RenderingView(
                            viewModel: RenderingViewModel(
                                apiService: coordinator.environment.apiService,
                                coordinator: coordinator
                            )
                        )

                    case .finalResult:
                        FinalResultView(coordinator: coordinator)
                    }
                }
            }
            #if DEBUG
            .devSettingsOnShake(settingsService: coordinator.environment.settingsService)
            #endif
        }
    }
}

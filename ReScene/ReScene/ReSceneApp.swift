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
                        if let result = coordinator.remasteredResult {
                            ResultView(
                                viewModel: ResultViewModel(
                                    result: result,
                                    coordinator: coordinator
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

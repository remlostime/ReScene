//
//  DevSettingsViewModel.swift
//  ReScene
//

#if DEBUG

import Observation
import Foundation

/// Manages state and logic for the Dev Settings screen.
///
/// Tracks the user's environment selection, persists changes through the
/// settings service, and handles the restart-confirmation / revert flow.
@Observable
final class DevSettingsViewModel {

    private let settingsService: any SettingsServiceProtocol

    /// The environment value when the view first appeared (used for revert).
    private var originalEnvironment: APIEnvironment

    /// The currently selected environment in the UI.
    var selectedEnvironment: APIEnvironment

    /// Controls the "Restart Required" alert presentation.
    var showRestartAlert = false

    init(settingsService: any SettingsServiceProtocol) {
        self.settingsService = settingsService
        self.originalEnvironment = settingsService.apiEnvironment
        self.selectedEnvironment = settingsService.apiEnvironment
    }

    /// Called when the user taps a different environment option.
    func selectEnvironment(_ environment: APIEnvironment) {
        guard environment != selectedEnvironment else { return }
        selectedEnvironment = environment
        settingsService.apiEnvironment = environment
        showRestartAlert = true
    }

    /// Called when the user cancels the restart alert -- reverts to original.
    func revertSelection() {
        settingsService.apiEnvironment = originalEnvironment
        selectedEnvironment = originalEnvironment
    }

    /// Called when the user confirms the restart alert -- commits the change.
    func confirmSelection() {
        originalEnvironment = selectedEnvironment
    }
}

#endif

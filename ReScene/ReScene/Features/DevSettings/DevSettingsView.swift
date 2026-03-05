//
//  DevSettingsView.swift
//  ReScene
//

#if DEBUG

import SwiftUI

/// Debug-only settings screen for switching app configuration at runtime.
///
/// Presented as a sheet when the user performs a shake gesture.
struct DevSettingsView: View {

    @State private var viewModel: DevSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(settingsService: any SettingsServiceProtocol) {
        _viewModel = State(
            initialValue: DevSettingsViewModel(settingsService: settingsService)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(APIEnvironment.allCases, id: \.self) { env in
                        Button {
                            viewModel.selectEnvironment(env)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(env.displayName)
                                        .foregroundStyle(.primary)
                                    Text(env.baseURL.absoluteString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if viewModel.selectedEnvironment == env {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Text("API Base URL")
                }
            }
            .navigationTitle("Dev Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert(
                "Restart Required",
                isPresented: $viewModel.showRestartAlert
            ) {
                Button("Restart Later") {
                    viewModel.confirmSelection()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.revertSelection()
                }
            } message: {
                Text("The app needs to be restarted for this change to take effect.")
            }
        }
    }
}

#endif

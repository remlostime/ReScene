//
//  ShakeDetector.swift
//  ReScene
//

#if DEBUG

import SwiftUI
import UIKit

// MARK: - Shake Notification

extension Notification.Name {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}

// MARK: - UIWindow Shake Override

extension UIWindow {
    /// Forwards shake gestures as notifications so SwiftUI can react to them.
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
    }
}

// MARK: - SwiftUI Modifier

/// Presents a Dev Settings sheet when the device detects a shake gesture.
struct DevSettingsShakeModifier: ViewModifier {

    let settingsService: any SettingsServiceProtocol

    @State private var showDevSettings = false

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                showDevSettings = true
            }
            .sheet(isPresented: $showDevSettings) {
                DevSettingsView(settingsService: settingsService)
            }
    }
}

extension View {
    /// Attaches the shake-to-open Dev Settings behavior (DEBUG only).
    func devSettingsOnShake(settingsService: any SettingsServiceProtocol) -> some View {
        modifier(DevSettingsShakeModifier(settingsService: settingsService))
    }
}

#endif

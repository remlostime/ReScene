//
//  GlassButton.swift
//  ReScene
//

import SwiftUI

/// A reusable button styled with a glassmorphism effect (`.ultraThinMaterial`),
/// an SF Symbol icon, and haptic feedback on tap.
///
/// Usage:
/// ```swift
/// GlassButton(title: "Select Photo", systemImage: "photo.on.rectangle.angled") {
///     // action
/// }
/// ```
struct GlassButton: View {

    let title: String
    let systemImage: String
    let action: () -> Void

    /// Optional accent color override; defaults to the app's primary tint.
    var tintColor: Color = .primary

    /// Controls the button's enabled state.
    var isEnabled: Bool = true

    @State private var isPressed = false

    var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(isEnabled ? tintColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    // MARK: - Private

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [.indigo, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 20) {
            GlassButton(
                title: "Select Photo",
                systemImage: "photo.on.rectangle.angled"
            ) {}

            GlassButton(
                title: "Disabled",
                systemImage: "xmark.circle",
                action: {},
                isEnabled: false
            )
        }
        .padding()
    }
}

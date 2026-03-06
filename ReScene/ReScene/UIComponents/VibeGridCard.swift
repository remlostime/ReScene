//
//  VibeGridCard.swift
//  ReScene
//

import SwiftUI

/// A compact glassmorphism card for the horizontal vibe grid.
///
/// Shows an icon badge and title only. The icon is derived from
/// keywords in the option title, matching the logic in `OptionCard`.
struct VibeGridCard: View {

    let option: RemasterOption
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                iconBadge
                Text(option.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(option.title)
    }

    // MARK: - Icon Badge

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 44, height: 44)

            Image(systemName: iconName)
                .font(.system(size: 18))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
        }
    }

    private var iconName: String {
        let lowered = option.title.lowercased()
        if lowered.contains("sunset") || lowered.contains("golden") {
            return "sun.horizon.fill"
        } else if lowered.contains("blossom") || lowered.contains("cherry") || lowered.contains("dream") {
            return "leaf.fill"
        } else if lowered.contains("neon") || lowered.contains("night") || lowered.contains("cyber") {
            return "sparkles"
        } else if lowered.contains("rain") || lowered.contains("storm") {
            return "cloud.rain.fill"
        } else if lowered.contains("snow") || lowered.contains("winter") {
            return "snowflake"
        } else if lowered.contains("mist") || lowered.contains("fog") || lowered.contains("mystic") {
            return "cloud.fog.fill"
        } else if lowered.contains("vibrant") || lowered.contains("bloom") {
            return "camera.filters"
        }
        return "wand.and.stars"
    }
}

// MARK: - Scale Button Style

/// A button style that scales down on press without using a `DragGesture`,
/// so it doesn't conflict with surrounding `ScrollView` gestures.
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [.black, .indigo.opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        HStack(spacing: 12) {
            VibeGridCard(
                option: RemasterOption(
                    title: "Cinematic Sunset",
                    description: "为场景打造温暖的黄金时刻氛围。",
                    nanoPrompt: "Transform to golden hour."
                ),
                onTap: {}
            )

            VibeGridCard(
                option: RemasterOption(
                    title: "Cherry Blossom Dream",
                    description: "添加浪漫的粉色花瓣。",
                    nanoPrompt: "Add cherry blossom petals."
                ),
                onTap: {}
            )

            VibeGridCard(
                option: RemasterOption(
                    title: "Neon Night",
                    description: "转变为赛博朋克夜景。",
                    nanoPrompt: "Transform to cyberpunk night."
                ),
                onTap: {}
            )
        }
        .padding()
    }
}

//
//  OptionCard.swift
//  ReScene
//

import SwiftUI

/// A glassmorphism card displaying a single remastering option.
///
/// Shows the English title, Chinese description, and a select indicator.
/// Triggers haptic feedback via its `onSelect` closure.
struct OptionCard: View {

    let option: RemasterOption
    let isSelected: Bool
    var onSelect: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                iconBadge

                VStack(alignment: .leading, spacing: 6) {
                    Text(option.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(option.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected
                            ? Color.white.opacity(0.6)
                            : Color.white.opacity(0.15),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("\(option.title): \(option.description)")
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
        }
        return "wand.and.stars"
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

        VStack(spacing: 16) {
            OptionCard(
                option: RemasterOption(
                    title: "Cinematic Sunset",
                    description: "为场景打造温暖的黄金时刻氛围，柔和的夕阳光线洒满整个场景。",
                    nanoPrompt: "Transform background to golden hour."
                ),
                isSelected: true,
                onSelect: {}
            )

            OptionCard(
                option: RemasterOption(
                    title: "Neon Night",
                    description: "将场景转变为充满霓虹灯光的赛博朋克夜景。",
                    nanoPrompt: "Transform to cyberpunk night."
                ),
                isSelected: false,
                onSelect: {}
            )
        }
        .padding()
    }
}

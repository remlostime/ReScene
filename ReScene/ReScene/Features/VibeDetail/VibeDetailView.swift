//
//  VibeDetailView.swift
//  ReScene
//

import SwiftUI

/// Displays the full details of a selected remastering vibe and lets
/// the user proceed to rendering by tapping "Apply This Vibe".
struct VibeDetailView: View {

    let option: RemasterOption
    let originalImage: UIImage?
    let coordinator: AppCoordinator

    @State private var contentAppeared = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        photoSection
                        vibeInfoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }

                applyButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) {
                contentAppeared = true
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [.black, .indigo.opacity(0.3), .purple.opacity(0.15)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Photo

    private var photoSection: some View {
        Group {
            if let uiImage = originalImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 280)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
            }
        }
    }

    // MARK: - Vibe Info

    private var vibeInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                iconBadge

                Text(option.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            Text(option.description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.75))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(contentAppeared ? 1 : 0)
        .offset(y: contentAppeared ? 0 : 20)
    }

    // MARK: - Apply Button

    @State private var isButtonPressed = false

    private var applyButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            coordinator.startRendering(option: option)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Text("Apply This Vibe")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .purple.opacity(0.4), radius: 16, y: 6)
            .scaleEffect(isButtonPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isButtonPressed = true }
                .onEnded { _ in isButtonPressed = false }
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .padding(.top, 8)
        .opacity(contentAppeared ? 1 : 0)
        .offset(y: contentAppeared ? 0 : 12)
    }

    // MARK: - Icon Badge

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 48, height: 48)

            Image(systemName: iconName)
                .font(.system(size: 20))
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

// MARK: - Preview

#Preview {
    let coordinator = AppCoordinator(environment: .mock())

    NavigationStack {
        VibeDetailView(
            option: RemasterOption(
                title: "Cinematic Sunset",
                description: "为场景打造温暖的黄金时刻氛围，柔和的夕阳光线洒满整个场景。",
                nanoPrompt: "Transform to golden hour."
            ),
            originalImage: UIImage(systemName: "photo"),
            coordinator: coordinator
        )
    }
}

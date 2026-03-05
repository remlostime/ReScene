//
//  ResultView.swift
//  ReScene
//

import CoreLocation
import SwiftUI

/// Displays the original photo alongside three AI-generated remastering
/// options in a vertically scrollable, premium selection UI.
struct ResultView: View {

    @Bindable var viewModel: ResultViewModel

    @State private var cardsAppeared = false
    @State private var imageScale: CGFloat = 1.05

    var body: some View {
        ZStack {
            background

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    originalPhotoSection
                    optionsSection
                    actionSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                imageScale = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                cardsAppeared = true
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Scene")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            if let location = viewModel.locationLabel {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(location)
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Original Photo

    private var originalPhotoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ORIGINAL")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.5))
                .tracking(1.5)

            if let uiImage = viewModel.originalImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 240)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(imageScale)
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

    // MARK: - Options

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CHOOSE YOUR VIBE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.5))
                .tracking(1.5)

            ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                OptionCard(
                    option: option,
                    isSelected: viewModel.selectedOption == option,
                    onSelect: { viewModel.selectOption(option) }
                )
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 30)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.12),
                    value: cardsAppeared
                )
            }
        }
    }

    // MARK: - Actions

    private var actionSection: some View {
        VStack(spacing: 12) {
            GlassButton(
                title: "Apply This Vibe",
                systemImage: "wand.and.stars",
                action: { viewModel.proceedToRendering() },
                tintColor: .white,
                isEnabled: viewModel.canProceed
            )

            Button {
                viewModel.startOver()
            } label: {
                Text("Start Over")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

// MARK: - Preview

#Preview {
    let coordinator = AppCoordinator(environment: .mock())
    let mockPhoto = PhotoData(
        id: UUID(),
        imageData: UIImage(systemName: "photo")!.pngData()!,
        coordinate: .init(latitude: 35.6586, longitude: 139.7454),
        locationName: "Tokyo Tower"
    )
    let mockResult = AnalysisResult(
        imageId: "mock-preview-id",
        originalPhoto: mockPhoto,
        options: [
            RemasterOption(
                title: "Cinematic Sunset",
                description: "为场景打造温暖的黄金时刻氛围，柔和的夕阳光线洒满整个场景。",
                nanoPrompt: "Transform to golden hour."
            ),
            RemasterOption(
                title: "Cherry Blossom Dream",
                description: "以东京铁塔标志性的樱花季为灵感，添加浪漫的粉色花瓣。",
                nanoPrompt: "Add cherry blossom petals."
            ),
            RemasterOption(
                title: "Neon Night",
                description: "将场景转变为充满霓虹灯光的赛博朋克夜景。",
                nanoPrompt: "Transform to cyberpunk night."
            )
        ]
    )

    ResultView(
        viewModel: ResultViewModel(result: mockResult, coordinator: coordinator)
    )
}

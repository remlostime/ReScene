//
//  ResultView.swift
//  ReScene
//

import CoreLocation
import SwiftUI

/// Displays the original photo alongside AI-generated remastering
/// options in a horizontal grid selection UI.
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await viewModel.resolveLocationName()
        }
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

            HStack(spacing: 12) {
                ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                    VibeGridCard(
                        option: option,
                        onTap: { viewModel.showVibeDetail(option: option) }
                    )
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.12),
                        value: cardsAppeared
                    )
                }
            }

            makeYourOwnCard
        }
    }

    // MARK: - Make Your Own

    private var makeYourOwnCard: some View {
        Button { viewModel.showAgentChat() } label: {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 18))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
            }

            Text("Make Your Own")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.purple.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .opacity(cardsAppeared ? 1 : 0)
        .offset(y: cardsAppeared ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7)
                .delay(0.36),
            value: cardsAppeared
        )
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

    NavigationStack {
        ResultView(
            viewModel: ResultViewModel(
                result: mockResult,
                coordinator: coordinator,
                geocodingService: MockGeocodingService()
            )
        )
    }
}

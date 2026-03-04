//
//  ResultView.swift
//  ReScene
//

import CoreLocation
import SwiftUI

/// Displays the original photo alongside a 2x2 grid of AI-generated
/// remastered variants, allowing the user to browse and select a favorite.
struct ResultView: View {

    @Bindable var viewModel: ResultViewModel

    /// Staggered entrance animation state.
    @State private var cardsAppeared = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            background

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    originalPhotoSection
                    remasteredGridSection
                    actionSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                cardsAppeared = true
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [.black, .indigo.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Remasters")
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
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Remastered Grid

    private var remasteredGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REMASTERED")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.5))
                .tracking(1.5)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(0..<RemasteredResult.variantCount, id: \.self) { index in
                    RemasteredCard(
                        imageURL: viewModel.remasteredURLs[index],
                        styleDescription: viewModel.styleDescriptions[index],
                        index: index,
                        onSelect: { viewModel.selectVariant(at: index) }
                    )
                    .overlay(selectionBorder(for: index))
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 30)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                        value: cardsAppeared
                    )
                }
            }
        }
    }

    /// Highlights the selected card with a colored border.
    private func selectionBorder(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                viewModel.selectedVariantIndex == index
                    ? Color.white
                    : Color.clear,
                lineWidth: 2
            )
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedVariantIndex)
    }

    // MARK: - Actions

    private var actionSection: some View {
        VStack(spacing: 12) {
            GlassButton(
                title: "Start Over",
                systemImage: "arrow.counterclockwise",
                action: { viewModel.startOver() },
                tintColor: .white
            )
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
        coordinate: .init(latitude: 48.8566, longitude: 2.3522),
        locationName: "Paris, France"
    )
    let mockResult = RemasteredResult(
        originalPhoto: mockPhoto,
        remasteredImageURLs: (1...4).map { URL(string: "https://picsum.photos/seed/r\($0)/400/300")! },
        styleDescriptions: ["Golden Hour", "Cinematic Noir", "Vibrant Palette", "Watercolor"]
    )

    ResultView(
        viewModel: ResultViewModel(result: mockResult, coordinator: coordinator)
    )
}

//
//  RemasteredCard.swift
//  ReScene
//

import SwiftUI

/// A card view displaying a single AI-remastered image variant with its style label.
///
/// Uses `AsyncImage` to load the remastered image from a URL, with a
/// glassmorphism label overlay at the bottom.
struct RemasteredCard: View {

    let imageURL: URL
    let styleDescription: String
    let index: Int

    /// Called when the user taps this card to select it.
    var onSelect: (() -> Void)?

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onSelect?()
        } label: {
            ZStack(alignment: .bottom) {
                // Remastered image loaded asynchronously
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(4 / 3, contentMode: .fill)
                    case .failure:
                        errorPlaceholder
                    case .empty:
                        loadingPlaceholder
                    @unknown default:
                        loadingPlaceholder
                    }
                }
                .frame(minHeight: 120)
                .clipped()

                // Style label with glass overlay
                Text(styleDescription)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remastered option \(index + 1): \(styleDescription)")
    }

    // MARK: - Subviews

    private var loadingPlaceholder: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .aspectRatio(4 / 3, contentMode: .fill)
            .overlay {
                ProgressView()
                    .tint(.white)
            }
    }

    private var errorPlaceholder: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .aspectRatio(4 / 3, contentMode: .fill)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                    Text("Failed to load")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                RemasteredCard(
                    imageURL: URL(string: "https://picsum.photos/seed/demo\(index)/400/300")!,
                    styleDescription: ["Golden Hour", "Cinematic Noir", "Vibrant Palette", "Watercolor"][index],
                    index: index
                )
            }
        }
        .padding()
    }
}

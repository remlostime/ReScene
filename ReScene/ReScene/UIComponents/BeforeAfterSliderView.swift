//
//  BeforeAfterSliderView.swift
//  ReScene
//

import SwiftUI
import UIKit

/// A drag-to-reveal comparison slider that stacks a "before" and "after"
/// image on top of each other with a movable vertical divider.
///
/// The after image is masked so only the portion to the left of the
/// divider is visible, creating a smooth wipe-reveal effect.
struct BeforeAfterSliderView: View {

    let beforeImage: UIImage
    let afterImage: UIImage

    @State private var sliderPosition: CGFloat = 0.5
    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let xPosition = sliderPosition * width

            ZStack {
                beforeLayer
                afterLayer(width: width, xPosition: xPosition)
                divider(xPosition: xPosition, height: geometry.size.height)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        sliderPosition = min(max(value.location.x / width, 0), 1)
                    }
            )
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    // MARK: - Layers

    private var beforeLayer: some View {
        Image(uiImage: beforeImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }

    private func afterLayer(width: CGFloat, xPosition: CGFloat) -> some View {
        Image(uiImage: afterImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .mask(
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: xPosition)
                    Spacer(minLength: 0)
                }
            )
    }

    // MARK: - Divider

    private func divider(xPosition: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 2, height: height)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 0)

            handle
        }
        .position(x: xPosition, y: height / 2)
    }

    private var handle: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)

            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(.black.opacity(0.6))
        }
        .scaleEffect(isDragging ? 1.15 : 1.0)
        .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.7), value: isDragging)
    }

    // MARK: - Helpers

    private var aspectRatio: CGFloat {
        let size = beforeImage.size
        guard size.height > 0 else { return 1 }
        return size.width / size.height
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        if let image = UIImage(systemName: "photo.artframe") {
            BeforeAfterSliderView(
                beforeImage: image,
                afterImage: image
            )
            .padding(20)
        }
    }
}

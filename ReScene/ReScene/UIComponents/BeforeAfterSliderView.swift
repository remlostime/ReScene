//
//  BeforeAfterCompareView.swift
//  ReScene
//

import SwiftUI
import UIKit

/// A press-and-hold comparison view that shows the "after" image by default
/// and crossfades to the "before" image while the user holds down.
///
/// Releasing the press animates back to the "after" image automatically
/// via `@GestureState` reset behavior.
struct BeforeAfterCompareView: View {

    let beforeImage: UIImage
    let afterImage: UIImage

    @GestureState private var isShowingBefore = false

    var body: some View {
        ZStack {
            Image(uiImage: afterImage)
                .resizable()
                .aspectRatio(contentMode: .fill)

            Image(uiImage: beforeImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(isShowingBefore ? 1 : 0)

            labelBadge
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .gesture(
            LongPressGesture(minimumDuration: .infinity)
                .updating($isShowingBefore) { _, state, _ in
                    state = true
                }
        )
        .aspectRatio(aspectRatio, contentMode: .fit)
        .animation(.easeInOut(duration: 0.25), value: isShowingBefore)
    }

    // MARK: - Label

    private var labelBadge: some View {
        VStack {
            HStack {
                Spacer()
                Text(isShowingBefore ? "BEFORE" : "AFTER")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.5), in: Capsule())
            }
            Spacer()
        }
        .padding(12)
    }

    // MARK: - Helpers

    private var aspectRatio: CGFloat {
        let size = afterImage.size
        guard size.height > 0 else { return 1 }
        return size.width / size.height
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        if let image = UIImage(systemName: "photo.artframe") {
            BeforeAfterCompareView(
                beforeImage: image,
                afterImage: image
            )
            .padding(20)
        }
    }
}

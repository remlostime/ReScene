//
//  TypingIndicatorView.swift
//  ReScene
//

import SwiftUI

/// Animated three-dot typing indicator shown while the agent is composing a response.
struct TypingIndicatorView: View {

    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 7, height: 7)
                    .offset(y: animating ? -4 : 4)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .onAppear { animating = true }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TypingIndicatorView()
    }
}

//
//  ChatMessageBubbleView.swift
//  ReScene
//

import SwiftUI

/// Renders a single chat message bubble, adapting its layout and style
/// based on sender (user vs. agent), content type (text, image, generating).
struct ChatMessageBubbleView: View {

    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isCurrentUser { Spacer(minLength: 48) }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 8) {
                if message.isGenerating {
                    typingBubble
                } else {
                    if let text = message.text {
                        textBubble(text)
                    }

                    if message.imageUrl != nil {
                        imageBubble
                    }
                }
            }

            if !message.isCurrentUser { Spacer(minLength: 48) }
        }
    }

    // MARK: - Text Bubble

    private func textBubble(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if message.isCurrentUser {
                    AnyView(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else {
                    AnyView(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Image Bubble

    private var imageBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.08))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )

            HStack(spacing: 12) {
                imageActionButton(title: "Save", icon: "arrow.down.circle.fill")
                imageActionButton(title: "Tweak", icon: "slider.horizontal.3")
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func imageActionButton(title: String, icon: String) -> some View {
        Button {} label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white.opacity(0.1), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Typing Bubble

    private var typingBubble: some View {
        TypingIndicatorView()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
    }

}

// MARK: - Preview

#Preview("Agent text") {
    ZStack {
        Color.black.ignoresSafeArea()
        ChatMessageBubbleView(
            message: ChatMessage(
                text: "I see your photo. What kind of cinematic vibe?",
                isCurrentUser: false
            )
        )
        .padding()
    }
}

#Preview("User text") {
    ZStack {
        Color.black.ignoresSafeArea()
        ChatMessageBubbleView(
            message: ChatMessage(text: "Make it look like golden hour", isCurrentUser: true)
        )
        .padding()
    }
}

#Preview("Image bubble") {
    ZStack {
        Color.black.ignoresSafeArea()
        ChatMessageBubbleView(
            message: ChatMessage(
                text: "Here's a preview:",
                isCurrentUser: false,
                imageUrl: URL(string: "https://example.com/img.jpg")
            )
        )
        .padding()
    }
}

#Preview("Typing") {
    ZStack {
        Color.black.ignoresSafeArea()
        ChatMessageBubbleView(
            message: ChatMessage(isCurrentUser: false, isGenerating: true)
        )
        .padding()
    }
}

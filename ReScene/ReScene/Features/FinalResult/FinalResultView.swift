//
//  FinalResultView.swift
//  ReScene
//

import Photos
import SwiftUI
import UIKit

/// Presents the before/after comparison view and action buttons for
/// saving the AI-rendered image.
struct FinalResultView: View {

    let coordinator: AppCoordinator

    @State private var savedToPhotos = false
    @State private var showPermissionAlert = false
    @State private var sliderAppeared = false
    @State private var isSavePressed = false
    @State private var isStartOverPressed = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                sliderSection
                    .padding(.horizontal, 16)

                Spacer(minLength: 20)

                actionBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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
        .alert(
            "Photo Library Access Required",
            isPresented: $showPermissionAlert
        ) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please grant photo library access in Settings to save your remastered image.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                sliderAppeared = true
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [.black, .indigo.opacity(0.25), .purple.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("Your Remaster")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            if let title = coordinator.selectedOption?.title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Comparison

    private var sliderSection: some View {
        Group {
            if let before = coordinator.analysisResult?.originalPhoto.uiImage,
               let after = coordinator.renderedImage {
                BeforeAfterCompareView(
                    beforeImage: before,
                    afterImage: after
                )
                .opacity(sliderAppeared ? 1 : 0)
                .scaleEffect(sliderAppeared ? 1 : 0.92)
            }
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        VStack(spacing: 12) {
            saveButton
            startOverButton
        }
    }

    private var saveButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            saveToPhotos()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: savedToPhotos ? "checkmark.circle.fill" : "square.and.arrow.down")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Text(savedToPhotos ? "Saved!" : "Save to Photos")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: savedToPhotos
                        ? [.green.opacity(0.8), .mint.opacity(0.7)]
                        : [.indigo, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: savedToPhotos ? .green.opacity(0.3) : .purple.opacity(0.4), radius: 16, y: 6)
            .scaleEffect(isSavePressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSavePressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isSavePressed = true }
                .onEnded { _ in isSavePressed = false }
        )
    }

    private var startOverButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            coordinator.popToRoot()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Text("Start Over")
                    .font(.headline)
            }
            .foregroundStyle(.white.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isStartOverPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isStartOverPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isStartOverPressed = true }
                .onEnded { _ in isStartOverPressed = false }
        )
    }

    // MARK: - Save

    private func saveToPhotos() {
        guard let image = coordinator.renderedImage else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    savedToPhotos = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                default:
                    showPermissionAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let coordinator = AppCoordinator(environment: .mock())
    FinalResultView(coordinator: coordinator)
}

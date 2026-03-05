//
//  FinalResultView.swift
//  ReScene
//

import Photos
import SwiftUI
import UIKit

/// Presents the before/after comparison slider and action buttons for
/// saving or sharing the AI-rendered image.
struct FinalResultView: View {

    let coordinator: AppCoordinator

    @State private var showShareSheet = false
    @State private var savedToPhotos = false
    @State private var showPermissionAlert = false
    @State private var sliderAppeared = false

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
        .sheet(isPresented: $showShareSheet) {
            if let image = coordinator.renderedImage {
                ActivityViewController(activityItems: [image])
                    .presentationDetents([.medium, .large])
            }
        }
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

    // MARK: - Slider

    private var sliderSection: some View {
        Group {
            if let before = coordinator.analysisResult?.originalPhoto.uiImage,
               let after = coordinator.renderedImage {
                ZStack(alignment: .top) {
                    BeforeAfterSliderView(
                        beforeImage: before,
                        afterImage: after
                    )

                    HStack {
                        label("BEFORE")
                        Spacer()
                        label("AFTER")
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }
                .opacity(sliderAppeared ? 1 : 0)
                .scaleEffect(sliderAppeared ? 1 : 0.92)
            }
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .tracking(1.2)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.black.opacity(0.5), in: Capsule())
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GlassButton(
                    title: savedToPhotos ? "Saved!" : "Save to Photos",
                    systemImage: savedToPhotos ? "checkmark.circle.fill" : "square.and.arrow.down",
                    action: saveToPhotos,
                    tintColor: savedToPhotos ? .green : .white
                )

                GlassButton(
                    title: "Share",
                    systemImage: "square.and.arrow.up",
                    action: { showShareSheet = true },
                    tintColor: .white
                )
            }

            Button {
                coordinator.popToRoot()
            } label: {
                Text("Start Over")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.top, 4)
        }
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

// MARK: - UIActivityViewController Wrapper

/// Bridges `UIActivityViewController` into SwiftUI for sharing images.
private struct ActivityViewController: UIViewControllerRepresentable {

    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    let coordinator = AppCoordinator(environment: .mock())
    FinalResultView(coordinator: coordinator)
}

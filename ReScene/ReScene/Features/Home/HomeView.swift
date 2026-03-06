//
//  HomeView.swift
//  ReScene
//

import PhotosUI
import SwiftUI

/// The app's landing screen featuring a glassmorphism UI with a photo picker.
/// Selecting a photo navigates directly to the processing screen.
struct HomeView: View {

    @Bindable var viewModel: HomeViewModel

    /// Controls the mesh gradient animation on the background.
    @State private var animateBackground = false

    var body: some View {
        ZStack {
            animatedBackground
            mainContent
        }
        .onChange(of: viewModel.pickerItem) {
            Task { await viewModel.handlePhotoSelection() }
        }
        .alert(
            "Something went wrong",
            isPresented: $viewModel.showError,
            presenting: viewModel.error
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { appError in
            Text(appError.localizedDescription)
        }
    }

    // MARK: - Background

    private var animatedBackground: some View {
        LinearGradient(
            colors: [
                .indigo.opacity(0.8),
                .purple.opacity(0.6),
                .pink.opacity(0.4),
                .orange.opacity(0.3)
            ],
            startPoint: animateBackground ? .topLeading : .bottomLeading,
            endPoint: animateBackground ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateBackground.toggle()
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            headerSection
                .padding(.bottom, 40)

            pickerSection

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)

            Text("ReScene")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("AI-powered photo remastering\nwith geographic context")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Photo Picker

    private var pickerSection: some View {
        VStack(spacing: 20) {
            PhotosPicker(
                selection: $viewModel.pickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)

                    Text("Select Photo")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
            }

            if viewModel.isLoading {
                ProgressView("Loading photo...")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
    }

}

// MARK: - Preview

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            locationService: MockLocationService(),
            photoPickerService: MockPhotoPickerService(),
            coordinator: AppCoordinator(environment: .mock())
        )
    )
}

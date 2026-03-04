//
//  HomeView.swift
//  ReScene
//

import PhotosUI
import SwiftUI

/// The app's landing screen featuring a glassmorphism UI with a photo picker
/// and a preview of the selected image before proceeding to remastering.
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

            if let photo = viewModel.selectedPhoto, let uiImage = photo.uiImage {
                photoPreviewSection(uiImage: uiImage, photo: photo)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                pickerSection
                    .transition(.opacity)
            }

            Spacer()

            if viewModel.selectedPhoto != nil {
                actionButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.selectedPhoto)
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

    // MARK: - Photo Preview

    private func photoPreviewSection(uiImage: UIImage, photo: PhotoData) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

            if let locationName = photo.locationName {
                locationBadge(locationName)
            } else if photo.coordinate != nil {
                locationBadge("GPS data found")
            } else {
                locationBadge("No location data", icon: "location.slash")
            }
        }
    }

    private func locationBadge(_ text: String, icon: String = "location.fill") -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            GlassButton(
                title: "Remaster This Photo",
                systemImage: "wand.and.stars",
                action: { viewModel.proceedToProcessing() },
                tintColor: .white
            )

            Button {
                viewModel.resetSelection()
            } label: {
                Text("Choose Different Photo")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
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

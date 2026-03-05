//
//  RenderingView.swift
//  ReScene
//

import SwiftUI

/// An immersive loading screen displayed while the server renders the
/// AI-remastered image. Shows the original photo blurred in the background
/// with cycling status messages.
struct RenderingView: View {

    @Bindable var viewModel: RenderingViewModel

    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            blurredBackground
            content
        }
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.startRendering() }
        .alert(
            "Rendering Failed",
            isPresented: $viewModel.showError,
            presenting: viewModel.error
        ) { _ in
            Button("Go Back", role: .cancel) {
                viewModel.goBack()
            }
        } message: { appError in
            Text(appError.localizedDescription)
        }
    }

    // MARK: - Blurred Background

    private var blurredBackground: some View {
        ZStack {
            if let uiImage = viewModel.originalImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .blur(radius: 40)
            }

            Color.black.opacity(0.4)
                .ignoresSafeArea()
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 40) {
            Spacer()

            animatedIcon

            VStack(spacing: 12) {
                Text("Rendering")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(viewModel.dynamicLoadingText)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.4), value: viewModel.dynamicLoadingText)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Animated Icon

    private var animatedIcon: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [.indigo, .purple, .pink, .orange, .indigo],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(rotationAngle))

            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 40))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .scaleEffect(pulseScale)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RenderingView(
        viewModel: RenderingViewModel(
            apiService: MockReSceneAPIService(),
            coordinator: AppCoordinator(environment: .mock())
        )
    )
}

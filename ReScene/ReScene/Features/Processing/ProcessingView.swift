//
//  ProcessingView.swift
//  ReScene
//

import SwiftUI

/// A visually rich loading screen displayed while the AI backend processes the photo.
///
/// Features a pulsing icon animation, a smooth progress bar, and staged status messages
/// that update as processing advances.
struct ProcessingView: View {

    @Bindable var viewModel: ProcessingViewModel

    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            background
            content
        }
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.startProcessing() }
        .alert(
            "Processing Failed",
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

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [
                .black,
                .indigo.opacity(0.4),
                .purple.opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 40) {
            Spacer()

            animatedIcon
            statusSection
            progressBar

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Animated Icon

    private var animatedIcon: some View {
        ZStack {
            // Outer ring
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

            // Center icon
            Image(systemName: "wand.and.stars")
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

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 12) {
            Text("Remastering")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: viewModel.statusMessage)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 6)

                    // Fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.indigo, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * viewModel.progress,
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                }
            }
            .frame(height: 6)

            Text("\(Int(viewModel.progress * 100))%")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
        }
    }
}

// MARK: - Preview

#Preview {
    ProcessingView(
        viewModel: ProcessingViewModel(
            apiService: MockReSceneAPIService(),
            coordinator: AppCoordinator(environment: .mock())
        )
    )
}

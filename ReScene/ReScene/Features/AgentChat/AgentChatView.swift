//
//  AgentChatView.swift
//  ReScene
//

import SwiftUI

/// Collaborative AI director studio where the user chats with the Gemini Agent
/// to craft the perfect environment for their scene.
struct AgentChatView: View {

    @State private var viewModel: AgentChatViewModel
    @FocusState private var isInputFocused: Bool

    init(viewModel: AgentChatViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header
                chatStream
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.messages.count)
        .alert(
            "Error",
            isPresented: $viewModel.showError,
            presenting: viewModel.error
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [.black, .indigo.opacity(0.3), .purple.opacity(0.15)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { viewModel.goBack() } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("AI Director")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()

            if let uiImage = viewModel.originalImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    )
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Chat Stream

    private var chatStream: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        ChatMessageBubbleView(message: message)
                            .id(message.id)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) {
                guard let lastId = viewModel.messages.last?.id else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 12) {
            renderButton
            inputBar
        }
    }

    // MARK: - Render Button

    @State private var isRenderPressed = false

    private var renderButton: some View {
        let hasProposal = viewModel.currentProposal != nil

        return Button { viewModel.renderProposal() } label: {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Text("Render Image")
                    .font(.headline)
            }
            .foregroundStyle(.white.opacity(hasProposal ? 1.0 : 0.35))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(hasProposal ? 1.0 : 0.3),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(hasProposal ? 0.25 : 0.1), lineWidth: 1)
            )
            .shadow(color: .purple.opacity(hasProposal ? 0.4 : 0.1), radius: 16, y: 6)
            .scaleEffect(isRenderPressed ? 0.96 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: isRenderPressed
            )
        }
        .buttonStyle(.plain)
        .disabled(!hasProposal)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isRenderPressed = true }
                .onEnded { _ in isRenderPressed = false }
        )
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasProposal)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            Button {} label: {
                Image(systemName: "mic.fill")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            TextField("Describe your vision...", text: $viewModel.inputText)
                .font(.body)
                .foregroundStyle(.white)
                .tint(.purple)
                .focused($isInputFocused)
                .onSubmit { viewModel.sendMessage() }

            Button { viewModel.sendMessage() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? .white.opacity(0.25)
                            : .white
                    )
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 16, y: -4)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

#Preview {
    let coordinator = AppCoordinator(environment: .mock())
    let mockPhoto = PhotoData(
        id: UUID(),
        imageData: UIImage(systemName: "photo")!.pngData()!,
        coordinate: nil,
        locationName: nil
    )
    coordinator.analysisResult = AnalysisResult(
        imageId: "mock",
        originalPhoto: mockPhoto,
        options: []
    )

    return NavigationStack {
        AgentChatView(
            viewModel: AgentChatViewModel(
                apiService: MockReSceneAPIService(),
                coordinator: coordinator
            )
        )
    }
}

//
//  AgentChatViewModel.swift
//  ReScene
//

import Observation
import UIKit

/// Drives the Agent Chat screen, managing the conversation with the AI
/// Photography Director via `POST /api/chat` and bridging approved proposals
/// into the existing VibeDetail -> Rendering pipeline.
@Observable
final class AgentChatViewModel {

    // MARK: - Dependencies

    private let apiService: any ReSceneAPIServiceProtocol
    private let coordinator: AppCoordinator

    // MARK: - State

    var messages: [ChatMessage] = []
    var inputText: String = ""
    var currentProposal: ChatProposal?
    var error: AppError?
    var showError = false

    /// The full conversation history sent with each API call.
    /// Only `text` from each response is stored, never the proposal object.
    private var history: [ChatHistoryMessage] = []

    // MARK: - Computed

    var originalImage: UIImage? {
        coordinator.analysisResult?.originalPhoto.uiImage
    }

    private var imageId: String? {
        coordinator.analysisResult?.imageId
    }

    // MARK: - Init

    init(
        apiService: any ReSceneAPIServiceProtocol,
        coordinator: AppCoordinator
    ) {
        self.apiService = apiService
        self.coordinator = coordinator

        messages.append(
            ChatMessage(
                text: "I see your photo. What kind of cinematic vibe "
                    + "or weather would you like to apply?",
                isCurrentUser: false
            )
        )
    }

    // MARK: - Actions

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(text: trimmed, isCurrentUser: true))
        inputText = ""
        currentProposal = nil

        let placeholderId = UUID()
        messages.append(
            ChatMessage(id: placeholderId, isCurrentUser: false, isGenerating: true)
        )

        Task { @MainActor [weak self] in
            guard let self, let imageId = self.imageId else { return }

            do {
                let response = try await self.apiService.chat(
                    imageId: imageId,
                    message: trimmed,
                    history: self.history
                )

                self.history.append(ChatHistoryMessage(role: "user", text: trimmed))
                self.history.append(ChatHistoryMessage(role: "model", text: response.text))

                guard let index = self.messages.firstIndex(where: { $0.id == placeholderId })
                else { return }

                self.messages[index] = ChatMessage(
                    id: placeholderId,
                    text: response.text,
                    isCurrentUser: false
                )

                if response.type == "proposal_card" {
                    self.currentProposal = response.proposal
                }
            } catch let appError as AppError {
                self.replacePlaceholderWithError(id: placeholderId, error: appError)
            } catch {
                self.replacePlaceholderWithError(
                    id: placeholderId,
                    error: .unknown(error.localizedDescription)
                )
            }
        }
    }

    /// Converts the current proposal into a `RemasterOption` and navigates
    /// to the VibeDetail screen, entering the existing rendering pipeline.
    func renderProposal() {
        guard let proposal = currentProposal else { return }

        let option = RemasterOption(
            title: proposal.title,
            description: proposal.description,
            nanoPrompt: proposal.nanoPrompt
        )

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        coordinator.showVibeDetail(option: option)
    }

    func goBack() {
        coordinator.pop()
    }

    // MARK: - Private

    private func replacePlaceholderWithError(id: UUID, error: AppError) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index] = ChatMessage(
                id: id,
                text: "Something went wrong. Please try again.",
                isCurrentUser: false
            )
        }
        self.error = error
        showError = true
    }
}

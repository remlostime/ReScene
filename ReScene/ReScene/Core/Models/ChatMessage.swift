//
//  ChatMessage.swift
//  ReScene
//

import Foundation

/// A single message in the Agent Chat conversation.
///
/// Messages can be text-only, image-bearing (when the agent generates a preview),
/// or a transient "generating" placeholder that drives the typing indicator.
struct ChatMessage: Identifiable, Hashable {

    let id: UUID
    var text: String?
    let isCurrentUser: Bool
    var imageUrl: URL?
    var isGenerating: Bool

    init(
        id: UUID = UUID(),
        text: String? = nil,
        isCurrentUser: Bool,
        imageUrl: URL? = nil,
        isGenerating: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isCurrentUser = isCurrentUser
        self.imageUrl = imageUrl
        self.isGenerating = isGenerating
    }
}

//
//  ChatResponse.swift
//  ReScene
//

import Foundation

/// Top-level response wrapper for `POST /api/chat`.
///
/// Mirrors the JSON envelope:
/// `{ "status": "success", "data": { "type": "...", "text": "...", "proposal": {...} } }`.
struct ChatResponse: Decodable {
    let status: String
    let data: ChatResponseData
}

/// The payload inside a chat response, discriminated by `type`.
///
/// - `chat_reply`: Agent asks a clarifying question (only `text`).
/// - `proposal_card`: Agent proposes a rendering plan (`text` + `proposal`).
struct ChatResponseData: Decodable {
    let type: String
    let text: String
    let proposal: ChatProposal?
}

/// A rendering proposal returned by the AI director when the user's intent
/// is clear and actionable.
///
/// `nanoPrompt` is the technical prompt for the rendering model and should
/// **not** be displayed to the user.
struct ChatProposal: Decodable {
    let title: String
    let description: String
    let nanoPrompt: String

    enum CodingKeys: String, CodingKey {
        case title, description
        case nanoPrompt = "nano_prompt"
    }
}

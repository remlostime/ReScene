//
//  ChatHistoryMessage.swift
//  ReScene
//

import Foundation

/// A single entry in the conversation history sent with each `/api/chat` request.
///
/// The backend is stateless -- the full history must be passed every time.
/// Role alternation must strictly follow `user` -> `model` -> `user` -> `model`.
struct ChatHistoryMessage: Codable {
    let role: String
    let text: String
}

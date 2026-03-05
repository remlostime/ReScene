//
//  RemasterOption.swift
//  ReScene
//

import Foundation

/// A single AI-generated remastering suggestion returned by the `/api/analyze` endpoint.
///
/// Each option describes a creative direction the user can choose
/// before triggering the actual image generation step.
struct RemasterOption: Decodable, Identifiable, Hashable, Sendable {

    /// Locally generated identifier for SwiftUI list diffing.
    var id = UUID()

    /// Short, catchy English label (e.g. "Cinematic Sunset").
    let title: String

    /// User-facing Chinese description of the vibe/mood.
    let description: String

    /// Technical prompt for the downstream image-generation model.
    let nanoPrompt: String

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case nanoPrompt = "nano_prompt"
    }

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.nanoPrompt = try container.decode(String.self, forKey: .nanoPrompt)
    }

    // MARK: - Memberwise

    init(title: String, description: String, nanoPrompt: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.nanoPrompt = nanoPrompt
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(nanoPrompt)
    }

    static func == (lhs: RemasterOption, rhs: RemasterOption) -> Bool {
        lhs.title == rhs.title
            && lhs.description == rhs.description
            && lhs.nanoPrompt == rhs.nanoPrompt
    }
}

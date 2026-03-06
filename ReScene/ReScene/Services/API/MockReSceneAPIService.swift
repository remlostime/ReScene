//
//  MockReSceneAPIService.swift
//  ReScene
//

import Foundation

/// Mock implementation of `ReSceneAPIServiceProtocol` for previews and testing.
///
/// Simulates network delays and returns placeholder data for both
/// the analyze and render endpoints.
final class MockReSceneAPIService: ReSceneAPIServiceProtocol {

    /// When `true`, API calls will throw `AppError.serverError`.
    var shouldFail = false

    /// Simulated network latency for the analyze call.
    var simulatedDelay: Duration = .seconds(3)

    /// Simulated network latency for the render call.
    var simulatedRenderDelay: Duration = .seconds(5)

    /// Simulated network latency for the chat call.
    var simulatedChatDelay: Duration = .seconds(1.5)

    /// Tracks chat call count to alternate between reply and proposal.
    private var chatCallCount = 0

    // MARK: - ReSceneAPIServiceProtocol

    func analyzeImage(
        imageData: Data,
        latitude: Double?,
        longitude: Double?,
        locationName: String?
    ) async throws -> (imageId: String, options: [RemasterOption]) {
        if shouldFail {
            throw AppError.serverError(message: "Mock network failure")
        }

        try await Task.sleep(for: simulatedDelay)

        let options = [
            RemasterOption(
                title: "Cinematic Sunset",
                description: "为场景打造温暖的黄金时刻氛围，柔和的夕阳光线洒满整个场景。",
                nanoPrompt: "Transform the background lighting to warm golden hour with soft sun rays."
            ),
            RemasterOption(
                title: "Cherry Blossom Dream",
                description: "以标志性的樱花季为灵感，添加浪漫的粉色花瓣。",
                nanoPrompt: "Add cherry blossom branches and falling petals to the background."
            ),
            RemasterOption(
                title: "Neon Night",
                description: "将场景转变为充满霓虹灯光的赛博朋克夜景。",
                nanoPrompt: "Transform the background into a cyberpunk night scene with neon lights."
            )
        ]

        return (imageId: "mock-\(UUID().uuidString)", options: options)
    }

    func chat(
        imageId: String,
        message: String,
        history: [ChatHistoryMessage]
    ) async throws -> ChatResponseData {
        if shouldFail {
            throw AppError.serverError(message: "Mock chat failure")
        }

        try await Task.sleep(for: simulatedChatDelay)

        chatCallCount += 1

        if chatCallCount % 3 == 0 {
            return ChatResponseData(
                type: "proposal_card",
                text: "好的！根据你的描述，我为你准备了一个方案：",
                proposal: ChatProposal(
                    title: "Cyberpunk Neon Rain",
                    description: "将照片转变为充满赛博朋克风格的霓虹雨夜，"
                        + "霓虹灯光在湿润的地面上反射出迷幻色彩。",
                    nanoPrompt: "Transform the background into a "
                        + "cyberpunk night scene with neon rain."
                )
            )
        }

        let replies = [
            "你是想要赛博朋克霓虹风，还是复古胶片的酷感？",
            "明白了！你希望保留原始色调，还是完全重新调色？"
        ]
        let reply = replies[(chatCallCount - 1) % replies.count]

        return ChatResponseData(type: "chat_reply", text: reply, proposal: nil)
    }

    func renderImage(imageId: String, prompt: String) async throws -> URL {
        if shouldFail {
            throw AppError.serverError(message: "Mock render failure")
        }

        try await Task.sleep(for: simulatedRenderDelay)

        return URL(string: "https://picsum.photos/seed/rescene/1024/1024")!
    }
}

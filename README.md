# ReScene

**AI-powered photo remastering with geographic context.**

ReScene is a native iOS app (Swift / SwiftUI) that lets users upload a photo, receive AI-generated creative remastering suggestions based on the image and its location, and render a final remastered image — all driven by a Fastify backend that orchestrates the AI pipeline.

---

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [User Flow](#user-flow)
3. [Project Structure](#project-structure)
4. [Core Concepts](#core-concepts)
5. [Services](#services)
6. [Features (Screens)](#features-screens)
7. [Reusable UI Components](#reusable-ui-components)
8. [Navigation & Coordination](#navigation--coordination)
9. [Dependency Injection](#dependency-injection)
10. [API Contract](#api-contract)
11. [Dev Settings & Debug Tools](#dev-settings--debug-tools)
12. [Getting Started](#getting-started)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     ReScene iOS App                      │
│                                                         │
│  ┌───────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Views   │◄──►│  ViewModels  │───►│ Coordinator  │  │
│  │ (SwiftUI) │    │ (@Observable)│    │ (Navigation) │  │
│  └───────────┘    └──────┬───────┘    └──────────────┘  │
│                          │                               │
│                  ┌───────▼───────┐                       │
│                  │   Services    │                       │
│                  │  (Protocols)  │                       │
│                  └───────┬───────┘                       │
│                          │                               │
│              ┌───────────┼───────────┐                   │
│              ▼           ▼           ▼                   │
│         API Service  Location    PhotoPicker             │
│         Geocoding    Settings                            │
└──────────────┬──────────────────────────────────────────┘
               │ HTTPS
               ▼
┌──────────────────────────┐
│   Fastify Backend (AI)   │
│  /api/analyze            │
│  /api/render             │
│  /api/chat               │
└──────────────────────────┘
```

The app follows **MVVM + Coordinator** with **protocol-based dependency injection**. Every service has a protocol, a live implementation, and a mock — making the entire app previewable and testable without hitting the network.

---

## User Flow

```
Home ──► Processing ──► Result ──┬──► Vibe Detail ──► Rendering ──► Final Result
(pick      (POST             (3 AI     │                (POST           (before/after
 photo)     /api/analyze)     options)  │                /api/render)    + save)
                                        │
                                        └──► Agent Chat ──► Vibe Detail ──► ...
                                              (POST /api/chat — multi-turn conversation
                                               with AI Director)
```

1. **Home** — User picks a photo from their library.
2. **Processing** — Photo is uploaded to `/api/analyze` with GPS + location context. Animated progress bar plays while waiting.
3. **Result** — Displays 3 AI-generated "vibe" options (e.g., "Cinematic Sunset", "Cherry Blossom Dream") plus a "Make Your Own" card for the chat agent.
4. **Vibe Detail** — Full description of the selected vibe with an "Apply This Vibe" CTA.
5. **Rendering** — Calls `/api/render` with the selected `nano_prompt`. Shows blurred original image as background with cycling status messages.
6. **Final Result** — Before/after comparison (hold-to-compare). Save to Photos or start over.
7. **Agent Chat** (alternate path) — Multi-turn conversation with the AI Photography Director. When the agent proposes a rendering plan, the user can approve and enter the same Rendering pipeline.

---

## Project Structure

```
ReScene/
├── ReSceneApp.swift              # @main entry point, wires DI + NavigationStack
│
├── App/
│   └── AppEnvironment.swift      # DI container — holds all service references
│
├── Coordinators/
│   └── AppCoordinator.swift      # Navigation state + shared workflow data
│
├── Core/
│   ├── Errors/
│   │   └── AppError.swift        # Centralized error enum (LocalizedError)
│   └── Models/
│       ├── PhotoData.swift       # Photo + EXIF GPS metadata
│       ├── AnalysisResult.swift  # Bundles photo + imageId + 3 options
│       ├── AnalyzeResponse.swift # Decodable for POST /api/analyze
│       ├── RemasterOption.swift  # Single AI vibe suggestion (title, desc, nano_prompt)
│       ├── RenderResponse.swift  # Decodable for POST /api/render
│       ├── ChatMessage.swift     # Local chat bubble model (UI state)
│       ├── ChatResponse.swift    # Decodable for POST /api/chat
│       └── ChatHistoryMessage.swift # Codable for chat history array
│
├── Services/
│   ├── API/
│   │   ├── ReSceneAPIServiceProtocol.swift   # Contract: analyze, render, chat
│   │   ├── ReSceneAPIService.swift           # Live URLSession implementation
│   │   └── MockReSceneAPIService.swift       # Simulated delays + fixture data
│   ├── Settings/
│   │   ├── SettingsServiceProtocol.swift      # Contract: apiEnvironment, apiBaseURL
│   │   ├── SettingsService.swift              # UserDefaults-backed persistence
│   │   ├── MockSettingsService.swift          # In-memory for previews
│   │   └── APIEnvironment.swift               # dev (localhost:8080) / prod enum
│   ├── PhotoPicker/
│   │   ├── PhotoPickerServiceProtocol.swift   # Contract: loadPhoto(from:)
│   │   ├── PhotoPickerService.swift           # ImageIO EXIF GPS extraction
│   │   └── MockPhotoPickerService.swift       # Returns placeholder image
│   ├── Location/
│   │   ├── LocationServiceProtocol.swift      # Contract: requestPermission, fetchLocation
│   │   ├── LocationService.swift              # CLLocationManager + async/await bridge
│   │   └── MockLocationService.swift          # Returns static SF coordinate
│   └── Geocoding/
│       ├── GeocodingServiceProtocol.swift     # Contract: reverseGeocode(_:)
│       ├── GeocodingService.swift             # CLGeocoder wrapper
│       └── MockGeocodingService.swift         # Returns "Tokyo, Japan"
│
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift                     # Landing screen + PhotosPicker
│   │   └── HomeViewModel.swift                # Photo selection + GPS fallback
│   ├── Processing/
│   │   ├── ProcessingView.swift               # Animated loading screen
│   │   └── ProcessingViewModel.swift          # Calls /api/analyze + progress animation
│   ├── Result/
│   │   ├── ResultView.swift                   # Photo + 3 vibe cards grid
│   │   └── ResultViewModel.swift              # Exposes options + reverse geocoding
│   ├── VibeDetail/
│   │   └── VibeDetailView.swift               # Full vibe description + "Apply" CTA
│   ├── Rendering/
│   │   ├── RenderingView.swift                # Blurred bg + spinning icon
│   │   └── RenderingViewModel.swift           # Calls /api/render + image download
│   ├── AgentChat/
│   │   ├── AgentChatView.swift                # Chat UI with input bar + render button
│   │   ├── AgentChatViewModel.swift           # Multi-turn /api/chat conversation
│   │   ├── ChatMessageBubbleView.swift        # Sender-adaptive bubble component
│   │   └── TypingIndicatorView.swift          # Animated three-dot indicator
│   ├── FinalResult/
│   │   └── FinalResultView.swift              # Before/after + save to Photos
│   └── DevSettings/                           # DEBUG only
│       ├── DevSettingsView.swift              # API environment picker
│       └── DevSettingsViewModel.swift         # Persist + restart flow
│
└── UIComponents/
    ├── BeforeAfterSliderView.swift            # Hold-to-compare before/after
    ├── VibeGridCard.swift                     # Compact card for vibe grid
    ├── OptionCard.swift                       # Full-size option card
    ├── GlassButton.swift                      # Reusable glassmorphism button
    └── ShakeDetector.swift                    # DEBUG: shake gesture → Dev Settings
```

---

## Core Concepts

### Models

| Model | Purpose |
|-------|---------|
| `PhotoData` | Wraps the selected photo's raw image data + optional GPS coordinate + location name. Flows through the entire pipeline. |
| `AnalysisResult` | Bundles `PhotoData` with the server-assigned `imageId` and exactly 3 `RemasterOption` items returned by `/api/analyze`. |
| `RemasterOption` | A single AI-generated creative direction: English `title`, Chinese `description`, and a technical `nanoPrompt` for the rendering model. |
| `ChatMessage` | Local UI model for chat bubbles — text, sender flag, optional image URL, and a generating state for the typing indicator. |
| `ChatHistoryMessage` | The `{role, text}` pair sent to the stateless `/api/chat` endpoint. Full history is re-sent every call. |
| `AppError` | Centralized `LocalizedError` enum covering location, photo picker, network, decoding, and server errors. |

### API Response Models

| Model | Endpoint |
|-------|----------|
| `AnalyzeResponse` | `POST /api/analyze` — wraps `imageId` + `options[]` |
| `RenderResponse` | `POST /api/render` — wraps `resultUrl` |
| `ChatResponse` / `ChatResponseData` / `ChatProposal` | `POST /api/chat` — either a `chat_reply` (text) or `proposal_card` (text + rendering proposal) |
| `APIErrorResponse` | Error body on 4xx/5xx responses |

---

## Services

Every service follows the **Protocol → Live → Mock** pattern. Protocols use `any` existential types and are `Sendable`.

### API Service (`ReSceneAPIServiceProtocol`)

The main backend communication layer. Three operations:

| Method | What it does |
|--------|-------------|
| `analyzeImage(imageData:latitude:longitude:locationName:)` | Base64-encodes the photo, sends it with GPS context to `/api/analyze`. Returns `(imageId, [RemasterOption])`. |
| `chat(imageId:message:history:)` | Sends a user message + full conversation history to `/api/chat`. Returns a text reply or a rendering proposal. |
| `renderImage(imageId:prompt:)` | Sends the `imageId` + `nano_prompt` to `/api/render`. Returns the URL of the generated image. |

The live implementation (`ReSceneAPIService`) uses `URLSession`, reads the base URL from `SettingsService`, and maps HTTP errors to `AppError`.

### Photo Picker Service (`PhotoPickerServiceProtocol`)

Loads image data from a `PhotosPicker` selection and extracts EXIF GPS coordinates using `CGImageSource` / `ImageIO`. Returns a `PhotoData` struct.

### Location Service (`LocationServiceProtocol`)

Wraps `CLLocationManager` with Swift Concurrency (`CheckedContinuation`). Used as a **fallback** when the selected photo has no EXIF GPS data — the app requests the device's current location instead.

### Geocoding Service (`GeocodingServiceProtocol`)

Reverse-geocodes a `CLLocationCoordinate2D` into a human-readable place name (e.g., "Paris, France") via `CLGeocoder`. Best-effort: returns `nil` on failure.

### Settings Service (`SettingsServiceProtocol`)

Persists the active `APIEnvironment` (dev / prod) in `UserDefaults`. Exposes the resolved `apiBaseURL` used by the API service.

---

## Features (Screens)

### Home (`HomeView` + `HomeViewModel`)

- Displays the app logo and a `PhotosPicker` button on an animated gradient background.
- On photo selection: loads image data, extracts EXIF GPS, falls back to device location if needed, then navigates to Processing.

### Processing (`ProcessingView` + `ProcessingViewModel`)

- Calls `analyzeImage` on the API service.
- Runs a staged progress animation (0% → 90%) in parallel with the real API call.
- On success: constructs `AnalysisResult` and navigates to Result.

### Result (`ResultView` + `ResultViewModel`)

- Shows the original photo, 3 vibe option cards in a horizontal grid, and a "Make Your Own" card.
- Lazily reverse-geocodes the photo's coordinate for the location badge.
- Tapping a vibe → Vibe Detail. Tapping "Make Your Own" → Agent Chat.

### Vibe Detail (`VibeDetailView`)

- Full-screen detail of a single `RemasterOption`: icon, title, Chinese description.
- "Apply This Vibe" button triggers `coordinator.startRendering(option:)`.

### Rendering (`RenderingView` + `RenderingViewModel`)

- Calls `renderImage` on the API service.
- Shows the original image blurred behind a spinning icon + cycling status messages.
- Downloads the rendered image from the returned URL, then navigates to Final Result.

### Agent Chat (`AgentChatView` + `AgentChatViewModel`)

- Multi-turn conversational interface with the AI Photography Director.
- Sends messages to `/api/chat` with the full conversation history (backend is stateless).
- Responses are either `chat_reply` (clarifying question) or `proposal_card` (actionable rendering plan with `nano_prompt`).
- When a proposal is received, the "Render Image" button activates. Approving converts the proposal to a `RemasterOption` and enters the standard Vibe Detail → Rendering pipeline.

### Final Result (`FinalResultView`)

- Press-and-hold before/after comparison using `BeforeAfterCompareView`.
- "Save to Photos" (requests `PHPhotoLibrary` add-only permission).
- "Start Over" returns to Home and clears all state.

### Dev Settings (`DevSettingsView` + `DevSettingsViewModel`) — DEBUG only

- Shake the device to open.
- Switch between `dev` (localhost:8080) and `prod` API environments.
- Persists the change and prompts for an app restart.

---

## Reusable UI Components

| Component | Description |
|-----------|-------------|
| `BeforeAfterCompareView` | Hold-to-compare overlay. Shows "AFTER" by default; crossfades to "BEFORE" while pressing. Uses `@GestureState` for auto-reset. |
| `VibeGridCard` | Compact glassmorphism card for the horizontal vibe selection grid. Icon derived from keywords in the option title. |
| `OptionCard` | Full-width option card with icon, title, description, and selection checkmark. |
| `GlassButton` | Reusable `.ultraThinMaterial` button with SF Symbol, haptic feedback, and press-scale animation. |
| `ChatMessageBubbleView` | Renders a single chat bubble — adapts layout for user (gradient) vs. agent (material). Supports text, image preview, and typing indicator states. |
| `TypingIndicatorView` | Animated three-dot bounce indicator shown while the agent is composing. |
| `ShakeDetector` | DEBUG-only: intercepts `UIWindow.motionEnded` shake gestures and posts a notification to trigger the Dev Settings sheet. |

---

## Navigation & Coordination

Navigation is driven by `AppCoordinator`, an `@Observable` class that owns:

- **`navigationPath`** — The `NavigationPath` powering the root `NavigationStack`.
- **Shared workflow data** — `selectedPhoto`, `analysisResult`, `selectedOption`, `renderedImage`.

ViewModels receive a reference to the coordinator and call methods like `startProcessing(with:)`, `showResults(_:)`, `startRendering(option:)`, etc. Views never directly manipulate navigation — they go through their ViewModel → Coordinator.

Routes are defined as a lightweight `Route` enum:

```swift
enum Route: Hashable {
    case processing
    case result
    case vibeDetail
    case rendering
    case finalResult
    case agentChat
}
```

The coordinator holds the actual data payloads, so routes stay simple and `Hashable`.

---

## Dependency Injection

`AppEnvironment` is the DI container — a simple struct holding protocol-typed references to every service:

```swift
struct AppEnvironment {
    let locationService:    any LocationServiceProtocol
    let photoPickerService: any PhotoPickerServiceProtocol
    let apiService:         any ReSceneAPIServiceProtocol
    let settingsService:    any SettingsServiceProtocol
    let geocodingService:   any GeocodingServiceProtocol
}
```

Two factory methods:
- **`.live()`** — Production services (network, CoreLocation, CLGeocoder, UserDefaults).
- **`.mock()`** — In-memory fakes with simulated delays. Used for SwiftUI Previews and testing.

The app entry point (`ReSceneApp.swift`) creates `AppEnvironment.live()` and passes it to the `AppCoordinator`. Swap to `.mock()` for preview/testing.

---

## API Contract

All endpoints live on the Fastify backend. Base URLs:

| Environment | URL |
|-------------|-----|
| **prod** | `https://rescene-api-568316754281.us-west1.run.app` |
| **dev** | `http://localhost:8080` |

### `POST /api/analyze`

Analyzes a photo and returns 3 creative remastering suggestions.

**Request:**
```json
{
  "imageBase64": "<base64 string>",
  "latitude": 48.8566,
  "longitude": 2.3522,
  "locationName": "Paris, France"
}
```

**Response (200):**
```json
{
  "status": "success",
  "imageId": "uuid-string",
  "data": {
    "options": [
      {
        "title": "Cinematic Sunset",
        "description": "中文描述...",
        "nano_prompt": "Technical prompt for the rendering model."
      }
    ]
  }
}
```

### `POST /api/render`

Renders the previously uploaded image with a selected style.

**Request:**
```json
{
  "imageId": "uuid-from-analyze",
  "nano_prompt": "Technical prompt string"
}
```

**Response (200):**
```json
{
  "status": "success",
  "resultUrl": "https://storage.example.com/rendered-image.png"
}
```

### `POST /api/chat`

Multi-turn conversation with the AI Photography Director.

**Request:**
```json
{
  "imageId": "uuid-from-analyze",
  "message": "Make it look like a rainy night in Tokyo",
  "history": [
    { "role": "user", "text": "..." },
    { "role": "model", "text": "..." }
  ]
}
```

**Response (200) — clarifying question:**
```json
{
  "status": "success",
  "data": {
    "type": "chat_reply",
    "text": "你是想要赛博朋克霓虹风，还是复古胶片的酷感？",
    "proposal": null
  }
}
```

**Response (200) — rendering proposal:**
```json
{
  "status": "success",
  "data": {
    "type": "proposal_card",
    "text": "好的！根据你的描述，我为你准备了一个方案：",
    "proposal": {
      "title": "Neon Rain Tokyo",
      "description": "中文描述...",
      "nano_prompt": "Technical prompt for rendering."
    }
  }
}
```

### Error Responses

```json
{
  "status": "error",
  "message": "Human-readable error message"
}
```

---

## Dev Settings & Debug Tools

In **DEBUG** builds only:

- **Shake to open Dev Settings** — `ShakeDetector` intercepts device shake gestures and presents a sheet where you can toggle between `dev` and `prod` API environments.
- **Mock environment** — Switch `AppEnvironment.live()` to `.mock()` in `ReSceneApp.swift` to run the entire app against fake data with simulated network delays.

---

## Getting Started

### Prerequisites

- Xcode 16+ (Swift 6 / iOS 18 SDK)
- iOS 17+ deployment target
- (Optional) Local backend running on `http://localhost:8080` for dev environment

### Build & Run

1. Clone the repo:
   ```bash
   git clone <repo-url> && cd ReScene
   ```
2. Open the Xcode project:
   ```bash
   open ReScene/ReScene.xcodeproj
   ```
3. Select a simulator or device and hit **Cmd+R**.

### Run Against Mock Data

In `ReSceneApp.swift`, change:
```swift
let environment = AppEnvironment.live()
```
to:
```swift
let environment = AppEnvironment.mock()
```

This wires all services to in-memory mocks with simulated delays — no backend needed.

### Switch API Environment at Runtime

On a **DEBUG** build, shake the device (or Ctrl+Cmd+Z in Simulator) to open Dev Settings and toggle between `dev` / `prod` endpoints.

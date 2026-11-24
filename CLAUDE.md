# Vibra iOS

Native iOS music streaming app (SwiftUI, Swift 6). Demo project for an iOS course. Talks to `vibra-backend` through an OpenAPI-generated client. Payments are simulated with StoreKit 2 local testing.

## Commands

```bash
# Build + test the app (list simulators first: xcrun simctl list devices available)
xcodebuild -scheme Vibra -destination 'platform=iOS Simulator,name=<simulator>' build
xcodebuild -scheme Vibra -destination 'platform=iOS Simulator,name=<simulator>' test

# Test a single local package (fast, preferred while iterating)
swift test --package-path Packages/<PackageName>

# Re-sync the API contract from vibra-contracts, then rebuild (regenerates the client)
./scripts/sync-contract.sh
```

Always run the relevant tests before saying a task is done. Prefer package-level `swift test` over full app builds while iterating.

## Architecture

MVVM + repositories, split into local Swift packages under `Packages/`:

- `Domain`: models and repository protocols. **No dependencies.**
- `Networking`: generated API client, auth interceptor, token refresh.
- `Persistence`: SwiftData cache and download metadata.
- `Playback`: `PlaybackService`, queue, Now Playing, remote commands.
- `Store`: StoreKit 2 service and `EntitlementsStore`.
- `DesignSystem`: colors, fonts, reusable views.
- `Features/{Auth,Home,Search,Library,Player,Store,Subscription,Settings}`.

The `Vibra/` app target is thin: composition root, dependency injection, navigation/router.

Data flow: `View → ViewModel (@Observable, @MainActor) → Repository (protocol in Domain) → Networking + Persistence`.

## Rules

- Features depend on `Domain` and `DesignSystem` only. **Never import one feature from another.** Cross-feature navigation goes through the router in the app target.
- No business logic or networking in views. Views render state and send intents to the ViewModel.
- Swift 6 strict concurrency stays on. Fix data-race warnings properly; do not silence them with `@unchecked Sendable` or `nonisolated(unsafe)` without a comment explaining why.
- Use `@Observable` (Observation framework), async/await, and actors. No Combine for new code, no completion handlers.
- No force unwraps (`!`) or `try!` outside tests and previews.
- Tokens live in the **Keychain only**. Never in UserDefaults, SwiftData, or logs.
- Token refresh lives in one actor so concurrent 401s trigger a single refresh.
- **Never hand-edit the generated API client or the synced `openapi.json`.** Change the contract in `vibra-contracts` and re-sync.
- Add dependencies (Swift packages) only after asking. Prefer Apple frameworks.
- User-facing strings go through `String(localized:)`.

## Playback (the riskiest part)

- A single app-wide `PlaybackService` wraps `AVPlayer`/`AVQueuePlayer`. It never lives inside a view or ViewModel.
- `AVAudioSession` category `.playback`; background mode "Audio" enabled.
- Lock screen and Control Center via `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter`.
- Handle interruptions (calls, Siri) and route changes (headphones unplugged).
- Audio is **FLAC** served from signed URLs with HTTP range requests. Previews are 30 s AAC.
- A `403` from `GET /v1/tracks/{id}/stream` carries a `previewUrl`; show the paywall and offer the preview.

## StoreKit 2 (demo mode)

- Products are defined in the local `Vibra.storekit` file (attached to the scheme). No App Store Connect.
- Subscription group with monthly + annual; non-consumables for a few albums/tracks, mapped by `store_product_id`.
- After a purchase, send the transaction to `POST /v1/storekit/transactions`. The backend trusts it in demo mode only.
- Listen to `Transaction.updates` from app launch.
- The `.storekit` renewal rate is set to "Monthly Renewal Every 30 Seconds" for demos.
- Free Apple account: do **not** add the "In-App Purchase" capability if Xcode refuses to sign. Test on the Simulator first.

## Widget / Live Activity

- `WidgetKit` + `ActivityKit` extension shows "Now Playing". Share data with the app through an App Group.
- Live Activities are started and updated locally from the app (no push).
- Verify App Groups and Background Modes work with the current signing team before building on them.

## Testing

- Swift Testing for ViewModels and repositories; mock the repository protocols from `Domain`.
- A few XCUITests for the critical flow (login → play a track → hit paywall).
- Do not call the real backend in unit tests.

## Gotchas

- Free Apple account builds expire after 7 days; reinstall from Xcode before a demo.
- Do not commit `xcuserdata/`, `DerivedData/`, or signing secrets.
- Keep `Vibra.xcodeproj` merges minimal; prefer package changes over target changes.

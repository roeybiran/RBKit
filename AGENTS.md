# Repository Guidelines

## Project Structure & Module Organization
The SwiftPM manifest `Package.swift` declares two libraries: `RBKit` for production code and `RBKitTestSupport` for fixtures. Shipping sources live under `Sources/RBKit`, with subfolders for `Dependencies`, `Extensions`, `Mocks`, `Protocols`, `Types`, and `UI Components`; match those buckets when adding files. Shared helpers for tests belong in `Sources/RBKitTestSupport`. XCTest targets sit in `Tests/RBKitTests`; mirror the directory names from `Sources` so navigation stays intuitive. The shared plan `RBKit.xctestplan` mirrors the SwiftPM setup for Xcode users.

## Build, Test, and Development Commands
Run `swift build` to compile every target with the Swift 6.2 toolchain. Execute `swift test` before each push; narrow the scope with `swift test --filter TypeNameTests/test_scenario`. If dependency pins change, call `swift package resolve` to update `Package.resolved`. Xcode workflows can use `xcodebuild test -testPlan RBKit` for IDE-driven validation.

## Coding Style & Naming Conventions
Use four spaces for indentation and keep lines near 120 characters. Follow Swift API Design Guidelines: `UpperCamelCase` for types/protocols, `lowerCamelCase` for values and functions, and boolean accessors prefixed with `is`, `has`, or `should`. Prefer focused extensions in their own files over catch-all utilities, and align filenames with the primary type (`TextAndImageTableCellView.swift`). Concurrency is opt-in with `StrictConcurrency` and default `@MainActor`; mark intentionally nonisolated work explicitly.

## Testing Guidelines
Write tests with XCTest and colocate them with the feature under test. Adopt the ``test_context_expectedBehavior`` naming style already in the suite. Place reusable doubles in `RBKitTestSupport` rather than duplicating mocks. Use `swift test --enable-code-coverage` when verifying large changes and capture failure diagnostics with `CustomDump` where useful.

## Commit & Pull Request Guidelines
Keep commit subjects in the imperative mood (`feat: add FileManagerClient`, `fix: restore selection state`) instead of `wip`. Include concise bodies that mention motivation and test coverage. Pull requests should link issues, list the manual or automated test plan, and attach screenshots or screencasts for UI updates. Stay focused by isolating unrelated refactors into separate commits.

## Dependency & Configuration Notes
Third-party dependencies are managed via SwiftPM; avoid manual vendoring. When adding a new package, update both `Package.swift` and `Package.resolved`, and verify license compatibility. Swift concurrency flags (`StrictConcurrency`, `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`) are enabled globally—respect actor isolation when introducing new APIs.

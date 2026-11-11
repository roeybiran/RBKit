// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RBKit",
  platforms: [.macOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "RBKit",
      targets: ["RBKit"],
    ),
    .library(
      name: "RBKitTestSupport",
      targets: ["RBKitTestSupport"],
    ),
    // Opt-in libraries. Each pulls in third-party packages that the `RBKit` product never does.
    .library(name: "HotKeyRecorder", targets: ["HotKeyRecorder"]),
    .library(name: "PermissionsKit", targets: ["PermissionsKit"]),
    .library(name: "OnboardingKit", targets: ["OnboardingKit"]),
    .library(name: "RBAnalytics", targets: ["RBAnalytics"]),
    .library(name: "SparkleExtras", targets: ["SparkleExtras"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-issue-reporting", from: "2.1.2"),
    .package(url: "https://github.com/airbnb/swift", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.26.2"),
    .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.2"),
    .package(url: "https://github.com/TelemetryDeck/SwiftSDK", from: "2.12.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "RBKit",
      dependencies: [
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "IssueReporting", package: "swift-issue-reporting"),
        .product(name: "Sharing", package: "swift-sharing"),
      ],
      resources: [
        .process("Resources")
      ],
    ),
    .target(
      name: "RBKitTestSupport"
    ),
    .testTarget(
      name: "RBKitTests",
      dependencies: [
        "RBKit",
        "RBKitTestSupport",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ],
    ),

    // MARK: - Opt-in targets

    .target(
      name: "HotKeyRecorder",
      dependencies: ["RBKit", .product(name: "ComposableArchitecture", package: "swift-composable-architecture")],
    ),
    .testTarget(
      name: "HotKeyRecorderTests",
      dependencies: [
        "HotKeyRecorder",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
      ],
    ),
    .target(
      name: "PermissionsKit",
      dependencies: ["RBKit", .product(name: "ComposableArchitecture", package: "swift-composable-architecture")],
    ),
    .testTarget(
      name: "PermissionsKitTests",
      dependencies: ["PermissionsKit"],
    ),
    .target(
      name: "OnboardingKit",
      dependencies: [
        "RBKit",
        "PermissionsKit",
        "RBAnalytics",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
    ),
    .testTarget(
      name: "OnboardingKitTests",
      dependencies: ["OnboardingKit"],
    ),
    .target(
      name: "RBAnalytics",
      dependencies: [
        "RBKit",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "TelemetryDeck", package: "SwiftSDK"),
      ],
    ),
    .testTarget(
      name: "RBAnalyticsTests",
      dependencies: ["RBAnalytics"],
    ),
    .target(
      name: "SparkleExtras",
      dependencies: [
        "RBKit",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Sparkle", package: "Sparkle"),
      ],
    ),
    .testTarget(
      name: "SparkleExtrasTests",
      dependencies: ["SparkleExtras"],
    ),
  ],
  swiftLanguageModes: [.v5],
)

for target in package.targets {
  var settings = target.swiftSettings ?? []
  settings.append(contentsOf: [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
  ])
  // RBKit itself is Swift 5 mode; the opt-in targets were written for Swift 6.
  if !["RBKit", "RBKitTestSupport", "RBKitTests"].contains(target.name) {
    settings.append(.swiftLanguageMode(.v6))
  }
  target.swiftSettings = settings
}

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RBKit",
  platforms: [.macOS(.v14)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "RBKit",
      targets: ["RBKit"]
    ),
    .library(
      name: "RBKitTestSupport",
      targets: ["RBKitTestSupport"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/airbnb/swift", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "RBKit",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableUpcomingFeature("InferSendableFromCaptures"),
      ]
    ),
    .target(
      name: "RBKitTestSupport"
    ),
    .testTarget(
      name: "RBKitTests",
      dependencies: [
        "RBKit",
        "RBKitTestSupport",
      ]
    ),
  ]
)

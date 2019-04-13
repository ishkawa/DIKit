// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "DIKit",
  platforms: [
      .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
  ],
  products: [
    .executable(name: "dikitgen", targets: ["dikitgen"]),
    .library(name: "DIKit", targets: ["DIKit"]),
    .library(name: "DIGenKit", targets: ["DIGenKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.23.0")
  ],
  targets: [
    .target(name: "DIKit"),
    .target(name: "DIGenKit", dependencies: ["DIKit", "SourceKittenFramework"]),
    .target(name: "dikitgen", dependencies: ["DIGenKit"]),
    .testTarget(name: "DIGenKitTests", dependencies: ["DIGenKit"])
  ],
  swiftLanguageVersions: [.v5]
)

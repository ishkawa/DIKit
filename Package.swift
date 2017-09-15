// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "DIKit",
  dependencies: [
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.18.1"),
    .package(url: "https://github.com/kylef/Stencil.git", from: "0.9.0"),
  ],
  targets: [
    .target(name: "DIKit"),
    .target(name: "dikitgen", dependencies: ["DIKit", "SourceKittenFramework", "Stencil"]),
  ]
)

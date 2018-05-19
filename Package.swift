// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "DIKit",
  products: [
    .executable(name: "dikitgen", targets: ["dikitgen"]),
    .library(name: "DIKit", targets: ["DIKit"]),
    .library(name: "DIGenKit", targets: ["DIGenKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.19.1"),
    .package(url: "https://github.com/kylef/Stencil.git", from: "0.9.0"),
  ],
  targets: [
    .target(name: "DIKit"),
    .target(name: "DIGenKit", dependencies: ["DIKit", "SourceKittenFramework", "Stencil"]),
    .target(name: "dikitgen", dependencies: ["DIGenKit"]),
    .testTarget(name: "DIGenKitTests", dependencies: ["DIGenKit"])
  ]
)

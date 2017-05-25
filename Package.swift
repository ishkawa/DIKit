import PackageDescription

let package = Package(
  name: "DIKit",
  targets: [
    Target(name: "dikitgen"),
  ],
  dependencies: [
    .Package(url: "https://github.com/jpsim/SourceKitten.git", Version(0, 17, 6)),
    .Package(url: "https://github.com/Carthage/Commandant.git", versions: Version(0, 12, 0)..<Version(0, 12, .max)),
  ]
)


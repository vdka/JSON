import PackageDescription

let package = Package(
  name: "JSON",
  targets: [
    Target(name: "JSON"),
    Target(name: "JSONTests",
      dependencies: [.Target(name: "JSON")]),
  ],
  dependencies: []
)


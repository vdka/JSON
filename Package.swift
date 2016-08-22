import PackageDescription

let package = Package(
  name: "JSON",
  targets: [
    Target(name: "JSONCore"), // `enum JSON` & `JSON.Parser` & `JSON.Serializer`
    Target(name: "JSON", dependencies: [.Target(name: "JSONCore")]),
  ]
)


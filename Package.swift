
import PackageDescription

let package = Package(
  name: "JSON",
  dependencies: [
    .Package(url: "https://github.com/vdka/JSONCore.git", majorVersion: 0)
  ]
)


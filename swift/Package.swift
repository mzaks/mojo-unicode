// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-unicode-bench",
    targets: [
        .executableTarget(
            name: "swift-unicode-bench",
            path: "Sources/swift"
        ),
    ]
)

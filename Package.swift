// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CodableCSV",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v7)
    ],
    products: [
        .library(name: "CodableCSV", targets: ["CodableCSV"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CodableCSV", dependencies: [], path: "sources"),
        .testTarget(name: "CodableCSVTests", dependencies: ["CodableCSV"], path: "tests"),
        .testTarget(name: "CodableCSVBenchmarks", dependencies: ["CodableCSV"], path: "benchmarks")
    ]
)

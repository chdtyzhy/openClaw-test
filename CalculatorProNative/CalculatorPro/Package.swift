// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CalculatorProApp",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "CalculatorProUI",
            targets: ["CalculatorProUI"]),
        .executable(
            name: "CalculatorPro",
            targets: ["CalculatorPro"]),
    ],
    dependencies: [
        // 本地依赖
        .package(path: "../"),
        
        // 外部依赖
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    ],
    targets: [
        // UI框架
        .target(
            name: "CalculatorProUI",
            dependencies: [
                .product(name: "CalculatorPro", package: "CalculatorProNative"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
            ],
            path: "Sources/UI",
            resources: [
                .process("Resources"),
                .copy("Assets.xcassets"),
            ]
        ),
        
        // 主应用
        .executableTarget(
            name: "CalculatorPro",
            dependencies: ["CalculatorProUI"],
            path: "Sources/App",
            resources: [
                .process("Resources"),
                .copy("Assets.xcassets"),
                .copy("Info.plist"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
            ]
        ),
        
        // 单元测试
        .testTarget(
            name: "CalculatorProUITests",
            dependencies: ["CalculatorProUI"],
            path: "Tests/UITests"
        ),
        
        // UI测试
        .testTarget(
            name: "CalculatorProAppUITests",
            dependencies: ["CalculatorPro"],
            path: "Tests/AppUITests"
        ),
    ]
)
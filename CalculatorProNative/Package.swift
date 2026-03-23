// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CalculatorPro",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // 核心计算引擎库
        .library(
            name: "CalculatorCore",
            targets: ["CalculatorCore"]),
        .library(
            name: "ScientificEngine",
            targets: ["ScientificEngine"]),
        // 完整计算器框架
        .library(
            name: "CalculatorPro",
            targets: ["CalculatorPro"]),
    ],
    dependencies: [
        // 测试框架
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.5.0"),
    ],
    targets: [
        // 基础计算核心
        .target(
            name: "CalculatorCore",
            dependencies: [],
            path: "Sources/CalculatorCore"),
        
        // 科学计算引擎
        .target(
            name: "ScientificEngine",
            dependencies: ["CalculatorCore"],
            path: "Sources/ScientificEngine"),
        
        // 主框架
        .target(
            name: "CalculatorPro",
            dependencies: ["CalculatorCore", "ScientificEngine"],
            path: "Sources/CalculatorPro"),
        
        // 单元测试
        .testTarget(
            name: "CalculatorCoreTests",
            dependencies: [
                "CalculatorCore",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/CalculatorCoreTests"),
        
        .testTarget(
            name: "ScientificEngineTests",
            dependencies: [
                "ScientificEngine",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/ScientificEngineTests"),
        
        .testTarget(
            name: "CalculatorProTests",
            dependencies: [
                "CalculatorPro",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/CalculatorProTests"),
    ]
)
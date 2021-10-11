// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LLFSMTestingFramework",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LLFSMTestingFramework",
            targets: ["LLFSMTestingFramework"]),
    ],
    dependencies: [
        .package(name: "SwiftParsing", url: "https://github.com/Morgan2010/SwiftParsing.git", .branch("main")),
        .package(url: "file:///Users/morgan/src/LLFSMTestingFramework/Tests/machines/SwiftPingPong.machine/Darwin-x86_64/SwiftPingPongMachine", .branch("master"))
        
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LLFSMTestingFramework",
            dependencies: ["SwiftParsing" ]),
        .target(
            name: "SwiftTests",
            dependencies: ["SwiftParsing", .target(name: "LLFSMTestingFramework")]),
        .testTarget(
            name: "LLFSMTestingFrameworkTests",
            dependencies: ["LLFSMTestingFramework", "SwiftPingPongMachine"],
            swiftSettings: [.unsafeFlags(["-I/usr/local/include/swiftfsm"])],
            linkerSettings: [.unsafeFlags(["-L/usr/local/lib", "-lFSM", "-R/usr/local/lib"])]
        ),
        .testTarget(
            name: "SwiftTestsTests",
            dependencies: ["LLFSMTestingFramework", "SwiftTests"])
    ]
)

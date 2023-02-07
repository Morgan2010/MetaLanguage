// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaLanguage",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MetaLanguage",
            targets: ["MetaLanguage"]
        ),
        .library(
            name: "SwiftTests",
            targets: ["SwiftTests"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:Morgan2010/SwiftParsing.git", from: "0.1.0"),
        .package(url: "https://github.com/mipalgu/swift_helpers.git", from: "1.0.2")
        
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MetaLanguage",
            dependencies: ["SwiftParsing", .product(name: "IO", package: "swift_helpers")]),
        .target(
            name: "SwiftTests",
            dependencies: ["SwiftParsing", .target(name: "MetaLanguage"), .product(name: "swift_helpers", package: "swift_helpers"), .product(name: "IO", package: "swift_helpers")]),
        .testTarget(
            name: "MetaLanguageTests",
            dependencies: ["MetaLanguage"]
        ),
        .testTarget(
            name: "SwiftTestsTests",
            dependencies: ["MetaLanguage", "SwiftTests"])
    ]
)

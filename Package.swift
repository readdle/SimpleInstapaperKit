// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleInstapaperKit",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "SimpleInstapaperKit",
            targets: ["SimpleInstapaperKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/UICKeyChainStore.git", .upToNextMajor(from: "2.1.2")),
    ],
    targets: [
        .target(
            name: "SimpleInstapaperKit",
            dependencies: [
                .product(name: "UICKeyChainStore", package: "UICKeyChainStore"),
            ],
            path: "SimpleInstapaperKit",
            sources: [
                "IKInstapaperActivity.m",
                "IKLoginViewController.m",
                "IKRequest.m",
            ],
            resources: [
                .copy("ClearButtonLogin.png"),
                .copy("ClearButtonLogin@2x.png"),
                .copy("ClearButtonLogin@3x.png"),
                .copy("InstapaperActivity.png"),
                .copy("InstapaperActivity@2x.png"),
                .copy("InstapaperActivity@2x~ipad.png"),
                .copy("InstapaperActivity~ipad.png"),
                .copy("InstapaperLogin.png"),
                .copy("InstapaperLogin@2x.png"),
                .process("IKLoginViewController.xib"),
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
            ]
        ),
        
    ]
)

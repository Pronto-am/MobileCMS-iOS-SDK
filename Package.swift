// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ProntoSDK",
    products: [
        .library(name: "ProntoSDK", targets: ["ProntoSDK", "ProntoSDKTests"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Igor-Palaguta/Cache", .revision("560f00a9a9549db161ca70d96eed74fc580b03e3")), // See https://github.com/hyperoslo/Cache/issues/238
        .package(url: "https://github.com/google/promises", .upToNextMajor(from: "1.2.8")),
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "5.0.1")),

        // Testing
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "8.0.1")),
        .package(url: "https://github.com/e-sites/Mockingjay", .branch("master")),

        // E-sites
        .package(url: "https://github.com/e-sites/Cobalt", .upToNextMajor(from: "5.8.2")),
        .package(url: "https://github.com/e-sites/Erbium", .branch("master")),
        .package(url: "https://github.com/e-sites/Einsteinium", .branch("master"))
    ],
    targets: [
        .target(
            name: "ProntoSDK",
            dependencies: [
                "SwiftyJSON",
                "KeychainAccess",
                "CryptoSwift",
                "Cache",
                "Promises",
                "RxSwift",
                "Erbium",
                "Einsteinium",
                "Cobalt"
            ],
            path: "ProntoSDK"
        ),
        .testTarget(
            name: "ProntoSDKTests",
            dependencies: [
                "Nimble",
                "Mockingjay",
                "Cobalt"
            ],
            path: "ProntoSDKTests"
        )
    ]
)

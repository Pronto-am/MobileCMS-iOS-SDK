// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ProntoSDK",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "ProntoSDK", targets: ["ProntoSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/google/promises.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/e-sites/Cobalt.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/e-sites/Erbium.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/e-sites/Einsteinium.git", .upToNextMajor(from: "1.0.0"))
        // ,.package(url: "https://github.com/Quick/Nimble.git", .branch("master")),
        // .package(url: "https://github.com/e-sites/Mockingjay.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "ProntoSDK",
            dependencies: [
                "SwiftyJSON",
                "KeychainAccess",
                "CryptoSwift",
                "Promises",
                "RxSwift",
                "Erbium",
                "Einsteinium",
                "Cobalt"
            ],
            path: "ProntoSDK"
        )
        // ,.testTarget(
        //     name: "ProntoSDKTests",
        //     dependencies: [
        //         "ProntoSDK",
        //         "Nimble",
        //         "Mockingjay",
        //         "Cobalt"
        //     ],
        //     path: "ProntoSDKTests"
        // )
    ],
    swiftLanguageVersions: [ .v5 ]
)

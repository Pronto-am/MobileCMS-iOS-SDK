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
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/e-sites/Cobalt.git", .upToNextMajor(from: "7.0.2")),
        .package(url: "https://github.com/e-sites/Erbium.git", .upToNextMajor(from: "4.4.1")),
        .package(url: "https://github.com/e-sites/Einsteinium.git", .upToNextMajor(from: "1.2.2"))
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
                "RxCocoa",
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

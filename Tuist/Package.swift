// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:],
        baseSettings: .settings(
            configurations: [
                .debug(name: "Debug-Prod"),
                .release(name: "Release-Prod"),
                .debug(name: "Debug-InHouse"),
                .release(name: "Release-InHouse"),
            ]
        )
    )
#endif

let package = Package(
    name: "iOS-main",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", exact: "5.7.1"),
        .package(url: "https://github.com/Moya/Moya", exact: "15.0.3"),
        .package(url: "https://github.com/scalessec/Toast-Swift", exact: "5.1.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "12.14.0"),
        .package(url: "https://github.com/scenee/FloatingPanel", exact: "2.8.6"),
        .package(url: "https://github.com/jonkykong/SideMenu", exact: "6.5.0"),
        .package(url: "https://github.com/devxoul/Then", exact: "3.0.0"),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap", branch: "main"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", branch: "master")
    ]
)

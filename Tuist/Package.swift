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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "11.7.0"),
        .package(url: "https://github.com/scenee/FloatingPanel", exact: "2.8.6"),
        .package(url: "https://github.com/jonkykong/SideMenu", exact: "6.5.0"),
        .package(url: "https://github.com/devxoul/Then", exact: "3.0.0"),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap", branch: "main"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", branch: "master"),
        // Tuist 4.55.6이 swift-tools-version 6.2의 traits 매니페스트를 파싱하지 못해,
        // Firebase의 전이 의존성인 swift-protobuf를 traits 도입 이전 버전으로 고정한다.
        .package(url: "https://github.com/apple/swift-protobuf.git", exact: "1.30.0"),
    ]
)

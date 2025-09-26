import ProjectDescription

let project = Project(
    name: "WebtoonApp",
    packages: [
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: "1.22.3")
        )
    ],
    targets: [
        // MARK: - App Target
        .target(
            name: "WebtoonApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.webtoon.app",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ]
                ]
            ),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            dependencies: [
                .target(name: "WebtoonList"),
                .target(name: "WebtoonDetail"),
                .target(name: "WebtoonViewer")
            ]
        ),
        
        // MARK: - Core Module
        .target(
            name: "Core",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.webtoon.core",
            deploymentTargets: .iOS("16.0"),
            sources: ["Modules/Core/Sources/**"],
            dependencies: [
                .package(product: "ComposableArchitecture")
            ]
        ),
        
        // MARK: - UI Module
        .target(
            name: "UI",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.webtoon.ui",
            deploymentTargets: .iOS("16.0"),
            sources: ["Modules/UI/Sources/**"],
            resources: ["Modules/UI/Resources/**"],
            dependencies: [

            ]
        ),
        
        // MARK: - WebtoonList Module (웹툰 목록)
        .target(
            name: "WebtoonList",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.webtoon.webtoonlist",
            deploymentTargets: .iOS("16.0"),
            sources: ["Modules/WebtoonList/Sources/**"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "UI")
            ]
        ),
        
        // MARK: - WebtoonDetail Module (웹툰 상세)
        .target(
            name: "WebtoonDetail",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.webtoon.webtoondetail",
            deploymentTargets: .iOS("16.0"),
            sources: ["Modules/WebtoonDetail/Sources/**"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "UI")
            ]
        ),
        
        // MARK: - WebtoonViewer Module (웹툰 뷰어)
        .target(
            name: "WebtoonViewer",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.webtoon.webtoonviewer",
            deploymentTargets: .iOS("16.0"),
            sources: ["Modules/WebtoonViewer/Sources/**"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "UI")
            ]
        )
    ]
)

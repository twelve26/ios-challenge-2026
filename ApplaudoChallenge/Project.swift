import ProjectDescription

let project = Project(
    name: "ApplaudoChallenge",
    targets: [
        .target(
            name: "ApplaudoChallenge",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.ApplaudoChallenge",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CAT_API_KEY": "$(CAT_API_KEY)",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "ApplaudoChallenge/Sources",
                "ApplaudoChallenge/Resources",
            ],
            dependencies: [
                .target(name: "NetworkLayer"),
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Config/Base.xcconfig"),
                    .release(name: "Release", xcconfig: "Config/Base.xcconfig"),
                ]
            )
        ),
        .target(
            name: "ApplaudoChallengeTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.ApplaudoChallengeTests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: [
                "ApplaudoChallenge/Tests"
            ],
            dependencies: [.target(name: "ApplaudoChallenge")]
        ),
        .target(
            name: "NetworkLayer",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "dev.tuist.NetworkLayer",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: [
                "modules/NetworkLayer/Sources",
            ],
            dependencies: [
                .external(name: "Moya"),
            ]
        ),
        .target(
            name: "NetworkLayerTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.NetworkLayerTests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: [
                "modules/NetworkLayer/NetworkLayerTest",
            ],
            dependencies: [.target(name: "NetworkLayer")]
        ),
    ]
)

// swift-tools-version: 6.0
import PackageDescription

// Núcleo puro de la app (zonas Friel y motor de reglas) expuesto como librería
// para poder probarlo sin simulador. Reutiliza los mismos ficheros que el target
// de Xcode, así que no hay código duplicado.
let package = Package(
    name: "RunnerTrackCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "RunnerTrackCore", targets: ["RunnerTrackCore"]),
    ],
    targets: [
        .target(
            name: "RunnerTrackCore",
            path: "RunnerTrack-iOS",
            sources: [
                "Models/Enums.swift",
                "Services/FrielZoneCalculator.swift",
                "Services/RulesEngine.swift",
            ]
        ),
        .testTarget(
            name: "RunnerTrackCoreTests",
            dependencies: ["RunnerTrackCore"]
        ),
    ]
)

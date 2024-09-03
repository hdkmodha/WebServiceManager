// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static var alamofire: Target.Dependency {
        return .product(name: "Alamofire", package: "Alamofire")
    }
    
    static var alamofireImage: Target.Dependency {
        return .product(name: "AlamofireImage", package: "AlamofireImage")
    }
}

let package = Package(
    name: "WebServiceManager",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WebServiceManager",
            targets: ["WebServiceManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", .upToNextMajor(from: "4.3.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WebServiceManager",
            dependencies: [
                .alamofire,
                .alamofireImage
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        
    ]
)

import Leaf
import Vapor
enum randomError : Error {
    case idk
}
// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)

    app.dataController = .init(app)

//    Task {
//        try await app.dataController?.initialize()
//    }

    // register routes
    try routes(app)
}

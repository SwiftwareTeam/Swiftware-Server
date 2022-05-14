import Leaf
import Vapor

public func configure(_ app: Application) throws {

    app.views.use(.leaf)

    app.dataController = .init(app)

    try routes(app)
}

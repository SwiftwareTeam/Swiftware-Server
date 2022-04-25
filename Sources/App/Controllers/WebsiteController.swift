import Vapor
import Leaf

// 1
struct WebsiteController: RouteCollection {
  // 2
  func boot(routes: RoutesBuilder) throws {
    // 3
    routes.get(use: indexHandler)
  }

  // 4
  func indexHandler(_ req: Request) -> EventLoopFuture<View> {
    // 5
    return req.view.render("index")
  }
}


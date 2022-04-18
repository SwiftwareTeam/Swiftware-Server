import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
  
    app.get("getResponses", ":uid") { req -> [String: [String: String]] in
        guard let uid = req.parameters.get("uid") else {
            return [String: [String: String]]()
        }

        if let data = app.data?.surveys[uid] {
            return data
        }
        return [String: [String: String]]()
                                     
   
}

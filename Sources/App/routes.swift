import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    app.get("users"){ req -> EventLoopFuture<View> in
        
        let u1 = User(id: 1, Q1: "Sometimes", Q2: "Never", Q3: "Fairly often")
        let u2 = User(id: 2, Q1: "Fairly Often", Q2: "Almost Never", Q3: "Sometime")
        let u3 = User(id: 3, Q1: "Almost Never", Q2: "Never", Q3: "Sometime")
        let u4 = User(id: 4, Q1: "Never", Q2: "Almost Never", Q3: "Fairly often")
        
       
        
        return req.view.render("home", ["users": [u1, u2, u3, u4]])
                      
    }
}

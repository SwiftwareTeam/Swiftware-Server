import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
  
    app.get("getResponses", ":uid") { req -> [SurveyResponse] in
        var responses = [SurveyResponse]()

        guard let uid = req.parameters.get("uid") else {
            return responses
        }

        if let data = await app.dataController?.surveyResponses {
            responses = data.filter { $0.uid == uid }
        }

        return responses
    }

    app.get("getSurveys") { req -> [Survey] in
        if let surveys = await app.dataController?.surveys {
            return surveys
        }

        return [Survey]()
    }

    app.post("createResponse") { req -> Response in

        if app.dataController == nil {
            req.logger.error("App.data is nil")
            throw Abort(.internalServerError, reason: "Unable to Load Server Data")
        }

        guard let surveyResponse = try? req.content.decode(SurveyResponse.self) else {
            throw Abort(.badRequest, reason: "Not a valid Survey Response Object")
        }
        req.logger.info("Responses: \(surveyResponse.responses)")

//      FIX ME
//        if (app.data?.surveyResponses.append(surveyResponse)) == nil {
//            throw Abort(.internalServerError, reason: "Unable to add survey response to app data")
//        }

        req.logger.info("Successfully Inserted SurveyResponse")

        return Response(status: .created)
        
    }

}

import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    app.get("getResponses", ":uid") { req -> [SurveyResponse] in
        guard let uid = req.parameters.get("uid") else {
            throw Abort(.notFound, reason: "Unable to find uid")
        }

        if let responses = try? await app.dataController?.getSurveyResponses(uid: uid) {
            return responses
        } else {
            throw Abort(.internalServerError)
        }
    }

    app.get("getSurveys") { req -> [Survey] in
        if let surveys = try? await app.dataController?.getSurveys() {
            return surveys
        } else {
            throw Abort(.internalServerError)
        }
    }

    app.post("createResponse") { req -> Response in

        if app.dataController == nil {
            req.logger.error("Data Controller not Initialized")
            throw Abort(.internalServerError, reason: "Unable to Load Data Controller")
        }

        guard let surveyResponse = try? req.content.decode(SurveyResponse.self) else {
            throw Abort(.badRequest, reason: "Not a valid Survey Response Object")
        }

        if (try? await app.dataController?.createResponse(response: surveyResponse)) == nil {
            throw Abort(.internalServerError, reason: "Unable to add survey response to app data")
        } else {
            req.logger.info("Successfully Inserted SurveyResponse")
            return Response(status: .created)
        }

    }

    app.patch("updateResponse") { req -> Response in
        if app.dataController == nil {
            req.logger.error("Data Controller not Initialized")
            throw Abort(.internalServerError, reason: "Unable to Load Server Data")
        }

        guard let surveyResponse = try? req.content.decode(SurveyResponse.self) else {
            throw Abort(.badRequest, reason: "Not a valid Survey Response Object")
        }

        if (try? await app.dataController?.updateResponse(response: surveyResponse)) == nil {
            throw Abort(.internalServerError, reason: "Unable to Update Survey Response in App Data")
        } else {
            req.logger.info("Successfully updated Survey Response")
            return Response(status: .ok)
        }
    }
    
    app.delete("deleteResponse") { req -> Response in
        if app.dataController == nil {
            req.logger.error("Data Controller not Initialized")
            throw Abort(.internalServerError, reason: "Unable to Load Data Controller")
        }

        guard let surveyResponse = try? req.content.decode(SurveyResponse.self) else {
            throw Abort(.badRequest, reason: "Nota a valid UUID")
        }
        app.logger.info("Attempting to Delete Response")
        if (try? await app.dataController?.deleteResponse(id: surveyResponse.id)) == true {
            return Response(status: .ok)
        } else {
            throw Abort(.notFound, reason: "UUID Not Found in Response List")
        }
    }

    app.get("backup") { req -> Response in
        if (try? await app.dataController?.backup()) == true {
            return Response(status: .ok)
        } else {
            throw Abort(.internalServerError, reason: "Unable to perform backup")
        }
    }

    app.get("loadBackup") { req -> Response in
        if (try? await app.dataController?.loadBackup()) == true {
            return Response(status: .ok)
        } else {
            throw Abort(.internalServerError, reason: "Unable to load backup")
        }
    }

}

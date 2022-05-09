import Vapor
import Foundation

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

        if let responses = try? app.dataController?.getSurveyResponses(uid: uid) {
            return responses
        } else {
            throw Abort(.internalServerError)
        }
    }

    app.get("getSurveys") { req -> [Survey] in
        if let surveys = try? app.dataController?.getSurveys() {
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

        if (try? app.dataController?.createResponse(response: surveyResponse)) == nil {
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

        if (try? app.dataController?.updateResponse(response: surveyResponse)) == nil {
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
        if (try? app.dataController?.deleteResponse(id: surveyResponse.id)) == true {
            return Response(status: .ok)
        } else {
            throw Abort(.notFound, reason: "UUID Not Found in Response List")
        }
    }

    app.get("backup") { req -> Response in
        if (try? app.dataController?.backup()) == true {
            return Response(status: .ok)
        } else {
            throw Abort(.internalServerError, reason: "Unable to perform backup")
        }
    }

    app.get("loadBackup") { req -> Response in
        if (try? app.dataController?.loadBackup()) == true {
            return Response(status: .ok)
        } else {
            throw Abort(.internalServerError, reason: "Unable to load backup")
        }
    }

    app.get("avgResponseRate",":surveyID") { req -> [ChartData] in
        guard let surveyIDString = req.parameters.get("surveyID") else {
            throw Abort(.badRequest)
        }
        guard let surveyID = Int(surveyIDString) else {
            throw Abort(.badRequest)
        }

        if let charts = app.dataController?.avgResponseRate(surveyID: surveyID) {
            return charts
        } else {
            throw Abort(.internalServerError)
        }
    }

    app.get("getUsers") { req -> [String] in
        if let users = try app.dataController?.getUsers() {
            return users
        } else {
            throw Abort(.internalServerError)
        }
    }

    app.get("getPersonalityScore", ":userID") { req -> PersonalityScore in
        guard let uid = req.parameters.get("userID") else {
            throw Abort(.notFound, reason: "Parameter userID not found")
        }

        if let personalityScore = try? app.dataController?.personalityScore(forUser: uid) {
            return personalityScore
        } else {
            throw Abort(.internalServerError)
        }
    }
}

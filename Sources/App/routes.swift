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

        if let data = app.data?.surveyResponses {
            responses = data.filter { $0.uid == uid }
        }

        return responses
    }

    app.get("getSurveys") { req -> [Survey] in
        if let surveys = app.data?.surveys {
            return surveys
        }

        return [Survey]()
    }

    app.post("createResponse") { req -> String in

        if let surveyResponse = try? req.content.decode(SurveyResponse.self) {
            return "Successfully Received and Decoded Survey Response"
        } else {
            return "Unable to Decode Survey Response Object"
        }
        
    }

}

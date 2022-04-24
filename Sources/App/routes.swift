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

    app.get("test") { req -> SurveyResponse in

        let questions = ["question 1", "question 2", "question 3"]
        let answers = ["Answer 1", "Answer 2", "Answer 3"]
        return SurveyResponse(uid: "u000", surveyID: 1, responseType: "pre", responses: [1: 1, 2: 3])
    }

    app.get("test2") { req -> Survey in
        let question1 = Question(id: 1, shortWording: "Talkative",
                                 fullWording: "I see myself as someone who is talkative")

        let question2 = Question(id: 2, shortWording: "A Fault Finder",
                                 fullWording: "I see myself as someone who tends to find fault with others")

        let questions = [question1.id: question1, question2.id: question2]

        let answer1 = Answer(id: 1, label: "Disagree Strongly", value: 1)
        let answer2 = Answer(id: 2, label: "Disagree a Little", value: 2)
        let answer3 = Answer(id: 3, label: "Neither Agree nor Disagree", value: 3)
        let answer4 = Answer(id: 4, label: "Agree a Little", value: 4)
        let answer5 = Answer(id: 5, label: "Agree Strongly", value: 5)

        let answers = [answer1.id: answer1, answer2.id: answer2, answer3.id: answer3,
                       answer4.id: answer4, answer5.id: answer5]

        return Survey(id: 1, name: "Big Five", group: "I see myself as", questions: questions, answers: answers)
    }

    app.get("surveys") { req -> [Survey] in
        if let surveys = app.data?.surveys {
            return surveys
        }
        return [Survey]()

    }


                                    
   
}

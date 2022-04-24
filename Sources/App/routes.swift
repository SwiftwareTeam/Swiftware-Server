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

    app.get("test") { req -> SurveyResponse in

        let questions = ["question 1", "question 2", "question 3"]
        let answers = ["Answer 1", "Answer 2", "Answer 3"]
        return SurveyResponse(uid: "u000", responseType: "pre", questions: questions, answers: answers)
    }

    app.get("test2") { req -> Survey in
        let question1 = Question(id: "Q1-1", shortWording: "Talkative",
                                 fullWording: "I see myself as someone who is talkative")

        let question2 = Question(id: "Q1-2", shortWording: "A Fault Finder",
                                 fullWording: "I see myself as someone who tends to find fault with others")

        let questions = [question1.id: question1, question2.id: question2]

        let answer1 = Answer(id: "Q1-1-1", label: "Disagree Strongly", value: 1)
        let answer2 = Answer(id: "Q1-1-2", label: "Disagree a Little", value: 2)
        let answer3 = Answer(id: "Q1-1-3", label: "Neither Agree nor Disagree", value: 3)
        let answer4 = Answer(id: "Q1-1-4", label: "Agree a Little", value: 4)
        let answer5 = Answer(id: "Q1-1-5", label: "Agree Strongly", value: 5)

        let answers = [answer1.id: answer1, answer2.id: answer2, answer3.id: answer3,
                       answer4.id: answer4, answer5.id: answer5]

        return Survey(name: "Big Five", group: "I see myself as", questions: questions, answers: answers)
    }


                                    
   
}

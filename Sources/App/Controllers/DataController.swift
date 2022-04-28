//
//  ServerData.swift
//  
//
//  Created by Shawn Long on 4/17/22.
//

import Vapor
import Foundation

actor DataController {

    var surveys = [Survey]()
    var surveyResponses = [SurveyResponse]()
    var surveyEncoder = JSONEncoder()
    var surveyDecoder = JSONDecoder()
    var JSONdata = Data()
    
    //let JSONdata = try surveyEncoder.encode(surveys)
    init() {

        // Survey 1
        surveys.append(loadSurvey(id: 1, name: "Big Five", group: "I see myself as"))
        surveyResponses = loadResponses(surveyid: 1)
        //saveUpdatedData()
        //decodeUpdatedData()
    }
    
    func saveUpdatedData() {
        surveyEncoder.outputFormatting = .prettyPrinted
        do {
            JSONdata = try surveyEncoder.encode(surveys)
            //print(String(data: JSONdata, encoding: .utf8)!)
        } catch let error {
            print(error.localizedDescription)
        }
        let jsonDir = "file://" + FileManager.default.currentDirectoryPath + "/Resources/UpdatedResponse.json"
        let url = URL(string: jsonDir)!
        
        do {
            try JSONdata.write(to: url)
            print("success")
        } catch {
            print(error)
        }
    }

    func decodeUpdatedData() {
        let jsonDir = "file://" + FileManager.default.currentDirectoryPath + "/Resources/UpdatedResponse.json"
        
        let url = URL(string: jsonDir)!
        
        var subdata = Data();
        do {
            subdata = try Data(contentsOf: url)
        } catch let error {
            print(error)
        }
        do {
            let array = try surveyDecoder.decode([Survey].self, from: subdata)
            surveys = array
            //print(surveys)
        } catch let error {
            print(error.localizedDescription)
        }
    }


    func loadQuestions(baseDir: String) -> [Int: Question] {

        let url = URL(fileURLWithPath: baseDir + "Questions.csv")

        var questions = [Int: Question]()

        do {
            let data = try Data(contentsOf: url) // Create saved data buffer

            // Convert Data Buffer into String
            if let dataString = String(data: data, encoding: .utf8) {

                // Create Array of Strings consisting of each line
                let lines: [String] = dataString.components(separatedBy: "\n")


                // 2D Array in which each row is an array of columns for the given row in the sheet
                // Outer Array represents a line or row from the csv file
                var dataArray = [[String]]()


                for line in lines {
                    // Convert the String for the given line to an array of tokens separated by a comma
                    // Then, use a map to transform each string in the array. The map uses a filter to
                    // remove whitespace from the string. Finally, append results to the data array

                    let lineArray = line.components(separatedBy: ",").map { str in
                        return str.filter {!$0.isWhitespace }
                    }

                    dataArray.append(lineArray)
                }

                dataArray.remove(at: 0) // Remove header

                var id: Int
                for row in dataArray {
                    // Convert id into integers
                    id = Int(row[0])!
                    questions[id] = Question(id: id, shortWording: row[1], fullWording: row[2])
                }

            } else {
                print("Error: Unable to convert Data Buffer for questions into String")
            }
        } catch {
            print("Error: unable to read question data at: \(baseDir)" + "Questions.csv")
        }

        return questions
        
    }

    func loadAnswers(baseDir: String) -> [Int: Answer] {

        let url = URL(fileURLWithPath: baseDir + "Answers.csv")

        var answers = [Int: Answer]()

        do {
          let data = try Data(contentsOf: url) // Create saved data buffer

          // Convert Data Buffer into String
          if let dataString = String(data: data, encoding: .utf8) {

              // Create Array of Strings consisting of each line
              let lines: [String] = dataString.components(separatedBy: "\n")


              // 2D Array in which each row is an array of columns for the given row in the sheet
              // Outer Array represents a line or row from the csv file
              var dataArray = [[String]]()


              for line in lines {
                  // Convert the String for the given line to an array of tokens separated by a comma
                  // Then, use a map to transform each string in the array. The map uses a filter to
                  // remove whitespace from the string. Finally, append results to the data array

                  let lineArray = line.components(separatedBy: ",").map { str in
                      return str.filter {!$0.isWhitespace }
                  }

                  dataArray.append(lineArray)
              }

              dataArray.remove(at: 0) // Remove header

              var id: Int
              var value: Int

              for row in dataArray {

                  // Convert id and value into Integers
                  id = Int(row[0])!
                  value = Int(row[2])!

                  answers[id] = Answer(id: id, label: row[1], value: value)

              }

          } else {
              print("Error: Unable to convert Data Buffer for answers into String")
          }
        } catch {
          print("Error: unable to read answer data at: \(baseDir)" + "Answers.csv")
        }

        return answers

    }

    func loadSurvey(id: Int, name: String, group: String) -> Survey {
        let currentDir = FileManager.default.currentDirectoryPath
        let baseDir = currentDir + "/Resources/Survey" + String(id)

        let questions = loadQuestions(baseDir: baseDir)
        let answers = loadAnswers(baseDir: baseDir)

        return Survey(id: id, name: name, group: group,
                      questions: questions, answers: answers)

    }

    func loadResponses(surveyid: Int) -> [SurveyResponse] {

        let currentDir = FileManager.default.currentDirectoryPath
        let responsesDir = currentDir + "/Resources/Survey" + String(surveyid) + "Responses.csv"

        let url = URL(fileURLWithPath: responsesDir)

        var responses = [SurveyResponse]()

        do {
          let data = try Data(contentsOf: url) // Create saved data buffer

          // Convert Data Buffer into String
          if let dataString = String(data: data, encoding: .utf8) {

              // Create Array of Strings consisting of each line
              let lines: [String] = dataString.components(separatedBy: "\n")


              // 2D Array in which each row is an array of columns for the given row in the sheet
              // Outer Array represents a line or row from the csv file
              var dataArray = [[String]]()


              for line in lines {
                  // Convert the String for the given line to an array of tokens separated by a comma
                  // Then, use a map to transform each string in the array. The map uses a filter to
                  // remove whitespace from the string. Finally, append results to the data array

                  let lineArray = line.components(separatedBy: ",").map { str in
                      return str.filter {!$0.isWhitespace }
                  }

                  dataArray.append(lineArray)
              }

              var header: [String] = dataArray[0] // Save header as own variable

              header.removeFirst(2) // Remove the first two columns of header, since they never change

              let questionIDs: [Int] = header.map { Int($0)! } // Convert the columns in the header to Ints, which are the questionID

              dataArray.remove(at: 0) // Remove header



              for row in dataArray {
                  let uid = row[0]
                  let responseType = row[1]

                  // Create changeable row which can be modified, unlike the row in the loop
                  var changeableRow = row
                  changeableRow.removeFirst(2)

                  // Initialize Empty Dictionary of QuestionID: AnswerID
                  var currentResponses = [Int: Int]()

                  // Iterate over the row with the index as well
                  for (index, answerID) in changeableRow.enumerated() {
                      // Use index to lookup the questionID from the modified header array we saved
                      // the modified header and modified row have the same number of columns

                      let questionID = questionIDs[index]

                      // Add the response to the given question in the responses Dictionary

                      // If the int can be parsed, check if answer is 0. If so, return nil
                      var returnAnswer = Int(answerID)
                      if returnAnswer == 0 {
                          returnAnswer = nil
                      }

                      currentResponses[questionID] = returnAnswer
                  }

                  responses.append(SurveyResponse(uid: uid, surveyID: surveyid,
                                                  responseType: responseType, responses: currentResponses))

              }

          } else {
              print("Error: Unable to convert Data Buffer for Responses into String")
          }
        } catch {
          print("Error: unable to read response data at: \(responsesDir)")
        }

        return responses


    }
}

struct MyConfigurationKey: StorageKey {
    typealias Value = DataController
}

extension Application {
    var dataController: DataController? {
        get {
            self.storage[MyConfigurationKey.self]
        }
        set {
            self.storage[MyConfigurationKey.self] = newValue

        }
    }
}

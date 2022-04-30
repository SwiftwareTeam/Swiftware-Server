//
//  FileController.swift
//  
//
//  Created by Shawn Long on 4/27/22.
//

import Foundation
import Vapor

enum FileControllerError : Error {
    case ReadError(message: String)
    case ConversionError(message: String)
}

/**
 - **baseDir**: The base directory is a string which consists of
 the current working directory plus the portion of the filename which begins `"Survey\(id)"`. eg. `/currentdirectory/Survey1`
 */
class FileController {

    private var baseDir: String
    private let app: Application

    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    private var JSONdata = Data()

    init(_ app: Application) {
        self.app = app
        let currentDir = FileManager.default.currentDirectoryPath
        self.baseDir = currentDir + "/Resources/"
    }

    /**
     Loads Survey data from Data Files
     */

    func loadSurvey(id: Int, name: String, group: String) throws -> Survey {
        let questions = try loadQuestions(surveyID: id)
        let answers = try loadAnswers(surveyID: id)

        return Survey(id: id, name: name, group: group,
                      questions: questions, answers: answers)
    }

    /**
     Reads Question Data from CSV File and returns Dictionary with keys `Question.id`
     and values of `Question`.
     - Note: No logic needed to avoid Race Conditions necessary since this method is only called
        at the beginning of the application.
     - Parameter surveyID: the Survey ID the questions belong to
     - Throws: `FatalError` if data cannot be read from CSV Files
     - Returns: Dictionary of QuestionID: Question containing all questions in the CSV File
     */
    func loadQuestions(surveyID id: Int) throws -> [Int: Question] {

        let url = URL(fileURLWithPath: baseDir + "/Data/Survey\(id)Questions.csv")

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
                        return str.filter {!$0.isNewline }
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
                app.logger.critical("Unable to convert Data Buffer for questions into String")
                throw FileControllerError.ConversionError(message: "Unable to convert Data Buffer for questions into String")
            }
        } catch {
            app.logger.critical("Unable to read question data")
            throw FileControllerError.ReadError(message: "Unable to read question data")
        }

        return questions

    }

    /**
     Reads Answer Data from CSV File and returns Dictionary with keys `Answer.id`
     and values of `Answer`.
     - Note: No logic needed to avoid Race Conditions necessary since this method is only called
        at the beginning of the application.
     - Parameter surveyID: The survey id the answers belong to
     - Throws: `FatalError` if data cannot be read from CSV Files
     - Returns: Dictionary of AnswerID: Answer containing all answers in the CSV File
     */
    func loadAnswers(surveyID id: Int) throws -> [Int: Answer] {

        let url = URL(fileURLWithPath: baseDir + "/Data/Survey\(id)Answers.csv")
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
                      return str.filter {!$0.isNewline }
                  }

                  dataArray.append(lineArray)
              }

              dataArray.remove(at: 0) // Remove header

//              var id: Int
//              var value: Int

              for row in dataArray {

                  // Convert id and value into Integers
                  if let id = Int(row[0]) {
                      if let value = Int(row[2]) {
                          answers[id] = Answer(id: id, label: row[1], value: value)

                      }
                  }

              }

          } else {
              app.logger.critical("Unable to convert Data Buffer for answers into String")
              throw FileControllerError.ConversionError(message: "Unable to convert Data Buffer for answers into String")
          }
        } catch {
            app.logger.critical("unable to read answer data")
            throw FileControllerError.ReadError(message: "Unable to read answer data")
        }

        return answers

    }

    func loadResponses(surveyID id: Int) throws -> [SurveyResponse] {
        let url = URL(fileURLWithPath: baseDir + "/Data/Survey\(id)Responses.csv")

        var responses = [SurveyResponse]()

        do {
            guard let data = try? Data(contentsOf: url) else {
                app.logger.error("Unable to read data for survey \(id)")
                return []
            }

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
                      return str.filter {!$0.isNewline }
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

                  responses.append(SurveyResponse(uid: uid, surveyID: id,
                                                  responseType: responseType, responses: currentResponses))

              }

          } else {
              app.logger.error("Unable to convert Data Buffer for Responses into String")
              throw FileControllerError.ConversionError(message: "Unable to convert Data Buffer for Responses into String")
          }
        } catch {
            app.logger.error("Unable to read response data")
            throw FileControllerError.ReadError(message: "Unable to read response data")
        }

        return responses

    }

    func backup(snapshot: DataSnapshot) throws -> Bool {
        encoder.outputFormatting = .prettyPrinted

        do {
            JSONdata = try encoder.encode(snapshot)
            app.logger.info("snapshot encoded")
        } catch let error {
            app.logger.report(error: error)
        }
        let jsonDir = "file://" + baseDir + "/Backups/backup.json"
        let url = URL(string: jsonDir)!

        do {
            app.logger.info("attempting write")
            try JSONdata.write(to: url)
            app.logger.info("Successfully exported data snapshot")
            return true
        } catch {
            app.logger.report(error: error)
            return false
        }
    }

        func getBackup() -> DataSnapshot? {
            let jsonDir = "file://" + baseDir + "/Backups/backup.json"
    
            let url = URL(string: jsonDir)!

            var subdata = Data();
            do {
                subdata = try Data(contentsOf: url)
            } catch let error {
                app.logger.report(error: error)
            }
            do {
                let snapshot = try decoder.decode(DataSnapshot.self, from: subdata)
                return snapshot

            } catch let error {
                app.logger.report(error: error)
                return nil
            }
        }
    
}

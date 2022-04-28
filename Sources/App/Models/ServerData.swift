//
//  ServerData.swift
//  
//
//  Created by Shawn Long on 4/27/22.
//

import Foundation

/**
  An object which stores data collections used by the vapor server.
 */
actor ServerData {
    /// Array of Surveys
    private var surveys = [Survey]()

    /// Array of Survey Responses
    private var surveyResponses = [SurveyResponse]()

    /**
     Inserts a Survey into the `ServerData.surveys` array. If a survey with
     the existing id already exists, the existing survey is overwritten.

     - Parameter newSurvey: The new survey to be inserted
     - Complexity: O(*n*) where *n* is the size of the survey array
     */
    func storeSurvey(_ newSurvey: Survey) throws {
        for (index, existingSurvey) in surveys.enumerated() {
            if existingSurvey.id == newSurvey.id {
                surveys[index] = newSurvey
                return
            }
        }
        surveys.append(newSurvey)
    }

    /**
     Inserts a Survey into the `ServerData.surveyResponses` array. If a survey
     response with the existing id already exists, the existing survey is overwritten.

     - Parameter newResponse: The new survey response to be inserted
     - Complexity: O(*n*) where *n* is the size of the survey response array
     */
    func storeSurveyResponse(_ newResponse: SurveyResponse) throws {
        for (index, existingResponse) in surveyResponses.enumerated() {
            if existingResponse.id == newResponse.id {
                surveyResponses[index] = newResponse
                return
            }
        }
        surveyResponses.append(newResponse)
    }

        /**
         Searches the `ServerData.surveys` for the first survey for which
         the predicate is true.

         - Parameter predicate: A closure that takes an element of `ServerData.surveys` as its argument
         and returns a Boolean value indicating whether the element is a match.

         - Returns: The first element of `ServerData.surveys` that satisfies `predicate` or `nil` if
         there is no element that satisfies `predicate`.
         - Complexity: O(*n*) where *n* is the size of the survey array
         */
    func firstSurvey(where predicate: (Survey) throws -> Bool) rethrows -> Survey? {
        for survey in surveys {
            if try predicate(survey) { return survey }
        }
        return nil
    }

    /**
     Searches the `ServerData.surveyResponses` for the first survey response for which
     the predicate is true.

     - Parameter predicate: A closure that takes an element of `ServerData.surveyResponses` as its argument
     and returns a Boolean value indicating whether the element is a match.

     - Returns: The first element of `ServerData.surveyResponses` that satisfies `predicate` or `nil` if
     there is no element that satisfies `predicate`.
     - Complexity: O(*n*) where *n* is the size of the survey response array
     */
    func firstSurveyResponse(where predicate: (SurveyResponse) throws -> Bool) rethrows -> SurveyResponse? {
        for response in surveyResponses {
            if try predicate(response) { return response }
        }
        return nil
    }

    /**
     Returns an array containing, in order, the elements of `ServerData.surveys` that satisfy the given predicate.

     - Parameter isIncluded: A closure that takes an element of the survey array as its argument
     and returns a Boolean value indicating whether the element should be included in the returned array.
     - Returns: An array of the elements that `isIncluded` allowed.
     - Complexity: O(*n*) where *n* is the size of the survey array
     */
    func filterSurveys(_ isIncluded: (Survey) throws -> Bool) rethrows -> [Survey] {
        return try surveys.filter(isIncluded)
    }

    /**
     Returns an array containing, in order, the elements of `ServerData.surveyResponses` that satisfy the given predicate.

     - Parameter isIncluded: A closure that takes an element of the survey response array as its argument
     and returns a Boolean value indicating whether the element should be included in the returned array.
     - Returns: An array of the elements that `isIncluded` allowed.
     - Complexity: O(*n*) where *n* is the size of the survey response array
     */
    func filterSurveyResponses(_ isIncluded: (SurveyResponse) throws -> Bool) rethrows -> [SurveyResponse] {
        return try surveyResponses.filter(isIncluded)
    }

}

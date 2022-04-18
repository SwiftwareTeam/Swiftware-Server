//
//  ServerData.swift
//  
//
//  Created by Shawn Long on 4/17/22.
//

import Vapor

final class ServerData {
    var surveys = [String:[String:[String: String]]]()

    init() {
        let directoryURL = FileManager.default.currentDirectoryPath
//        print(directoryURL)

        let fileURL = URL(fileURLWithPath: directoryURL + "/Resources/SimpleSurveyData.csv")

//        print(fileURL)

        do {
            // Attempt to load the data from the file
            let savedData = try Data(contentsOf: fileURL)

            // Convert the data to a String
            if let savedString = String(data: savedData, encoding: .utf8) {
                let lines = savedString.components(separatedBy: "\n")
                var dataArray = [[String]]()
                for line in lines {
                    dataArray.append(line.components(separatedBy: ","))
                }

            var columns = dataArray[0]
                columns.remove(at: 0)
                columns.remove(at: 1)

            dataArray.remove(at: 0)

            var mutableRow: [String]
            for row in dataArray {
                mutableRow = row

                let uid = mutableRow[0]
                let type = mutableRow[1]

                mutableRow.remove(at: 0)
                mutableRow.remove(at: 1)

                if self.surveys[uid] == nil {
                    self.surveys[uid] = [String : [String: String]]()
                }
                let dict = Dictionary(uniqueKeysWithValues: zip(columns, mutableRow))
                self.surveys[uid]?[type] = dict
            }

            }
        } catch {
            print("Unable to load data from \(fileURL)")
        }
    }
}

struct MyConfigurationKey: StorageKey {
    typealias Value = ServerData
}

extension Application {
    var data: ServerData? {
        get {
            self.storage[MyConfigurationKey.self]
        }
        set {
            self.storage[MyConfigurationKey.self] = newValue

        }
    }
}

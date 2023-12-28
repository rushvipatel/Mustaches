//
//  DatabaseManager.swift
//  Mustaches
//
//  Created by Rushvi Patel on 12/27/23.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private let db: Connection

    private let recordings = Table("recordings")
    private let id = Expression<Int64>("id")
    private let tag = Expression<String>("tag")
    private let duration = Expression<Int>("duration")
    private let videoFilePath = Expression<String>("videoFilePath")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        db = try! Connection("\(path)/db.sqlite3")
        createTable()
    }

    private func createTable() {
        try! db.run(recordings.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(tag)
            t.column(duration)
            t.column(videoFilePath)
        })
    }

    func saveRecording(videoPath: String, duration: Int, tagText: String) {
        let insert = recordings.insert(self.tag <- tagText, self.duration <- duration, self.videoFilePath <- videoPath)
        do {
            try db.run(insert)
            print("DatabaseManager: Saving recording with path: \(videoPath), duration: \(duration), tag: \(tagText)")

        } catch {
            print("Insert failed: \(error)")
        }
    }

    func getRecordings() -> [Recording] {
        var recordingList = [Recording]()
        do {
            for recording in try db.prepare(recordings) {
                let newRecording = Recording(
                    id: recording[id],
                    tag: recording[tag],
                    duration: recording[duration],
                    videoFilePath: recording[videoFilePath]
                )
                recordingList.append(newRecording)
            }
        } catch {
            print("Select failed: \(error)")
        }
        return recordingList
    }
}

struct Recording {
    let id: Int64
    let tag: String
    let duration: Int
    let videoFilePath: String
}

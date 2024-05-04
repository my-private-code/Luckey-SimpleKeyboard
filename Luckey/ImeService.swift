//
//  ImeService.swift
//  Luckey
//
//  Created by Yuwei Dong on 13/4/24.
//

import Foundation

import GRDB

struct Pinyin: FetchableRecord, PersistableRecord, Codable {
    var py: String
    var hz: String
    var abbr: String
    var freq: Int
}

struct Word: FetchableRecord, PersistableRecord, Codable {
    var word: String
    var freq: Int
}

class ImeService {
    var dbQueue: DatabaseQueue!
    var pyDbQueue: DatabaseQueue!
    
    init(){
        do {
            guard let url = Bundle.main.url(forResource: "english", withExtension: "sqlite3") else {
                print("pinyin_dict.json file not found")
                return
            }
            dbQueue = try DatabaseQueue(path: url.absoluteString)
        } catch {
            print("Database connection to english.sqlite3 error: \(error)")
        }
        
        do {
            guard let url2 = Bundle.main.url(forResource: "pinyin_data", withExtension: "sqlite3") else {
                print("pinyin_dict.json file not found")
                return
            }
            pyDbQueue = try DatabaseQueue(path: url2.absoluteString)
        } catch {
            print("Database connection to english.sqlite3 error: \(error)")
        }
    }
    
    func fetchEnglishWords(withPrefix prefix: String) -> [String] {
        var words: [Word] = []
        
        dbQueue.inDatabase { db in
            let sql = "SELECT * FROM words WHERE word LIKE ? ORDER BY freq DESC LIMIT 20"
            let pattern = "\(prefix)%"
            words = try! Word.fetchAll(db, sql: sql, arguments: [pattern])
        }
        return words.map{$0.word}
    }
    
    func fetchHanZiByPinyin(withPrefix prefix: String) -> [String] {
        var words: [Pinyin] = []
        
        pyDbQueue.inDatabase { db in
            let sql = "SELECT * FROM pinyin_data WHERE py LIKE ? or abbr LIKE ? ORDER BY freq DESC LIMIT 20"
            let pattern = "\(prefix)%"
            words = try! Pinyin.fetchAll(db, sql: sql, arguments: [pattern, pattern])
        }
        
        return words.map{$0.hz}
    }
}

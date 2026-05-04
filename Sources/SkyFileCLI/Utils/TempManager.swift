//
//  TempManager.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import Foundation

struct TempManager {

    static func write(_ data: Data, name: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("skyfile")

        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let url = dir.appendingPathComponent(name)
        try data.write(to: url)
        return url
    }
}
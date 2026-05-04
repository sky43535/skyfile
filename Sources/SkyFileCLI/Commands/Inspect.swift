//
//  Inspect.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import ArgumentParser
import Foundation

extension SkyFileCLI {

    struct Inspect: ParsableCommand {

        static let configuration = CommandConfiguration(
            abstract: "Inspect metadata of a .sky file",
            discussion: """
            Displays information stored in the .sky container header.

            Example:
              skyfile inspect file.sky
            """
        )

        @Argument(help: "Path to the .sky file")
        var path: String

        func run() throws {

            let url = URL(fileURLWithPath: path)

            guard FileManager.default.fileExists(atPath: url.path) else {
                throw ValidationError("File not found at path: \(path)")
            }

            let container = try SkyFile.decode(url)

            // MARK: - Output

            print("""
            📄 SKYFILE INSPECT
            -------------------
            Name:      \(container.header.filename)
            Type:      \(container.header.type)
            Encrypted: \(container.header.encrypted)
            Size:      \(container.payload.count) bytes
            Path:      \(url.path)
            """)
        }
    }
}

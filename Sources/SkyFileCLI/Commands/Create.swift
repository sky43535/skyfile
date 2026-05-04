//
//  Create.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import ArgumentParser
import Foundation

extension SkyFileCLI {

    struct Create: ParsableCommand {

        static let configuration = CommandConfiguration(
            abstract: "Create a .sky container from a file",
            discussion: """
            Wraps any file into a .sky container.

            If no output path is provided, the file will be created
            in the current directory with the same name and a .sky extension.

            Examples:
              skyfile create image.png
              skyfile create image.png output.sky
            """
        )

        @Argument(help: "Path to the source file")
        var source: String

        @Argument(help: "Optional output path for the .sky file")
        var output: String?

        func run() throws {

            let sourceURL = URL(fileURLWithPath: source)

            guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                throw ValidationError("File not found at path: \(source)")
            }

            // MARK: - Read source file

            let data = try Data(contentsOf: sourceURL)

            // MARK: - Build container

            let header = SkyHeader(
                version: 1,
                encrypted: false,
                filename: sourceURL.lastPathComponent,
                type: sourceURL.pathExtension
            )

            let container = SkyContainer(
                header: header,
                payload: data
            )

            let outData = try SkyFile.encode(container)

            // MARK: - Output path

            let outURL: URL

            if let output {
                outURL = URL(fileURLWithPath: output)
            } else {
                let baseName = sourceURL.deletingPathExtension().lastPathComponent
                let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                outURL = currentDir.appendingPathComponent("\(baseName).sky")
            }

            // MARK: - Write file

            try outData.write(to: outURL)

            CLIPrinter.success("Created \(outURL.path)")
        }
    }
}

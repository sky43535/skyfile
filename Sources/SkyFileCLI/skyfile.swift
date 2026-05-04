// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CryptoKit
import ArgumentParser

// =======================
// MARK: - Core Types
// =======================

struct SkyHeader: Codable {
    var version: Int = 1
    var encrypted: Bool
    var filename: String
    var type: String
}

struct SkyContainer: Codable {
    var header: SkyHeader
    var payload: Data
}

// =======================
// MARK: - File Format
// =======================

struct SkyFile {

    static let marker = Data("--DATA--".utf8)

    static func encode(_ container: SkyContainer) throws -> Data {
        let headerData = try JSONEncoder().encode(container.header).base64EncodedData()

        var out = Data()
        out.append(headerData)
        out.append(marker)
        out.append(container.payload)

        return out
    }

    static func decode(_ url: URL) throws -> SkyContainer {
        let raw = try Data(contentsOf: url)

        guard let range = raw.range(of: marker) else {
            throw NSError(domain: "skyfile", code: 1)
        }

        let headerPart = raw[..<range.lowerBound]
        let payload = raw[range.upperBound...]

        guard let headerData = Data(base64Encoded: headerPart),
              let header = try? JSONDecoder().decode(SkyHeader.self, from: headerData) else {
            throw NSError(domain: "skyfile", code: 2)
        }

        return SkyContainer(header: header, payload: Data(payload))
    }
}

// =======================
// MARK: - CLI Entry
// =======================

@main
struct SkyFileCLI: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "skyfile",
        abstract: "Secure .sky file system",
        subcommands: [
            Create.self,
            Inspect.self,
            Open.self,
            Encrypt.self,
            Decrypt.self
        ]
    )
}

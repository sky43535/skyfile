//
//  Open.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import ArgumentParser
import Foundation
import CryptoKit

#if os(macOS)
import AppKit
#endif

extension SkyFileCLI {

    struct Open: ParsableCommand {

        static let configuration = CommandConfiguration(
            abstract: "Open a .sky file using the system default app",
            discussion: """
            Opens a .sky file. If encrypted, a key must be provided.

            Examples:
              skyfile open file.sky
              skyfile open file.sky "my-key"
              skyfile open file.sky --raw
            """
        )

        @Argument(help: "Path to the .sky file")
        var path: String

        @Argument(help: "Optional decryption key (required if encrypted)")
        var key: String?

        @Flag(name: .long, help: "Open raw payload as text")
        var raw = false

        func run() throws {

            let url = URL(fileURLWithPath: path)
            let container = try SkyFile.decode(url)

            var data: Data

            // MARK: - Encrypted handling

            if container.header.encrypted {

                guard let key else {
                    throw ValidationError("This file is encrypted. Provide a key.")
                }

                let symmetricKey: SymmetricKey

                if let base64 = Data(base64Encoded: key) {
                    symmetricKey = SymmetricKey(data: base64)
                } else {
                    let hashed = SHA256.hash(data: Data(key.utf8))
                    symmetricKey = SymmetricKey(data: hashed)
                }

                data = try CryptoManager.decrypt(
                    container.payload,
                    key: symmetricKey
                )

            } else {
                data = container.payload
            }

            // MARK: - RAW MODE

            if raw {
                let text = String(decoding: data, as: UTF8.self)
                let temp = try TempManager.write(
                    Data(text.utf8),
                    name: "sky.txt"
                )

                openFile(temp)
                return
            }

            // MARK: - NORMAL OPEN

            let temp = try TempManager.write(
                data,
                name: container.header.filename
            )

            openFile(temp)
        }
    }
}

//
// MARK: - Cross-platform file opener
//

func openFile(_ url: URL) {

    #if os(macOS)
    NSWorkspace.shared.open(url)

    #elseif os(Windows)
    Process.open("cmd", ["/c", "start", "", url.path])

    #elseif os(Linux)
    Process.open("xdg-open", [url.path])

    #else
    print("Unsupported OS. File saved at: \(url.path)")
    #endif
}

//
// MARK: - Process helper
//

extension Process {

    static func open(_ command: String, _ args: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + args

        do {
            try process.run()
        } catch {
            print("Failed to open file: \(error)")
        }
    }
}

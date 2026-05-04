//
//  Decrypt.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import ArgumentParser
import Foundation
import CryptoKit

extension SkyFileCLI {

    struct Decrypt: ParsableCommand {

        static let configuration = CommandConfiguration(
            abstract: "Decrypt a .sky file",
            discussion: """
            Decrypts a previously encrypted .sky file using a key.

            The key must match the one used during encryption.

            Examples:
              skyfile decrypt file.sky "my-password"
              skyfile decrypt file.sky "base64Key=="
            """
        )

        @Argument(help: "Path to the .sky file")
        var path: String

        @Argument(help: "Decryption key (password or base64 key)")
        var key: String

        func run() throws {

            let url = URL(fileURLWithPath: path)

            guard FileManager.default.fileExists(atPath: url.path) else {
                throw ValidationError("File not found at path: \(path)")
            }

            let container = try SkyFile.decode(url)

            guard container.header.encrypted else {
                throw ValidationError("File is not encrypted")
            }

            // MARK: - Key Handling (must match Encrypt)

            let symmetricKey: SymmetricKey

            if let data = Data(base64Encoded: key) {
                // generated key
                symmetricKey = SymmetricKey(data: data)
            } else {
                // password-style key
                let hashed = SHA256.hash(data: Data(key.utf8))
                symmetricKey = SymmetricKey(data: hashed)
            }

            // MARK: - Decrypt

            let decrypted: Data

            do {
                decrypted = try CryptoManager.decrypt(
                    container.payload,
                    key: symmetricKey
                )
            } catch {
                throw ValidationError("Decryption failed. Key may be incorrect.")
            }

            // MARK: - Rebuild container

            let newHeader = SkyHeader(
                version: 1,
                encrypted: false,
                filename: container.header.filename,
                type: container.header.type
            )

            let newContainer = SkyContainer(
                header: newHeader,
                payload: decrypted
            )

            let final = try SkyFile.encode(newContainer)
            try final.write(to: url)

            // MARK: - Output

            CLIPrinter.success("Decrypted \(url.lastPathComponent)")
        }
    }
}

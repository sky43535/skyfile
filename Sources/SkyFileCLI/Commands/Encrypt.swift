//
//  Encrypt.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import ArgumentParser
import Foundation
import CryptoKit

extension SkyFileCLI {

    struct Encrypt: ParsableCommand {

        static let configuration = CommandConfiguration(
            abstract: "Encrypt a .sky file",
            discussion: """
            Encrypts the payload of a .sky file using AES-GCM.

            If no key is provided, a secure random key is generated and printed.

            Examples:
              skyfile encrypt file.sky
              skyfile encrypt file.sky "my-password"
              skyfile encrypt file.sky "base64Key=="
            """
        )

        @Argument(help: "Path to the .sky file")
        var path: String

        @Argument(help: "Optional encryption key or password")
        var key: String?

        func run() throws {

            let url = URL(fileURLWithPath: path)

            guard FileManager.default.fileExists(atPath: url.path) else {
                throw ValidationError("File not found at path: \(path)")
            }

            let container = try SkyFile.decode(url)

            // Prevent double encryption (optional but smart)
            if container.header.encrypted {
                throw ValidationError("File is already encrypted")
            }

            // MARK: - Key Handling

            let symmetricKey: SymmetricKey
            let printedKey: String

            if let key {
                if let data = Data(base64Encoded: key) {
                    // base64 key
                    symmetricKey = SymmetricKey(data: data)
                    printedKey = key
                } else {
                    // password → hash
                    let hashed = SHA256.hash(data: Data(key.utf8))
                    symmetricKey = SymmetricKey(data: hashed)
                    printedKey = key
                }
            } else {
                // generate random key
                symmetricKey = CryptoManager.generateKey()
                printedKey = symmetricKey.withUnsafeBytes {
                    Data($0).base64EncodedString()
                }
            }

            // MARK: - Encrypt

            let encryptedData = try CryptoManager.encrypt(
                container.payload,
                key: symmetricKey
            )

            // MARK: - Build new container

            let newHeader = SkyHeader(
                version: 1,
                encrypted: true,
                filename: container.header.filename,
                type: container.header.type
            )

            let newContainer = SkyContainer(
                header: newHeader,
                payload: encryptedData
            )

            let final = try SkyFile.encode(newContainer)

            try final.write(to: url)

            // MARK: - Output

            CLIPrinter.success("Encrypted \(url.lastPathComponent)")
            CLIPrinter.info("Key: \(printedKey)")
        }
    }
}

//
//  CryptoManager.swift
//  skyfile
//
//  Created by skyler peterson on 5/3/26.
//


import Foundation
import CryptoKit

struct CryptoManager {

    // MARK: - Key

    static func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    // MARK: - Encrypt

    static func encrypt(_ data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)

        guard let combined = sealedBox.combined else {
            throw NSError(domain: "crypto", code: 1)
        }

        return combined
    }

    // MARK: - Decrypt

    static func decrypt(_ combined: Data, key: SymmetricKey) throws -> Data {
        let box = try AES.GCM.SealedBox(combined: combined)
        return try AES.GCM.open(box, using: key)
    }
}

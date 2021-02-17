//
//  CredentialModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 21/11/20.
//

import Foundation

struct CredentialModel: Codable {
    let type, id: String?
    let thread: CredentialModelThread?
    let credentialPreview: CredentialPreview?
    let offersAttach: [OffersAttach]?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case thread = "~thread"
        case credentialPreview = "credential_preview"
        case offersAttach = "offers~attach"
        case comment
    }
}

// MARK: - CredentialPreview
struct CredentialPreview: Codable {
    let type: String?
    let attributes: [Attribute]?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case attributes
    }
}

// MARK: - Attribute
struct Attribute: Codable {
    let name, value: String?
}

// MARK: - OffersAttach
struct OffersAttach: Codable {
    let id, mimeType: String?
    let data: DataClass?

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case mimeType = "mime-type"
        case data
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    let base64: String?
}

// MARK: - Thread
struct CredentialModelThread: Codable {
}

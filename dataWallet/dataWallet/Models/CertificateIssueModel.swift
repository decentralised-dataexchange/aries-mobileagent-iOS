//
//  CertificateIssueModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 27/11/20.
//

import Foundation

struct CertificateIssueModel: Codable {
    let type, id: String?
    let thread: IssueCertificateThread?
    let credentialPreview: IssueCertificateCredentialPreview?
    let offersAttach: [IssueCertificateOffersAttach]?
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
struct IssueCertificateCredentialPreview: Codable {
    let type: String?
    let attributes: [IssueCertificateAttribute]?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case attributes
    }
}

// MARK: - Attribute
struct IssueCertificateAttribute: Codable {
    let name, value: String?
}

// MARK: - OffersAttach
struct IssueCertificateOffersAttach: Codable {
    let id, mimeType: String?
    let data: IssueCertificateDataClass?

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case mimeType = "mime-type"
        case data
    }
}

// MARK: - DataClass
struct IssueCertificateDataClass: Codable {
    let base64: String?
}

// MARK: - Thread
struct IssueCertificateThread: Codable {
    let thid: String?
}

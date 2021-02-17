// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let issueCredentialMesageIssueCredentialMessage = try? newJSONDecoder().decode(IssueCredentialMesageIssueCredentialMessage.self, from: jsonData)

import Foundation

// MARK: - IssueCredentialMesageIssueCredentialMessage
struct IssueCredentialMessageModel: Codable {
    let message: IssueCredentialMesage?
    let senderVerkey, recipientVerkey: String?

    enum CodingKeys: String, CodingKey {
        case message
        case senderVerkey = "sender_verkey"
        case recipientVerkey = "recipient_verkey"
    }
}

// MARK: - IssueCredentialMesageMessage
struct IssueCredentialMesage: Codable {
    let type, id: String?
    let thread: IssueCredentialMesageThread?
    let credentialsAttach: [IssueCredentialMesageCredentialsAttach]?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case thread = "~thread"
        case credentialsAttach = "credentials~attach"
        case comment
    }
}

// MARK: - IssueCredentialMesageCredentialsAttach
struct IssueCredentialMesageCredentialsAttach: Codable {
    let id, mimeType: String?
    let data: IssueCredentialMesageData?

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case mimeType = "mime-type"
        case data
    }
}

// MARK: - IssueCredentialMesageData
struct IssueCredentialMesageData: Codable {
    let base64: String?
}

// MARK: - IssueCredentialMesageThread
struct IssueCredentialMesageThread: Codable {
    let thid: String?
}


//
//  SearchInboxModel.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 18/01/21.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let inboxModelSearchInboxModel = try? newJSONDecoder().decode(InboxModelSearchInboxModel.self, from: jsonData)

import Foundation

// MARK: - InboxModelSearchInboxModel
struct SearchInboxModel: Codable {
    let totalCount: Int?
    let records: [InboxModelRecord]?

    enum CodingKeys: String, CodingKey {
        case totalCount = "totalCount"
        case records = "records"
    }
}

// MARK: - InboxModelRecord
struct InboxModelRecord: Codable {
    let type: String?
    let id: String?
    let value: InboxModelRecordValue?
    let tags: InboxModelRecordTags?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case id = "id"
        case value = "value"
        case tags = "tags"
    }
}

// MARK: - InboxModelRecordTags
struct InboxModelRecordTags: Codable {
    let threadID: String?
    let type: String?
    let requestID: String?

    enum CodingKeys: String, CodingKey {
        case threadID = "thread_id"
        case type = "type"
        case requestID = "request_id"
    }
}

// MARK: - InboxModelRecordValue
struct InboxModelRecordValue: Codable {
    let connectionModel: CloudAgentConnectionWalletModel?
    let presentationRequest: SearchPresentationExchangeValueModel?
    let offerCredential:SearchCertificateRecord?
    let type: String?
    let orgRecordId: String?

    enum CodingKeys: String, CodingKey {
        case connectionModel = "connectionModel"
        case presentationRequest = "presentationRequest"
        case type = "type"
        case offerCredential
        case orgRecordId

    }
}

enum InboxType: String {
    case certOffer = "CertOffer"
    case certRequest = "CertReq"
}

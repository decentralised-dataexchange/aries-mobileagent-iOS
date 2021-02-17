//
//  SearchConnectionResponse.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 07/12/20.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let searchConnectionResponse = try? newJSONDecoder().decode(SearchConnectionResponse.self, from: jsonData)

import Foundation

// MARK: - SearchConnectionResponse
struct SearchConnectionResponse: Codable {
    let totalCount: Int?
    let records: [SearchConnectionRecord]?
}

// MARK: - SearchConnectionRecord
struct SearchConnectionRecord: Codable {
//    let type: JSONNull?
    let id: String?
    let value: CloudAgentConnectionValue?
    let tags: SearchConnectionTags?
}

// MARK: - SearchConnectionTags
struct SearchConnectionTags: Codable {
    let serviceEndPoint: String?
    let requestID, myDid, invitationKey: String?
    let isIgrantAgent: String?


    enum CodingKeys: String, CodingKey {
        case serviceEndPoint
        case requestID = "request_id"
        case myDid = "my_did"
        case invitationKey = "invitation_key"
        case isIgrantAgent
    }
}

// MARK: - SearchConnectionValue
//struct SearchConnectionValue: Codable {
//    let accept, invitationMode, requestID: String?
//    let inboundConnectionID: JSONNull?
//    let initiator: String?
//    let errorMsg, alias: JSONNull?
//    let myDid, invitationKey: String?
//    let theirRole: JSONNull?
//    let state, routingState, updatedAt, createdAt: String?
//    let theirLabel: String?
//    let imageURL: String?
//
//    enum CodingKeys: String, CodingKey {
//        case accept
//        case invitationMode = "invitation_mode"
//        case requestID = "request_id"
//        case inboundConnectionID = "inbound_connection_id"
//        case initiator
//        case errorMsg = "error_msg"
//        case alias
//        case myDid = "my_did"
//        case invitationKey = "invitation_key"
//        case theirRole = "their_role"
//        case state
//        case routingState = "routing_state"
//        case updatedAt = "updated_at"
//        case createdAt = "created_at"
//        case theirLabel = "their_label"
//        case imageURL = "imageURL"
//    }
//}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

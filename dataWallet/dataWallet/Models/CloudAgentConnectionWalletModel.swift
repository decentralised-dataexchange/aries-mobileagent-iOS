// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let cloudAgentConnectionWalletModel = try? newJSONDecoder().decode(CloudAgentConnectionWalletModel.self, from: jsonData)

import Foundation

// MARK: - CloudAgentConnectionWalletModel
struct CloudAgentConnectionWalletModel: Codable {
    var type: String?
    var id: String?
    var value: CloudAgentConnectionValue?
    var tags: CloudAgentConnectionTags?
    
    init() { }
}


// MARK: - CloudAgentConnectionTags
struct CloudAgentConnectionTags: Codable {
    let theirDid, invitationKey, requestID, myDid, orgId, myVerKey: String?

    enum CodingKeys: String, CodingKey {
        case theirDid = "their_did"
        case invitationKey = "invitation_key"
        case requestID = "request_id"
        case myDid = "my_did"
        case orgId
        case myVerKey
    }
}

// MARK: - CloudAgentConnectionValue
class CloudAgentConnectionValue: Codable {
    let myDid, updatedAt: String?
    let alias: String?
    let routingState, createdAt: String?
    let theirRole: String?
    let requestID, theirLabel, inboxKey, invitationMode: String?
    let accept, inboxID, invitationKey, state: String?
    let inboundConnectionID: String?
    let initiator: String?
    let errorMsg: String?
    let theirDid: String?
    let imageURL: String?
    let reciepientKey: String?
    let isIgrantAgent: String?
    let routingKey: [String]?
    let orgDetails: OrganisationInfoModel?
    let orgId: String?

    enum CodingKeys: String, CodingKey {
        case myDid = "my_did"
        case updatedAt = "updated_at"
        case alias
        case routingState = "routing_state"
        case createdAt = "created_at"
        case theirRole = "their_role"
        case requestID = "request_id"
        case theirLabel = "their_label"
        case inboxKey = "inbox_Key"
        case invitationMode = "invitation_mode"
        case accept
        case inboxID = "inbox_id"
        case invitationKey = "invitation_key"
        case state
        case inboundConnectionID = "inbound_connection_id"
        case initiator
        case errorMsg = "error_msg"
        case theirDid = "their_did"
        case imageURL
        case reciepientKey
        case isIgrantAgent
        case routingKey = "routing_key"
        case orgDetails
        case orgId
    }
}

struct CloudAgentSearchConnectionModel: Codable {
    let totalCount: Int?
    let records: [CloudAgentConnectionWalletModel]?
}

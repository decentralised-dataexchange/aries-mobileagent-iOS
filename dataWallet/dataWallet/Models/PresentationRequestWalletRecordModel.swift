//
//  PresentationRequestWalletRecordModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 13/12/20.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let pRPresentationRequestWalletRecordModel = try? newJSONDecoder().decode(PRPresentationRequestWalletRecordModel.self, from: jsonData)

import Foundation

// MARK: - PresentationRequestWalletRecordModel
struct PresentationRequestWalletRecordModel: Codable {
    var threadID, createdAt, updatedAt, connectionID: String?
    var initiator: String?
    var presentationProposalDict: JSONNull?
    var presentationRequest: PresentationRequestModel?
    var presentationRequestDict: JSONNull?
    var presentation: PRPresentation?
    var role, state: String?
    var autoPresent: Bool?
    var errorMsg, verified: JSONNull?
    var trace: Bool?

    init() {}
    
    enum CodingKeys: String, CodingKey {
        case threadID = "thread_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case connectionID = "connection_id"
        case initiator
        case presentationProposalDict = "presentation_proposal_dict"
        case presentationRequest = "presentation_request"
        case presentationRequestDict = "presentation_request_dict"
        case presentation, role, state
        case autoPresent = "auto_present"
        case errorMsg = "error_msg"
        case verified, trace
    }
    
}

// MARK: - PRPresentation
struct PRPresentation: Codable {
    let proof: PRPresentationProof?
    let requestedProof: PRRequestedProof?
    let identifiers: [PRIdentifier]?

    enum CodingKeys: String, CodingKey {
        case proof
        case requestedProof = "requested_proof"
        case identifiers
    }
}

// MARK: - PRIdentifier
struct PRIdentifier: Codable {
    let schemaID, credDefID: String?
    let revRegID, timestamp: String?

    enum CodingKeys: String, CodingKey {
        case schemaID = "schema_id"
        case credDefID = "cred_def_id"
        case revRegID = "rev_reg_id"
        case timestamp
    }
}

// MARK: - PRPresentationProof
struct PRPresentationProof: Codable {
    let proofs: [PRProofElement]?
    let aggregatedProof: PRAggregatedProof?

    enum CodingKeys: String, CodingKey {
        case proofs
        case aggregatedProof = "aggregated_proof"
    }
}

// MARK: - PRAggregatedProof
struct PRAggregatedProof: Codable {
    let cHash: String?
    let cList: [[Int]]?

    enum CodingKeys: String, CodingKey {
        case cHash = "c_hash"
        case cList = "c_list"
    }
}

// MARK: - PRProofElement
struct PRProofElement: Codable {
    let primaryProof: PRPrimaryProof?
    let nonRevocProof: String? = nil

    enum CodingKeys: String, CodingKey {
        case primaryProof = "primary_proof"
        case nonRevocProof = "non_revoc_proof"
    }
}

// MARK: - PRPrimaryProof
struct PRPrimaryProof: Codable {
    let eqProof: PREqProof?
    let geProofs: [String]?

    enum CodingKeys: String, CodingKey {
        case eqProof = "eq_proof"
        case geProofs = "ge_proofs"
    }
}

// MARK: - PREqProof
struct PREqProof: Codable {
    let revealedAttrs: [String:String?]?
    let aPrime, e, v: String?
    let m: [String:String?]?
    let m2: String?

    enum CodingKeys: String, CodingKey {
        case revealedAttrs = "revealed_attrs"
        case aPrime = "a_prime"
        case e, v
        case m2
        case m
    }
}

// MARK: - PRM
struct PRM: Codable {
    let masterSecret, testresult, testresultid, patientage: String?
    let patientname: String?

    enum CodingKeys: String, CodingKey {
        case masterSecret = "master_secret"
        case testresult, testresultid, patientage, patientname
    }
}

// MARK: - PREqProofRevealedAttrs
struct PREqProofRevealedAttrs: Codable {
    let testdate: String?
}

// MARK: - PRRequestedProof
struct PRRequestedProof: Codable {
    let revealedAttrs: [String: PRRevealedAttrsAdditional]?
    let selfAttestedAttrs, unrevealedAttrs, predicates: PRRequestedPredicates?

    enum CodingKeys: String, CodingKey {
        case revealedAttrs = "revealed_attrs"
        case selfAttestedAttrs = "self_attested_attrs"
        case unrevealedAttrs = "unrevealed_attrs"
        case predicates
    }
}

// MARK: - PRRequestedPredicates
struct PRRequestedPredicates: Codable {
}

// MARK: - PRRevealedAttrsAdditionalProp1
struct PRRevealedAttrsAdditional: Codable {
    let subProofIndex: Int?
    let raw: String?
    let encoded: String?

    enum CodingKeys: String, CodingKey {
        case subProofIndex = "sub_proof_index"
        case raw, encoded
    }
}


public struct IntToBool: Codable {
    public var value: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intValue = try container.decode(Int.self)
        self.value = (intValue != 0)
    }

    public init(value: Bool) {
        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}

//
//  SearchProofRequestItemResponse.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 16/12/20.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let searchProofRequestItemResponse = try? newJSONDecoder().decode(SearchProofRequestItemResponse.self, from: jsonData)

import Foundation

// MARK: - SearchProofRequestItemResponseElement
struct SearchProofRequestItemResponseElement: Codable {
    let credInfo: SearchProofReqCredInfo?
    let interval: JSONNull?

    enum CodingKeys: String, CodingKey {
        case credInfo = "cred_info"
        case interval = "interval"
    }
}

// MARK: - SearchProofReqCredInfo
struct SearchProofReqCredInfo: Codable {
    let referent: String?
    let attrs: [String : String]?
    let schemaID: String?
    let credDefID: String?
    let revRegID: JSONNull?
    let credRevID: JSONNull?

    enum CodingKeys: String, CodingKey {
        case referent = "referent"
        case attrs = "attrs"
        case schemaID = "schema_id"
        case credDefID = "cred_def_id"
        case revRegID = "rev_reg_id"
        case credRevID = "cred_rev_id"
    }
}

struct SearchProofRequestItemResponse:Codable {
    var records: [SearchProofRequestItemResponseElement]?
    
    enum CodingKeys: String, CodingKey {
        case records
    }
}

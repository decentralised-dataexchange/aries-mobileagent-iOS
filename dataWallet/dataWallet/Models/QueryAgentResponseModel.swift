//
//  QueryAgentResponseModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 21/12/20.
//


import Foundation

// MARK: - QueryAgentResponseModel
struct QueryAgentResponseModel: Codable {
    let type: String?
    let id: String?
    let thread: QueryAgentResponseThread?
    let protocols: [ProtocolElement]?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case thread = "~thread"
        case protocols = "protocols"
    }
}

// MARK: - ProtocolElement
struct ProtocolElement: Codable {
    let pid: String?
    let roles: [String]?

    enum CodingKeys: String, CodingKey {
        case pid = "pid"
        case roles = "roles"
    }
}

// MARK: - Thread
struct QueryAgentResponseThread: Codable {
    let thid: String?

    enum CodingKeys: String, CodingKey {
        case thid = "thid"
    }
}

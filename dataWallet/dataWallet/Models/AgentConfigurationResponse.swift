//
//  AgentConfigurationResponse.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 15/11/20.
//

import Foundation

struct AgentConfigurationResponse: Codable {
    let serviceEndpoint: String?
    let routingKey: String?
    let invitation: Invitation?

    enum CodingKeys: String, CodingKey {
        case serviceEndpoint = "ServiceEndpoint"
        case routingKey = "RoutingKey"
        case invitation = "Invitation"
    }
}

// MARK: - Invitation
struct Invitation: Codable {
    let label, imageURL: String?
    let serviceEndpoint: String?
    let routingKeys: [String]?
    let recipientKeys: [String]?
    let id, type: String?

    enum CodingKeys: String, CodingKey {
        case label
        case imageURL = "imageUrl"
        case serviceEndpoint, routingKeys, recipientKeys
        case id = "@id"
        case type = "@type"
    }
}


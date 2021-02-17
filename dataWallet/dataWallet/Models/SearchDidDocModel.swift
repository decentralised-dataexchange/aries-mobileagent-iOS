//
//  MediatorDidDocModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 24/11/20.
//

import Foundation

// MARK: - MediatorDidDocModel
struct SearchDidDocModel: Codable {
    let totalCount: Int?
    let records: [DidDocModel]?
}

// MARK: - DidDocModel
struct DidDocModel: Codable {
    let type: JSONNull?
    let id: String?
    let value: Value?
    let tags: Tags?
}

// MARK: - Tags
struct Tags: Codable {
    let did: String?
}

// MARK: - Value
struct Value: Codable {
    let context: String?
    let service: [Service]?
    let authentication: [Authentication]?
    let id: String?
    let publicKey: [PublicKey]?

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case service, authentication, id, publicKey
    }
}

// MARK: - Authentication
struct Authentication: Codable {
    let type, publicKey: String?
}

// MARK: - PublicKey
struct PublicKey: Codable {
    let controller, id, type, publicKeyBase58: String?
}

// MARK: - Service
struct Service: Codable {
    let routingKeys: [String]?
    let type: String?
    let serviceEndpoint: String?
    let priority: Int?
    let id: String?
    let recipientKeys: [String]?
}

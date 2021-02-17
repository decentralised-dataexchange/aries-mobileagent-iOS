//
//  UnpackMessageModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 16/11/20.
//


import Foundation

// MARK: - UnpackMessageModel
struct UnpackMessageModel: Codable {
    let message: Message?
    let recipientVerkey: String?

    enum CodingKeys: String, CodingKey {
        case message
        case recipientVerkey = "recipient_verkey"
    }
}

// MARK: - Message
struct Message: Codable {
    let type, id: String?
    let thread: UnpackMsgThread?
    let connectionSig: ConnectionSig?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case thread = "~thread"
        case connectionSig = "connection~sig"
    }
}

// MARK: - ConnectionSig
struct ConnectionSig: Codable {
    let type, signature, sigData, signer: String?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case signature
        case sigData = "sig_data"
        case signer
    }
}

// MARK: - Thread
struct UnpackMsgThread: Codable {
    let thid: String?
}

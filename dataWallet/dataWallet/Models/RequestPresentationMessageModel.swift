//
//  RequestPresentationMessageModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 13/12/20.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let requestPresentationMessageModel = try? newJSONDecoder().decode(RequestPresentationMessageModel.self, from: jsonData)

import Foundation

// MARK: - RequestPresentationMessageModel
struct RequestPresentationMessageModel: Codable {
    let type, id, comment: String?
    let requestPresentationsAttach: [RequestPresentationsAttach]?
    let thread: RequestPresentationsAttachThread?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case comment
        case requestPresentationsAttach = "request_presentations~attach"
        case thread = "~thread"
    }
}

// MARK: - RequestPresentationsAttach
struct RequestPresentationsAttach: Codable {
    let id, mimeType: String?
    let data: DataClass?

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case mimeType = "mime-type"
        case data
    }
}

// MARK: - Thread
struct RequestPresentationsAttachThread: Codable {
    let thid: String?
}

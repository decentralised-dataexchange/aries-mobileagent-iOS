//
//  ExchangeDataQRCodeModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 18/12/20.
//

import Foundation

// MARK: - ExchangeDataQRCodeModel
struct ExchangeDataQRCodeModel: Codable {
    let invitationURL: String?
    let proofRequest: PresentationRequestModel?

    enum CodingKeys: String, CodingKey {
        case invitationURL = "invitation_url"
        case proofRequest = "proof_request"
    }
}

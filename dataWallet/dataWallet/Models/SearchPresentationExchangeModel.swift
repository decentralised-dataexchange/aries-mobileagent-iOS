//
//  SearchPresentationExchangeModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 15/12/20.
//

import Foundation

struct SearchPresentationExchangeModel: Codable {
    var totalCount: Int?
    var records: [SearchPresentationExchangeValueModel]?
}

struct SearchPresentationExchangeValueModel: Codable {
    var type: String?
    var id: String?
    var value: PresentationRequestWalletRecordModel?
}

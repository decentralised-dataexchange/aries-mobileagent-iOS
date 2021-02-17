//
//  WalletCertModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 28/12/20.
//

import Foundation

// MARK: - OrganisationListDataWalletCerttModel
class CustomWalletRecordCertModel: Codable {
    var referent: WalletCredentialModel?
    var schemaID:String?
    var certInfo: SearchCertificateRecord?
    var connectionInfo: CloudAgentConnectionWalletModel?
    init(){}
    
    enum CodingKeys: String, CodingKey {
        case referent
        case connectionInfo
        case schemaID
        case certInfo
    }
}

struct Search_CustomWalletRecordCertModel: Codable {
    var totalCount: Int?
    var records: [SearchItems_CustomWalletRecordCertModel]?
}

struct SearchItems_CustomWalletRecordCertModel: Codable {
    var type: String?
    var id: String?
    var value: CustomWalletRecordCertModel?
}

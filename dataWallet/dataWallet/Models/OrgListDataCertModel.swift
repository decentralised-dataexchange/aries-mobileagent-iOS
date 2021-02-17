//
//  OrgListDataCertModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 23/12/20.
//

import Foundation


// MARK: - OrganisationListDataCERTModel
class OrganisationListDataCERTModel: Codable {
    let type: String?
    let id: String?
    let dataCertificateTypes: [OrganisationListDataDataCertificateType]?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case dataCertificateTypes = "data_certificate_types"
    }
}

// MARK: - OrganisationListDataDataCertificateType
class OrganisationListDataDataCertificateType: Codable {
    let schemaVersion: String?
    let schemaName: String?
    let epoch: String?
    let schemaID: String?
    let credDefID: String?
    let schemaIssuerDid: String?
    let issuerDid: String?
    let schemaAttributes: [String]?
    var offerAvailable: Bool?
    var certificates: InboxModelRecord?
    var attrArray: [SearchCertificateAttribute]?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaName = "schema_name"
        case epoch = "epoch"
        case schemaID = "schema_id"
        case credDefID = "cred_def_id"
        case schemaIssuerDid = "schema_issuer_did"
        case issuerDid = "issuer_did"
        case offerAvailable
        case certificates
        case schemaAttributes = "schema_attributes"
        case attrArray
    }
}

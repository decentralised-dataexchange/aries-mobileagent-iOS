//
//  OrganisationDetailModel.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 21/12/20.
//

import Foundation


// MARK: - OrganisationInfoModel
struct OrganisationInfoModel: Codable {
    let type: String?
    let id: String?
    let name: String?
    let policyURL: String?
    let orgType: String?
    let logoImageURL: String?
    let location: String?
    let privacyDashboard: OrganisationInfoPrivacyDashboard?
    let coverImageURL: String?
    let organisationInfoModelDescription: String?
    let eulaURL: String?
    let orgId: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case name = "name"
        case policyURL = "policy_url"
        case orgType = "org_type"
        case logoImageURL = "logo_image_url"
        case location = "location"
        case privacyDashboard = "privacy_dashboard"
        case coverImageURL = "cover_image_url"
        case organisationInfoModelDescription = "description"
        case eulaURL = "eula_url"
        case orgId = "org_id"
    }
}

// MARK: - OrganisationInfoPrivacyDashboard
struct OrganisationInfoPrivacyDashboard: Codable {
    let hostName: String?
    let version: String?
    let status: Int?
    let delete: Bool?

    enum CodingKeys: String, CodingKey {
        case hostName = "host_name"
        case version = "version"
        case status = "status"
        case delete = "delete"
    }
}

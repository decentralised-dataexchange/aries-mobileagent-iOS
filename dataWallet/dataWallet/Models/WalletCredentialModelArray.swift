//
//  WalletCredentialModelArray.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 12/12/20.
//

import Foundation

// MARK: - WalletCredentialModelArray
struct WalletCredentialModel: Codable {
    let referent: String?
    let attrs: [String:String]?
    let schemaID, credDefID: String?
    let revRegID, credRevID: String?

    enum CodingKeys: String, CodingKey {
        case referent, attrs
        case schemaID = "schema_id"
        case credDefID = "cred_def_id"
        case revRegID = "rev_reg_id"
        case credRevID = "cred_rev_id"
    }
}



struct  WalletCredentialModelArray: Codable{
    let records: [WalletCredentialModel]?
    
    enum CodingKeys: String, CodingKey {
        case records
    }
}

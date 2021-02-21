//
//  Constants.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 06/01/21.
//

import Foundation

struct Constants {
    public static let didRecieveCertOffer = Notification.Name(rawValue: "io.igrant.recieved.certOffer")
    public static let didRecieveDataExchangeRequest = Notification.Name(rawValue: "io.igrant.recieved.dataExchangeRequest")
    public static let reloadWallet = Notification.Name(rawValue: "io.igrant.wallet.reload")
    public static let reloadOrgList = Notification.Name(rawValue: "io.igrant.OrganisationList.reload")

    public static let userDefault_ledger = "Ledger"
    public static let userDefault_language = "Language"
    public static let ledger_igrant_old_sandbox = "iGrant.io Sandbox Old"
    public static let ledger_igrant_sandbox = "iGrant.io Sandbox"
    public static let ledger_sovrin_builder = "Sovrin Builder"
    public static let ledger_sovrin_live = "Sovrin Live"
    public static let ledger_sovrin_sandbox = "Sovrin Sandbox"
}

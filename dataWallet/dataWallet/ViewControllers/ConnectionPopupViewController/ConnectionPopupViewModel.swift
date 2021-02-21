//
//  ConnectionPopupViewModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 19/12/20.
//

import Foundation

protocol ConnectionPopupViewModelDelegate: class{
    func connectionEstablised(connModel:CloudAgentConnectionWalletModel, recipientKey: String, myVerKey: String)
    func dismissPopup()
}

struct ConnectionPopupViewModel {
    var orgName: String?
    var orgImageURL: String?
    var walletHandler: IndyHandle?
    var recipientKey: String?
    var serviceEndPoint: String?
    var routingKey: [String]?
    var pollingEnabled: Bool!
    var orgId: String?
    var orgDetails: OrganisationInfoModel?
    weak var delegate:ConnectionPopupViewModelDelegate?
    
    init(orgName: String?,orgImageURL: String?,walletHandler: IndyHandle?,recipientKey: String?,serviceEndPoint: String?,routingKey: [String]?, pollingEnabled: Bool? = false, orgId: String?, orgDetails: OrganisationInfoModel?) {
        self.orgName = orgName
        self.orgImageURL = orgImageURL
        self.walletHandler = walletHandler
        self.recipientKey = recipientKey
        self.serviceEndPoint = serviceEndPoint
        self.routingKey  = routingKey
        self.pollingEnabled = pollingEnabled ?? true
        self.orgId = orgId
        self.orgDetails = orgDetails
    }
    //(walletHandler: IndyHandle, label: String, theirVerKey: String,serviceEndPoint: String, routingKey: String, imageURL: String,mediatorVerKey: String,pollingEnabled: Bool = true,completion: @escaping(Bool) -> Void)
    
    func startConnection(){
        AriesCloudAgentHelper.shared.newConnectionConfigCloudAgent(walletHandler: self.walletHandler ?? IndyHandle(), label: self.orgName ?? "", theirVerKey: self.recipientKey ?? "", serviceEndPoint: self.serviceEndPoint ?? "", routingKey: self.routingKey, imageURL: self.orgImageURL ?? "", pollingEnabled: self.pollingEnabled,orgId: self.orgId,orgDetails: self.orgDetails) { (connectionModel,recipientKey,myVerKey)  in
            if let connectionModel = connectionModel, let recipientKey = recipientKey, let myVerKey = myVerKey {
                delegate?.connectionEstablised(connModel:connectionModel, recipientKey: recipientKey, myVerKey: myVerKey)
            } else {
                delegate?.dismissPopup()
            }
            
        }
    }
}

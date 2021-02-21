//
//  WalletCertificateDetailViewModel.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 22/01/21.
//

import Foundation
import SVProgressHUD

protocol WalletCertificateDetailDelegate:class {
    func popVC()
}
class WalletCertificateDetailViewModel {
    var walletHandle: IndyHandle?
    var certDetail: SearchCertificateRecord?
    var reqId : String?
    weak var delegate: WalletCertificateDetailDelegate?
    var inboxId: String?
    var certModel:SearchItems_CustomWalletRecordCertModel?
    var orgInfo: OrganisationInfoModel?

    init(walletHandle: IndyHandle?,reqId: String?,certDetail: SearchCertificateRecord?,inboxId: String?, certModel:SearchItems_CustomWalletRecordCertModel? = nil) {
        self.walletHandle = walletHandle
        self.certDetail = certDetail
        self.reqId = reqId
        self.inboxId = inboxId
        self.certModel = certModel
    }
    
    func getOrgInfo(completion:@escaping ((Bool) -> Void)){
        let walletHandler = self.walletHandle ?? IndyHandle()
        SVProgressHUD.show()
//        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithId, record_id: self.reqId ?? "") { (success, searchHandler, error) in
//            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) { (success, invResult, error) in
//                let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: invResult)
//                let searchConnModel = CloudAgentSearchConnectionModel.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? CloudAgentSearchConnectionModel
//                let connModel = searchConnModel?.records?.first
        AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: certModel?.value?.connectionInfo?.value?.myDid ?? "", completion: { [unowned self] (metadataRecieved,metadata, error) in
                    let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                    if let verKey = metadataDict?["verkey"] as? String{
                       
                            AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnectionInvitation, searchType: .searchWithId,record_id: self.certModel?.value?.connectionInfo?.value?.requestID ?? "") {[unowned self] (success, searchHandler, error) in
                                AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (searchSuccess, records, error) in
                                    let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: records)
                                    let invitationRecord = (resultsDict?["records"] as? [[String: Any]])?.first
                                    let serviceEndPoint = (invitationRecord?["value"] as? [String: Any])?["serviceEndpoint"] as? String ?? ""
                                    NetworkManager.shared.baseURL = serviceEndPoint
                                AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: self.certModel?.value?.connectionInfo?.value?.reciepientKey ?? "", myVerKey: verKey, type: .getIgrantOrgDetail,isRoutingKeyEnabled: false) {[unowned self] (success, orgPackedData, error) in
                                    NetworkManager.shared.sendMsg(isMediator: false, msgData: orgPackedData ?? Data()) { [unowned self](statuscode,orgServerResponseData) in
                                        if statuscode != 200 {
                                            completion(true)
                                            SVProgressHUD.dismiss()
                                           return
                                        }
                                        AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: orgServerResponseData ?? Data()) {[unowned self] (unpackedSuccessfully, orgDetailsData, error) in
                                            if let messageModel = try? JSONSerialization.jsonObject(with: orgDetailsData ?? Data(), options: []) as? [String : Any] {
                                                print("unpackmsg -- \(messageModel)")
                                                let msgString = (messageModel)["message"] as? String
                                                let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "",boolKeys: ["delete"])
                                                let recipient_verkey = (messageModel)["recipient_verkey"] as? String ?? ""
                                                let sender_verkey = (messageModel)["sender_verkey"] as? String ?? ""
                                                print("Org details recieved")
                                                var orgInfoModel = OrganisationInfoModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? OrganisationInfoModel
                                                if orgInfoModel == nil {
                                                    orgInfoModel = self.certModel?.value?.connectionInfo?.value?.orgDetails
                                                }
                                                self.orgInfo = orgInfoModel
                                                completion(true)
                                                SVProgressHUD.dismiss()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        SVProgressHUD.dismiss()
                    }
        })
    }
    
    func deleteCredentialWith(id:String,walletRecordId: String?) {
        let walletHandler = self.walletHandle ?? 0
        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.walletCertificates, id: walletRecordId ?? "") { [unowned self](success, error) in
            AriesPoolHelper.shared.deleteCredentialFromWallet(withId: id, walletHandle: walletHandler) {[unowned self] (success, error) in
                NotificationCenter.default.post(name: Constants.reloadWallet, object: nil)
                self.delegate?.popVC()
            }
        }
    }
}

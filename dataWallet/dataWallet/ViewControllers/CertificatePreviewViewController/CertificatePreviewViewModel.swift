//
//  CertificatePreviewViewModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 07/12/20.
//

import Foundation
import SVProgressHUD

protocol CertificatePreviewDelegate: class {
    func popVC()
}

class CertificatePreviewViewModel {
    var walletHandle: IndyHandle?
    var certDetail: SearchCertificateRecord?
    var reqId : String?
    weak var delegate: CertificatePreviewDelegate?
    var inboxId: String?
    var certModel:SearchItems_CustomWalletRecordCertModel?
    
    init(walletHandle: IndyHandle?,reqId: String?,certDetail: SearchCertificateRecord?,inboxId: String?, certModel:SearchItems_CustomWalletRecordCertModel? = nil) {
        self.walletHandle = walletHandle
        self.certDetail = certDetail
        self.reqId = reqId
        self.inboxId = inboxId
        self.certModel = certModel
    }
    
    func acceptCertificate() {
        SVProgressHUD.show()
        let walletHandler = walletHandle ?? IndyHandle()
        AriesPoolHelper.shared.pool_setProtocol(version: 2) {[unowned self] (success, error) in
            AriesPoolHelper.shared.pool_openLedger(name: "default", config: [String:Any]()) { [unowned self](success, ledgerHandler, error) in
                AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection,searchType: .searchWithId, record_id: self.reqId ?? "", completion: { [unowned self](success, searchWalletHandler, error) in
                    if (success){
                        AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: {[unowned self] (fetchedSuccessfully,results,error) in
                            if (fetchedSuccessfully){
                                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: results,boolKeys: ["delete"])
                                let firstResult = (resultDict?["records"] as? [[String: Any]])?.first
                                if let connectionRecordId = (resultDict?["records"] as? [[String:Any]])?.first?["id"] as? String {
                                    if let myDid = (firstResult?["value"] as? [String: Any])?["my_did"] as? String, let recipientKey = (firstResult?["value"] as? [String: Any])?["reciepientKey"] as? String {
                                        AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: myDid, completion: {[unowned self] (metadataRecieved,metadata, error) in
                                            let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                                            if let verKey = metadataDict?["verkey"] as? String{
                                                AriesPoolHelper.shared.buildGetCredDefRequest(id: self.certDetail?.value?.credentialDefinitionID ?? "") { [unowned self](success, credDefReqResponse, error) in
                                                    AriesPoolHelper.shared.submitRequest(poolHandle: AriesPoolHelper.poolHandler, requestJSON: credDefReqResponse) { [unowned self](success, credDefSubmitResponse, error) in
                                                        AriesPoolHelper.shared.parseGetCredDefResponse(response: credDefSubmitResponse) {[unowned self](success, credDefId, credDefJson, error) in
                                                            if error?.localizedDescription.contains("309") ?? false {
                                                                SVProgressHUD.dismiss()
                                                                UIApplicationUtils.showErrorSnackbar(message: "Invalid Ledger. You can choose proper ledger from settings".localized())
                                                                return
                                                            }
                                                            if success{
                                                                let credentialOfferData = try! JSONEncoder().encode(self.certDetail?.value?.credentialOffer)
                                                                let credentialOfferJsonString = String(data: credentialOfferData, encoding: .utf8)!
                                                                AriesPoolHelper.shared.pool_prover_create_credential_request(walletHandle: walletHandler, forCredentialOffer: credentialOfferJsonString, credentialDefJSON: credDefJson, proverDID: myDid) {[unowned self] (success, credReqJSON, credReqMetadataJSON, error) in
                                                                    if success {
                                                                        let label = (firstResult?["value"] as? [String: Any])?["their_label"] as? String
                                                                        let their_did = (firstResult?["value"] as? [String: Any])?["their_did"] as? String
                                                                        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: self.walletHandle ?? IndyHandle(), type:AriesAgentFunctions.certType , searchType: .searchWithId,record_id: self.reqId ?? "") {[unowned self] (success, searchHandle, error) in
                                                                            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: self.walletHandle ?? IndyHandle(), searchWalletHandler: searchHandle) {[unowned self] (success, response, error) in
                                                                                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: response)
                                                                                let certRecord = (resultDict?["records"] as? [[String: Any]])?.first
                                                                                let certRecordId = certRecord?["id"] as? String ?? ""
                                                                                var tempCertModel = self.certDetail
                                                                                tempCertModel?.value?.credentialOffer = SearchCertificateCredentialOffer.decode(withDictionary: (UIApplicationUtils.shared.convertToDictionary(text: credentialOfferJsonString) ?? [String:Any]()) as NSDictionary? ?? NSDictionary()) as? SearchCertificateCredentialOffer
                                                                                tempCertModel?.value?.credentialRequestMetadata = SearchCertificateCredentialRequestMetadata.decode(withDictionary: (UIApplicationUtils.shared.convertToDictionary(text:credReqMetadataJSON) ?? [String:Any]()) as NSDictionary? ?? NSDictionary()) as? SearchCertificateCredentialRequestMetadata
                                                                                tempCertModel?.value?.credentialRequest = SearchCertificateCredentialRequest.decode(withDictionary: (UIApplicationUtils.shared.convertToDictionary(text: credReqJSON) ?? [String:Any]()) as NSDictionary? ?? NSDictionary()) as? SearchCertificateCredentialRequest
                                                                                tempCertModel?.value?.credDefJson = CredentialDefModel.decode(withDictionary: (UIApplicationUtils.shared.convertToDictionary(text:credDefJson) ?? [String:Any]()) as NSDictionary? ?? NSDictionary()) as? CredentialDefModel
                                                                                tempCertModel?.value?.state = "request_sent"
                                                                                AriesAgentFunctions.shared.updateWalletRecord(walletHandler: walletHandler, type: .issueCredential, id: certRecordId, certModel: tempCertModel ?? SearchCertificateRecord.init()) {[unowned self] (success,response, error) in
                                                                                    AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler,id: self.reqId ?? "", type: .issueCredential, threadId: self.certDetail?.value?.threadID ?? "", state: "request_sent") { [unowned self](success, error) in
                                                                                        
                                                                                        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type:
                                                                                                                                            AriesAgentFunctions.cloudAgentConnectionInvitation,searchType: .searchWithId, serviceEndPoint: "",record_id: self.reqId ?? "", completion: {[unowned self] (success, searchWalletHandler, error) in
                                                                                                                                                if (success){
                                                                                                                                                    AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: {
                                                                                                                                                        [unowned self]                                                   (fetchedSuccessfully,results,error) in
                                                                                                                                                        if (fetchedSuccessfully){
                                                                                                                                                            let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: results)
                                                                                                                                                            let invitationRecord = (resultsDict?["records"] as? [[String: Any]])?.first
                                                                                                                                                            let serviceEndPoint = (invitationRecord?["value"] as? [String: Any])?["serviceEndpoint"] as? String ?? ""
                                                                                                
                                                                                                                                                            let externalRoutingKey = (invitationRecord?["value"] as? [String: Any])?["routing_key"] as? [String] ?? []
                                                                                                                                                            NetworkManager.shared.baseURL = serviceEndPoint
                                                                                                                                                            AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, label: label ?? "", recipientKey: recipientKey , id: connectionRecordId , myDid: myDid , myVerKey: verKey , serviceEndPoint: "", routingKey: "", deleteItemId: "",threadId: self.certDetail?.value?.threadID ?? "", credReq: credReqJSON, type: .credentialRequest,isRoutingKeyEnabled: externalRoutingKey.count ?? 0 > 0, externalRoutingKey: externalRoutingKey) {[unowned self] (success, packedData, error) in
                                                                                                                                                                NetworkManager.shared.sendMsg(isMediator: false, msgData: packedData ?? Data()) {[unowned self] (statuscode,recievedData) in
                                                                                                                                                                        AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler,id:self.reqId ?? "", type: .issueCredential, threadId: self.certDetail?.value?.threadID ?? "",state: "processed") { [unowned self] (success, error) in
                                                                                                                                                                            SVProgressHUD.dismiss()
//                                                                                                                                                                            NotificationCenter.default.post(Notification.init(name: Constants.didRecieveCertOffer))

                                                                                                                                                                            self.delegate?.popVC()
                                                                                                                                                                            print("Accepted")
                                                                                                                                                                    }
                                                                                                                                                                }
                                                                                                                                                            }
                                                                                                                                                        }
                                                                                                                                                    })
                                                                                                                                                }
                                                                                                                                            })
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        })
                                    }
                                } else {
                                    SVProgressHUD.dismiss()
                                    UIApplicationUtils.showErrorSnackbar(message: "No related organisation found. You may have removed the organisation".localized())
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    func rejectCertificate() {
        let walletHandler = walletHandle ?? IndyHandle()
        SVProgressHUD.show()
        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.certType, id: self.reqId ?? "") {[unowned self]
            (deletedSuccessfully, error) in
            AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, id: self.inboxId ?? "") { [unowned self](deletedSuccessfully, error) in
                print("Cert deleted \(deletedSuccessfully)")
                SVProgressHUD.dismiss()
                self.delegate?.popVC()
            }
        }
    }
    
    func deleteCredentialWith(id:String,walletRecordId: String?){
        let walletHandler = self.walletHandle ?? 0
        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.walletCertificates, id: walletRecordId ?? "") {[unowned self] (success, error) in
            AriesPoolHelper.shared.deleteCredentialFromWallet(withId: id, walletHandle: walletHandler) {[unowned self] (success, error) in
                NotificationCenter.default.post(name: Constants.reloadWallet, object: nil)
                self.delegate?.popVC()
            }
        }
    }
    
}

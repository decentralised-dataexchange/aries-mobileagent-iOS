//
//  ExchangeDataPreviewViewModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 15/12/20.
//

import Foundation
import SVProgressHUD
import UIKit

protocol ExchangeDataPreviewViewModelDelegate: class {
    func goBack()
    func showError(message:String)
    func refresh()
}

class ExchangeDataPreviewViewModel{
    var walletHandle: IndyHandle?
    var reqDetail: SearchPresentationExchangeValueModel?
    var requestedAttributes: [String: ProofCredentialValue] = [String: ProofCredentialValue]()
    var attributelist: [ProofExchangeAttributes] = []
    var isInsufficientData: Bool = false
    weak var delegate:ExchangeDataPreviewViewModelDelegate?
    var QRData: ExchangeDataQRCodeModel?
    var orgName: String?
    var isFromQR: Bool = false
    var inboxId: String?
    var connectionModel: CloudAgentConnectionWalletModel?
    var QR_ID:String?
    
    init(walletHandle: IndyHandle?,reqDetail: SearchPresentationExchangeValueModel?,QRData: ExchangeDataQRCodeModel? = nil,isFromQR: Bool? = false, inboxId: String?,connectionModel: CloudAgentConnectionWalletModel?, QR_ID:String? = "") {
        self.walletHandle = walletHandle
        self.reqDetail = reqDetail
        self.QRData = QRData
        self.isFromQR = isFromQR ?? false
        self.inboxId = inboxId
        self.connectionModel = connectionModel
    }
    
    func getCredsForProof(forceReqDetail: Bool? = false,completion : @escaping(Bool)-> Void) {
        let walletHandler = walletHandle ?? IndyHandle()
        SVProgressHUD.show()
        var attrs = isFromQR ? self.QRData?.proofRequest?.requestedAttributes ?? [:] : self.reqDetail?.value?.presentationRequest?.requestedAttributes ?? [:]
        var presentntReq = isFromQR ? self.QRData?.proofRequest : self.reqDetail?.value?.presentationRequest
        if forceReqDetail ?? false {
            presentntReq = self.reqDetail?.value?.presentationRequest
            attrs = self.reqDetail?.value?.presentationRequest?.requestedAttributes ?? [:]
        }
        
        //getOrgNAme
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithId, record_id: self.reqDetail?.value?.connectionID ?? "") { [unowned self](success, connSearchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: connSearchHandler) { [unowned self](fetched, records, error) in
                let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: records,boolKeys: ["delete"])
                let cloudAgentSearchConnectionModel = CloudAgentSearchConnectionModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? CloudAgentSearchConnectionModel
                self.orgName = cloudAgentSearchConnectionModel?.records?.first?.value?.theirLabel ?? ""
                if self.isFromQR {
                    let value = "\(self.QRData?.invitationURL?.split(separator: "=").last ?? "")".decodeBase64() ?? ""
                    let dataDID = UIApplicationUtils.shared.convertToDictionary(text: value)
                    let label = dataDID?["label"] as? String ?? ""
                    self.orgName = label
                }
                
                ///////////// GetOrgName
                for item in attrs.keys {
                    AriesPoolHelper.shared.pool_prover_search_credentials(forProofRequest: UIApplicationUtils.shared.getJsonString(for: presentntReq.dictionary ?? [String:Any]()), extraQueryJSON: UIApplicationUtils.shared.getJsonString(for: [String:Any]()), walletHandle: walletHandler) {[unowned self] (success, searchHandle, error) in
                        AriesPoolHelper.shared.proverfetchcredentialsforproof_req(forProofReqItemReferent: item, searchHandle: searchHandle ?? IndyHandle(), count: 100) { [unowned self] (success, response, error) in
                            let addKeyRecord = "{\"records\":" + (response ?? "") + "}"
                            let proofReqDict = UIApplicationUtils.shared.convertToDictionary(text: addKeyRecord)
                            let searchProofRequestItemResponse = SearchProofRequestItemResponse.decode(withDictionary: proofReqDict as NSDictionary? ?? NSDictionary()) as? SearchProofRequestItemResponse
                            
                            if searchProofRequestItemResponse?.records?.count ?? 0 == 0 {
                                self.isInsufficientData = true
                            }
                            var credValue = ProofCredentialValue()
                            credValue.credId = searchProofRequestItemResponse?.records?.first?.credInfo?.referent
                            credValue.revealed = true
                            
                            self.requestedAttributes[item] = credValue
                            
                            var attributes = ProofExchangeAttributes()
                            attributes.name = attrs[item]?.name
                            attributes.value = searchProofRequestItemResponse?.records?.first?.credInfo?.attrs?[attributes.name ?? ""] ?? ""
                            if let names = attrs[item]?.names {
                                for name in names{
                                    if let value = searchProofRequestItemResponse?.records?.first?.credInfo?.attrs?[name] {
                                        attributes.name = name
                                        attributes.value = value
                                    }
                                }
                            }
                            
                            attributes.credDefId = searchProofRequestItemResponse?.records?.first?.credInfo?.credDefID
                            attributes.referent = searchProofRequestItemResponse?.records?.first?.credInfo?.referent
                            self.attributelist.append(attributes)
                            if self.attributelist.count == attrs.count {
                                AriesPoolHelper.shared.proverclosecredentialssearchforproofreq(withHandle: searchHandle ?? IndyHandle()) {[unowned self] (success, error) in
                                    completion(true)
                                    SVProgressHUD.dismiss()
                                }
                            }
                        }
                    }
                }
                if attrs.isEmpty{
                    isInsufficientData = true
                    completion(true)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func checkConnection() {
        
        if isInsufficientData {
            UIApplicationUtils.showErrorSnackbar(withTitle:"Error",message: "Insufficient Data")
            return
        }
        if self.isFromQR{
            SVProgressHUD.show()
            
            let walletHandler = walletHandle ?? IndyHandle()
            let value = "\(self.QRData?.invitationURL?.split(separator: "=").last ?? "")".decodeBase64() ?? ""
            let dataDID = UIApplicationUtils.shared.convertToDictionary(text: value)
            let recipientKey = (dataDID?["recipientKeys"] as? [String])?.first ?? ""
            let label = dataDID?["label"] as? String ?? ""
            let serviceEndPoint = dataDID?["serviceEndpoint"] as? String ?? ""
            let routingKey = (dataDID?["routingKeys"] as? [String]) ?? []
            let imageURL = dataDID?["imageUrl"] as? String ?? (dataDID?["image_url"] as? String ?? "")
            
            self.orgName = label
            AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection,searchType: .checkExistingConnection,invitationKey: recipientKey, completion: { [unowned self](success, searchWalletHandler, error) in
                if (success){
                    AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: {[unowned self] (fetchedSuccessfully,results,error) in
                        if (fetchedSuccessfully){
                            let resultDict = UIApplicationUtils.shared.convertToDictionary(text: results,boolKeys: ["delete"])
                            if ((resultDict?["records"] as? [[String:Any]])?.first?["id"] as? String) != nil {
                                let records = resultDict?["records"] as? [[String:Any]]
                                let firstRecord = records?.first
                                let connectionModel = CloudAgentConnectionWalletModel.decode(withDictionary: firstRecord as NSDictionary? ?? NSDictionary()) as? CloudAgentConnectionWalletModel ?? CloudAgentConnectionWalletModel()
                                self.connectionModel = connectionModel
                                AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: connectionModel.value?.myDid ?? "") {[unowned self] (getMetaSuccessfully, metadata, error) in
                                    let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                                    if let my_verKey = metadataDict?["verkey"] as? String{
                                        self.getPresentationRequest(walletHandler: walletHandler, connectionModel: connectionModel, recipientKey: connectionModel.value?.reciepientKey ?? "", myKey: my_verKey, serviceEndPoint: serviceEndPoint)
                                    }
                                }
                                
                            }else{
                                ConnectionPopupViewController.showConnectionPopup(orgName: label, orgImageURL: imageURL, walletHandler: walletHandler, recipientKey: recipientKey, serviceEndPoint: serviceEndPoint, routingKey: routingKey,isFromDataExchange: true) {[unowned self] (connectionModel,recipientKey,myVerKey) in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        SVProgressHUD.show()
                                        guard let connectionModel = connectionModel, let recipientKey = recipientKey, let myVerKey = myVerKey else{
                                            SVProgressHUD.dismiss()
                                            UIApplicationUtils.showErrorSnackbar(message: "Something went wrong".localized())
                                            return
                                        }
                                        self.connectionModel = connectionModel
                                        self.getPresentationRequest(walletHandler: walletHandler, connectionModel: connectionModel, recipientKey: recipientKey, myKey: myVerKey,serviceEndPoint:serviceEndPoint)
                                    }
                                }
                            }
                        }
                    })
                }
            })
        } else {
            self.acceptCertificate()
        }
        
    }
    
    func getPresentationRequest(walletHandler: IndyHandle,connectionModel:CloudAgentConnectionWalletModel, recipientKey: String, myKey: String,serviceEndPoint:String ){
        SVProgressHUD.show()
        var attr = ProofExchangeAttributesArray()
        attr.items = attributelist
        AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: recipientKey, myVerKey: myKey, attributes: attr, type: .proposePresentation,isRoutingKeyEnabled: connectionModel.value?.routingKey?.count ?? 0 > 0,externalRoutingKey: connectionModel.value?.routingKey ?? [],QR_ID: self.QR_ID) {[unowned self] (success, data, error) in
            NetworkManager.shared.baseURL = serviceEndPoint
            NetworkManager.shared.sendMsg(isMediator: false, msgData: data ?? Data()) { [unowned self](statuscode,responseData) in
                
                AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: responseData ?? Data()) { [unowned self](unpackSuccess, unpackedData, error) in
                    if let recievedData = unpackedData {
                        if let messageModel = try? JSONSerialization.jsonObject(with: recievedData , options: []) as? [String : Any] {
                            print("unpackmsg -- \(messageModel)")
                            let msgString = (messageModel)["message"] as? String
                            let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "")
                            let recipient_verkey = (messageModel)["recipient_verkey"] as? String ?? ""
                            let sender_verkey = (messageModel)["sender_verkey"] as? String ?? ""
                            print("Presentation request recieved")
                            let requestPresentationMessageModel = RequestPresentationMessageModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? RequestPresentationMessageModel
                            self.requestPresentationRecieved(requestPresentationMessageModel:requestPresentationMessageModel,myVerKey: recipient_verkey,recipientKey: sender_verkey)
                        }
                        
                    } else {
                        UIApplicationUtils.showErrorSnackbar(message: "Something went wrong".localized())
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    func acceptCertificate() {
        let walletHandler = walletHandle ?? IndyHandle()
        var schemaParsedList: [String] = []
        var credParsedList: [String] = []
        var completedLoopCount = 0
        SVProgressHUD.show()
        for item in self.requestedAttributes {
            AriesPoolHelper.shared.pool_setProtocol(version: 2) {[unowned self] (success, error) in
                //                AriesAgentConnectionHelper.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentConnectionHelper.cloudAgentConnection,searchType: .withoutQuery,recipientKey: "", serviceEndPoint: "", completion: { (success, searchWalletHandler, error) in
                //                    if (success){
                //                        AriesAgentConnectionHelper.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: { (fetchedSuccessfully,results,error) in
                //                            if (fetchedSuccessfully){
                //                                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: results)
                //                                let firstResult = (resultDict?["records"] as? [[String: Any]])?.first
                //                                if let connectionRecordId = (resultDict?["records"] as? [[String:Any]])?.first?["id"] as? String {
                //                                    if let myDid = (firstResult?["value"] as? [String: Any])?["my_did"] as? String, let recipientKey = (firstResult?["value"] as? [String: Any])?["invitation_key"] as? String {
                //                                        AriesAgentConnectionHelper.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: myDid, completion: { (metadataRecieved,metadata, error) in
                //                                            let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                //                                            if let verKey = metadataDict?["verkey"] as? String{
                AriesPoolHelper.shared.pool_prover_get_credentials(id: item.value.credId ?? "", walletHandle: walletHandler) {[unowned self] (success, credentialJSON, error) in
                    let credentialDict = UIApplicationUtils.shared.convertToDictionary(text: credentialJSON)
                    let credentialInfo = SearchProofReqCredInfo.decode(withDictionary: credentialDict as NSDictionary? ?? NSDictionary()) as? SearchProofReqCredInfo
                    AriesPoolHelper.shared.buildGetSchemaRequest(id: credentialInfo?.schemaID ?? "") { [unowned self](success, getSchemaReqResponse, error) in
                        AriesPoolHelper.shared.submitRequest(poolHandle: AriesPoolHelper.poolHandler, requestJSON: getSchemaReqResponse) { [unowned self](success, submitResponse, error) in
                            AriesPoolHelper.shared.buildGetSchemaResponse(getSchemaResponse: submitResponse) { [unowned self](success, defId, defJson, error) in
                                if (!schemaParsedList.contains(defJson)){
                                    schemaParsedList.append(defJson)
                                }
                                AriesPoolHelper.shared.buildGetCredDefRequest(id: credentialInfo?.credDefID ?? "") { [unowned self](success, credReqResponse, error) in
                                    AriesPoolHelper.shared.submitRequest(poolHandle: AriesPoolHelper.poolHandler, requestJSON: credReqResponse) { [unowned self](success, credDefResponse, error) in
                                        AriesPoolHelper.shared.parseGetCredDefResponse(response: credDefResponse) { [unowned self](success, credId, credresJson, error) in
                                            if error?.localizedDescription.contains("309") ?? false {
                                                SVProgressHUD.dismiss()
                                                UIApplicationUtils.showErrorSnackbar(message: "Invalid Ledger. You can choose proper ledger from settings".localized())
                                                return
                                            }
                                            if (!credParsedList.contains(credresJson)){
                                                credParsedList.append(credresJson)
                                                if completedLoopCount == self.requestedAttributes.count - 1{
                                                    self.createPool(schemaList: schemaParsedList, credList: credParsedList)
                                                } else {
                                                    completedLoopCount += 1
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //                                            }
                    //                                        })
                    //                                    }
                    //                                }
                    //                            }
                    //                        })
                    //                    }
                    //                })
                }
            }
        }
    }
    
    func createPool(schemaList:[String], credList: [String]) {
        let walletHandler = walletHandle ?? IndyHandle()
        
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let masterSecretID = "iGrantMobileAgent-\(deviceID)"
        
        var schemasJson = [String:Any]()
        for item in schemaList{
            let tempDict =  UIApplicationUtils.shared.convertToDictionary(text: item)
            let schemaID = tempDict?["id"] as? String ?? ""
            
            schemasJson[schemaID] = UIApplicationUtils.shared.convertToDictionary(text: item)
        }
        
        var credJson = [String:Any]()
        for item in credList{
            let tempDict =  UIApplicationUtils.shared.convertToDictionary(text: item)
            let credID = tempDict?["id"] as? String ?? ""
            credJson[credID] = UIApplicationUtils.shared.convertToDictionary(text: item)
        }
        
        let RequestedCredentialsJSON = ["self_attested_attributes": [String : Any](),
                                        "requested_attributes":  requestedAttributes.dictionary ?? [String:Any](),
                                        "requested_predicates": [String : Any]()] as [String : Any]
        
        AriesPoolHelper.shared.createProof(
            forRequest: UIApplicationUtils.shared.getJsonString(for: self.reqDetail?.value?.presentationRequest?.dictionary ?? [String:Any]()) ,
            requestedCredentialsJSON: UIApplicationUtils.shared.getJsonString(for: RequestedCredentialsJSON),
            masterSecretID: masterSecretID,
            schemasJSON: UIApplicationUtils.shared.getJsonString(for: schemasJson),
            credentialDefsJSON: UIApplicationUtils.shared.getJsonString(for: credJson),
            revocStatesJSON: UIApplicationUtils.shared.getJsonString(for:[String:Any]()),
            walletHandle: walletHandler) {[unowned self] (success,proofJson, error) in
            var updateReq = self.reqDetail
            let proofDict = UIApplicationUtils.shared.convertToDictionary(text: proofJson)
            let presentation = PRPresentation.decode(withDictionary: proofDict as NSDictionary? ?? NSDictionary()) as? PRPresentation
            print("Presentation --- \(presentation)")
            updateReq?.value?.presentation = presentation
            updateReq?.value?.state = "presentation_sent"
            AriesAgentFunctions.shared.updateWalletRecord(walletHandler: walletHandler, type: .credentialExchange, id: self.reqDetail?.id ?? "",presentationReqModel:updateReq?.value) {[unowned self] (success, id, error) in
                AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler, id: self.reqDetail?.id ?? "", type: .credentialExchange,threadId: updateReq?.value?.threadID ?? "" ,state:updateReq?.value?.state ?? "") {[unowned self] (success, error) in
                    AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: self.connectionModel?.value?.myDid ?? "") { [unowned self](getMetaSuccessfully, metadata, error) in
                        let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                        print("Thread id --- \(self.reqDetail?.value?.threadID ?? "")" )
                        if let my_verKey = metadataDict?["verkey"] as? String{
                            AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: self.connectionModel?.value?.reciepientKey ?? "", myVerKey: my_verKey, threadId: self.reqDetail?.value?.threadID ?? "" , type: .presentation, isRoutingKeyEnabled: self.connectionModel?.value?.routingKey?.count ?? 0 > 0, externalRoutingKey : self.connectionModel?.value?.routingKey ?? [], presentation: updateReq?.value?.presentation) {[unowned self] (success, packedData, error) in
                                AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnectionInvitation, searchType: .searchWithId,record_id: self.connectionModel?.value?.requestID ?? "") { [unowned self](success, searchHandler, error) in
                                    AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (searchSuccess, records, error) in
                                        let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: records)
                                        let invitationRecord = (resultsDict?["records"] as? [[String: Any]])?.first
                                        let serviceEndPoint = (invitationRecord?["value"] as? [String: Any])?["serviceEndpoint"] as? String ?? ""
                                        _ = (invitationRecord?["value"] as? [String: Any])?["routing_key"] as? String ?? ""
                                        NetworkManager.shared.baseURL = serviceEndPoint
                                        NetworkManager.shared.sendMsg(isMediator: false, msgData: packedData ?? Data()) {[unowned self](statuscode,responseData) in
                                            
                                            //                                                                    AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: responseData ?? Data()) { (unpackSuccess, unpackedData, error) in
                                            //                                                                        if unpackSuccess {
                                            self.deleteWalletRecord()
                                            UIApplicationUtils.showSuccessSnackbar(message: "Data shared successfully".localized())
                                            
                                            //                                                                        }
                                            //                                                                    }
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
    
    func deleteWalletRecord() {
        let walletHandler = walletHandle ?? IndyHandle()
        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.presentationExchange, id: reqDetail?.id ?? "") { [unowned self](success, error) in
            AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, id: self.inboxId ?? "") {[unowned self] (deletedSuccessfully, error) in
                SVProgressHUD.dismiss()
                if deletedSuccessfully {
                    self.delegate?.goBack()
                } else {
                    if self.isFromQR{
                        self.delegate?.goBack()
                        return
                    }
                    self.delegate?.showError(message: "Failed to delete request from wallet record.".localized())
                }
            }
        }
    }
    
    func rejectCertificate() {
        self.deleteWalletRecord()
    }
    
}

//MARK: request-presentation
extension ExchangeDataPreviewViewModel {
    
    func requestPresentationRecieved(requestPresentationMessageModel: RequestPresentationMessageModel?,myVerKey: String,recipientKey: String) {
        let walletHandler = self.walletHandle ?? 0
        let base64String = requestPresentationMessageModel?.requestPresentationsAttach?.first?.data?.base64?.decodeBase64() ?? ""
        let base64DataDict = UIApplicationUtils.shared.convertToDictionary(text: base64String)
        let presentationRequestModel = PresentationRequestModel.decode(withDictionary: base64DataDict as NSDictionary? ?? NSDictionary()) as? PresentationRequestModel
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithReciepientKey,reciepientKey: recipientKey) {[unowned self] (success, searchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, record, error) in
                let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: record,boolKeys: ["delete"])
                let cloudAgentSearchConnectionModel = CloudAgentSearchConnectionModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? CloudAgentSearchConnectionModel
                if cloudAgentSearchConnectionModel?.totalCount ?? 0 > 0 {
                    //                    AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.presentationExchange,searchType:.searchWithThreadId, threadId: requestPresentationMessageModel?.id ?? "") { (success, prsntnExchngSearchWallet, error) in
                    //                        AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: prsntnExchngSearchWallet) { (success, response, error) in
                    //                            let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: response)
                    //                            if (recordResponse?["totalCount"] as? Int ?? 0) > 0 {
                    //                                return
                    //                            }
                    //                            let searchPresentationExchangeModel = SearchPresentationExchangeModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? SearchPresentationExchangeModel
                    print("Req Thread id --- \(requestPresentationMessageModel?.thread?.thid ?? "")" )
                    let connectionModel = cloudAgentSearchConnectionModel?.records?.first
                    var  presentationExchangeWalletModel = PresentationRequestWalletRecordModel.init()
                    presentationExchangeWalletModel.threadID = requestPresentationMessageModel?.thread?.thid ?? ""
                    presentationExchangeWalletModel.connectionID = connectionModel?.value?.requestID
                    presentationExchangeWalletModel.createdAt = AgentWrapper.shared.getCurrentDateTime()
                    presentationExchangeWalletModel.updatedAt = AgentWrapper.shared.getCurrentDateTime()
                    presentationExchangeWalletModel.initiator = "external"
                    presentationExchangeWalletModel.presentationRequest = presentationRequestModel
                    presentationExchangeWalletModel.role = "prover"
                    presentationExchangeWalletModel.state = "request_received"
                    presentationExchangeWalletModel.autoPresent = true
                    presentationExchangeWalletModel.trace = false
                    self.reqDetail = SearchPresentationExchangeValueModel()
                    self.reqDetail?.id = requestPresentationMessageModel?.id
                    self.reqDetail?.type = requestPresentationMessageModel?.type
                    self.reqDetail?.value = presentationExchangeWalletModel
                    self.attributelist.removeAll()
                    self.requestedAttributes.removeAll()
                    self.getCredsForProof(forceReqDetail: true) {[unowned self] (success) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            SVProgressHUD.show()
                        }
                        self.acceptCertificate()
                    }
                }
            }
        }
    }
    //        }
    //    }
}

struct ProofCredentialValue:Codable {
    var credId: String?
    var revealed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case credId = "cred_id"
        case revealed
    }
}

struct ProofExchangeAttributes: Codable {
    var name: String?
    var names: [String]?
    var value:String?
    var credDefId: String?
    var referent: String?
    
    enum CodingKeys: String, CodingKey {
        case credDefId = "cred_def_id"
        case value
        case referent
        case name
    }
}

struct ProofExchangeAttributesArray: Codable {
    var items: [ProofExchangeAttributes]?
}

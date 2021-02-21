//
//  WalletViewModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 21/11/20.
//

import Foundation
import SVProgressHUD

protocol WalletDelegate: class {
    func walletDataUpdated()
}

class WalletViewModel{
    static var mediatorVerKey: String?
    var walletHandle: IndyHandle? {
        didSet {
            WalletViewModel.openedWalletHandler = walletHandle
        }
    }
    static var openedWalletHandler: IndyHandle?
    var invitation: AgentConfigurationResponse?
    var myDid: String?
    var myVerKey: String?
    var mediatorDid: String?
    var connectionHelper = AriesAgentFunctions.shared
    var pollingTimer: Timer?
    weak var delegate: WalletDelegate?
    var certificates:[SearchItems_CustomWalletRecordCertModel] = []
    var searchCert: [SearchItems_CustomWalletRecordCertModel] = []
    var pollingInterval = 5
    
    func getSavedCertificates() {
        let walletHandler = self.walletHandle ?? 0
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.walletCertificates, searchType: .withoutQuery) {[unowned self] (success, searchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) { [unowned self](fetched, response, error) in
                let responseDict = UIApplicationUtils.shared.convertToDictionary(text: response)
                let certSearchModel = Search_CustomWalletRecordCertModel.decode(withDictionary: responseDict as NSDictionary? ?? NSDictionary()) as? Search_CustomWalletRecordCertModel
                self.certificates = certSearchModel?.records ?? []
                self.searchCert = certSearchModel?.records ?? []
                self.delegate?.walletDataUpdated()
                print("wallet credentials fetched")
            }
        }
//        AriesPoolHelper.shared.getCredentialsFromWallet(walletHandler: walletHandler) { (success, records, error) in
//            let addKeyRecord = "{\"records\":" + records + "}"
//            let credentialDict = UIApplicationUtils.shared.convertToDictionary(text: addKeyRecord)
//            let credentialAttachModel = WalletCredentialModelArray.decode(withDictionary: credentialDict as NSDictionary? ?? NSDictionary()) as? WalletCredentialModelArray
//            self.certificates = credentialAttachModel?.records ?? []
//            self.searchCert = credentialAttachModel?.records ?? []
//            self.delegate?.walletDataUpdated()
//            print("wallet credentials fetched")
//        }
    }
    
    func updateSearchedItems(searchString: String){
        if searchString == "" {
            self.searchCert = certificates
            delegate?.walletDataUpdated()
            return
        }
        let filteredArray = self.certificates.filter({ (item) -> Bool in
            let schemeSeperated = item.value?.schemaID?.split(separator: ":")
            let name = "\(schemeSeperated?[2] ?? "")"
            return (name.contains(searchString))
        })
        self.searchCert = filteredArray
        delegate?.walletDataUpdated()
        return
    }
    
    func setupNewConnectionToMediator() {
        NetworkManager.shared.getAgentConfig { [unowned self](response) in
            self.invitation = response
            self.newConnectionConfigMediator(label: response?.invitation?.label ?? "", theirVerKey: response?.invitation?.recipientKeys?.first ?? "", serviceEndPoint: response?.serviceEndpoint ?? "", routingKey: response?.routingKey ?? "")
        }
    }
    
    func fetchNotifications(completion: @escaping (Bool) -> Void) {
        let walletHandler = self.walletHandle ?? IndyHandle()
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, searchType:.withoutQuery) { [unowned self](success, prsntnExchngSearchWallet, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: prsntnExchngSearchWallet, count: 100) { [unowned self](success, response, error) in
                let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: response,boolKeys: ["auto_present","trace","auto_offer","auto_issue"])
                let searchInboxModel = SearchInboxModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? SearchInboxModel
                if (searchInboxModel?.records) != nil {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }
    
    func newConnectionConfigMediator(label: String, theirVerKey: String,serviceEndPoint: String, routingKey: String){
        let walletHandler = self.walletHandle ?? 0

        self.connectionHelper.addWalletRecord(invitationKey: theirVerKey, label: label, serviceEndPoint: serviceEndPoint, connectionRecordId: "", walletHandler: walletHandler,type: .mediatorConnection , completion: { [unowned self](addRecord_Connection_Completed, connectionRecordId, error) in
            if addRecord_Connection_Completed{
                self.connectionHelper.addWalletRecord(invitationKey: theirVerKey, label: label, serviceEndPoint: serviceEndPoint,connectionRecordId: connectionRecordId, walletHandler: walletHandler,type: ( .mediatorInvitation)) { [unowned self](addWalletRecord_ConnectionInvitation_Completed, connectionInvitationRecordId, error) in
                    if (addWalletRecord_ConnectionInvitation_Completed){
                        self.connectionHelper.getWallerRecord(walletHandler: walletHandler,connectionRecordId: connectionRecordId, isMediator: true, completion: {[unowned self] (getWalletRecordSuccessfully, error) in
                            if getWalletRecordSuccessfully {
                                self.connectionHelper.createAndStoreId(walletHandler: walletHandler) {[unowned self] (createDidSuccess, myDid, verKey,error) in
                                    self.mediatorDid = myDid
                                    WalletViewModel.mediatorVerKey = verKey
                                    self.connectionHelper.setMetadata(walletHandler: walletHandler, myDid: myDid ?? "",verKey:verKey ?? "", completion: {[unowned self] (metaAdded) in
                                        if(metaAdded){
                                            self.connectionHelper.updateWalletRecord(walletHandler: walletHandler,recipientKey: theirVerKey,label: label, type: UpdateWalletType.initial, id: connectionRecordId, theirDid: "", myDid: myDid ?? "",
                                                                                     invitiationKey: theirVerKey,completion: {[unowned self] (updateWalletRecordSuccess,updateWalletRecordId ,error) in
                                        if(updateWalletRecordSuccess){
                                            self.connectionHelper.updateWalletTags(walletHandler: walletHandler, id: connectionRecordId, myDid: myDid ?? "", theirDid: "",recipientKey: "", serviceEndPoint: "",type: .initial, completion: {[unowned self] (updateWalletTagSuccess, error) in
                                                if(updateWalletTagSuccess){
                                                    self.getRecordAndConnectForMediator(connectionRecordId: connectionRecordId, verKey: verKey ?? "", myDid: myDid ?? "", recipientKey: theirVerKey, label: label,packageMsgType: .initialMediator,routingKey: "",serviceEndPoint: serviceEndPoint, isRoutingKeyEnabled: false)
                                                }
                                            })
                                        }
                                    })
                                }
                                    })
                                }
                                }
                        })
                    }
                }
            }
        })
    }
    
   
    
func checkMediatorConnectionAvailable() {
        let walletHandler = self.walletHandle ?? 0
    connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.mediatorConnection,searchType: .withoutQuery, completion: {[unowned self] (success, searchWalletHandler, error) in
            if (success){
                self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: {[unowned self] (fetchedSuccessfully,results,error) in
                    if (fetchedSuccessfully){
                        let resultDict = UIApplicationUtils.shared.convertToDictionary(text: results)
                        let firstResult = (resultDict?["records"] as? [[String: Any]])?.first
                        if let connectionRecordId = (resultDict?["records"] as? [[String:Any]])?.first?["id"] as? String {
                            if let myDid = (firstResult?["value"] as? [String: Any])?["my_did"] as? String, let recipientKey = (firstResult?["value"] as? [String: Any])?["reciepientKey"] as? String {
                                self.mediatorDid = myDid
                                self.connectionHelper.getMyDidWithMeta(walletHandler: walletHandler, myDid: myDid, completion: {[unowned self] (metadataRecieved,metadata, error) in
                                    let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                                    if let verKey = metadataDict?["verkey"] as? String{
                                        WalletViewModel.mediatorVerKey = verKey
                                        self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.mediatorConnectionInvitation, searchType: .withoutQuery, serviceEndPoint: "", completion: {[unowned self] (invitationRecordFetchSuccess, invitationRecordSearchWalletHandler, error) in
                                            if (invitationRecordFetchSuccess){
                                                self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: invitationRecordSearchWalletHandler, completion: {[unowned self] (fetchedInvitationRecordSuccessfully,results,error) in
                                                    let recordData =  UIApplicationUtils.shared.convertToDictionary(text: results)
                                                    let records = recordData?["records"] as? [[String:Any?]]
                                                    let values = records?.first?["value"] as? [String:Any?]
                                                    let label = values?["label"] as? String ?? ""
                                                    
                                                    if let state = (firstResult?["value"] as? [String: Any])?["state"] as? String, let theirDid =  (firstResult?["value"] as? [String: Any])?["their_did"] as? String {
                                                        if state == "response"{
                                                            self.createInbox(connectionRecordId: connectionRecordId, verKey: verKey, myDid: myDid , recipientKey: recipientKey,theirDid: theirDid, label: label,invitationKey: recipientKey)
                                                            return
                                                        } else if state == "active"{
                                                            print("active mediator connection found")
                                                            self.pollingMediator(connectionRecordId: connectionRecordId, verKey: verKey, myDid: myDid , recipientKey: recipientKey, label: label,packageMsgType: .initialMediator, routingKey: "",serviceEndPoint: "")
                                                            return
                                                        }
                                                    }
                                                    
                                                    self.getRecordAndConnectForMediator(connectionRecordId: connectionRecordId, verKey: verKey, myDid: myDid , recipientKey: recipientKey, label: label,packageMsgType: .initialMediator, routingKey: "",serviceEndPoint: "", isRoutingKeyEnabled: false)
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        } else {
                            self.setupNewConnectionToMediator()
                        }
                    }
                })
            } else {
                self.setupNewConnectionToMediator()
            }
        })
    }

    func getRecordAndConnectForMediator(connectionRecordId: String,verKey: String, myDid: String, recipientKey: String, label: String, packageMsgType: PackMessageType, routingKey: String, serviceEndPoint: String,isRoutingKeyEnabled: Bool){
    let walletHandler = self.walletHandle ?? 0
    
        self.connectionHelper.getWallerRecord(walletHandler: walletHandler,connectionRecordId: connectionRecordId, isMediator: true, completion: {[unowned self] (getWallerRecord2Success, error) in
        if (getWallerRecord2Success){
            self.connectionHelper.packMessage(walletHandler: walletHandler,label: label, recipientKey: recipientKey,  id: connectionRecordId, myDid: myDid , myVerKey: verKey ,serviceEndPoint: serviceEndPoint, routingKey: routingKey, deleteItemId: "", type: packageMsgType, isRoutingKeyEnabled: false, completion:{[unowned self] (packMsgSuccess, messageData, error) in
                if (packMsgSuccess){
                    NetworkManager.shared.sendMsg(isMediator:true ,msgData: messageData ?? Data()) {[unowned self] (statuscode,recievedData) in
                       
                        self.connectionHelper.unpackMessage(walletHandler: walletHandler, messageData: recievedData ?? Data() , completion: { [unowned self](unpackMsgSuccess, unpackedMsgData, error) in
                            if let messageModel = try? JSONSerialization.jsonObject(with: unpackedMsgData ?? Data(), options: []) as? [String : Any] {
                                
                                print("unpackmsg -- \(messageModel)")
                                let msgString = (messageModel)["message"] as? String
                                let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "")
                                //connection~sig
                                let connSigDict = (msgDict)?["connection~sig"] as? [String:Any]
                                
                                let sigDataBase64String = (connSigDict)?["sig_data"] as? String
                                let sigDataString = sigDataBase64String?.decodeBase64_first8bitRemoved()
                                let sigDataDict = UIApplicationUtils.shared.convertToDictionary(text: sigDataString ?? "")
                                let theirDid = sigDataDict?["DID"] as? String ?? ""
                                let dataDic = ((sigDataDict?["DIDDoc"] as? [String:Any])?["service"] as? [[String:Any]])?.first
                                let senderVerKey = (dataDic?["recipientKeys"] as? [String])?.first ?? ""
                                let serviceEndPoint = (dataDic?["serviceEndpoint"] as? String) ?? ""
                                let routingKey = (dataDic?["routingKeys"] as? [String])?.first ?? ""
                                NetworkManager.shared.baseURL = serviceEndPoint
                                self.connectionHelper.addWalletRecord_DidDoc(walletHandler: walletHandler, invitationKey: recipientKey, theirDid: theirDid , recipientKey: senderVerKey , serviceEndPoint: serviceEndPoint,routingKey: routingKey, isMediator: true, completion: { [unowned self](didDocRecordAdded, didDocRecordId, error) in
                                    if (didDocRecordAdded){
                                        self.connectionHelper.addWalletRecord_DidKey(walletHandler: walletHandler, theirDid: theirDid, recipientKey: senderVerKey, isMediator: true, completion: { [unowned self](didKeyRecordAdded, didKeyRecordId, error) in
                                            self.connectionHelper.updateWalletRecord(walletHandler: walletHandler,recipientKey: senderVerKey,label: label, type: .updateTheirDid, id: connectionRecordId, theirDid: theirDid, myDid: myDid ,invitiationKey: recipientKey, completion: {[unowned self] (updatedSuccessfully, updatedRecordId, error) in
                                                if(updatedSuccessfully){
                                                    self.connectionHelper.updateWalletTags(walletHandler: walletHandler, id: connectionRecordId, myDid: myDid , theirDid: theirDid, recipientKey: senderVerKey, serviceEndPoint: "", invitiationKey: recipientKey, type: .updateTheirDid, completion: { [unowned self](updatedSuccessfully, error) in
                                                        if (updatedSuccessfully){
                                                            if packageMsgType == .initialMediator {
                                                                self.createInbox(connectionRecordId: connectionRecordId, verKey: verKey, myDid: myDid , recipientKey: senderVerKey,theirDid: theirDid, label: label,invitationKey: recipientKey)
                                                            }
                                                        }
                                                    })
                                                }
                                            })
                                        })
                                    }
                                })
                            }
                        })
                    }
                }
            })
        }
    })
}
    

    
    
    func createInbox(connectionRecordId: String,verKey: String, myDid: String, recipientKey: String, theirDid: String, label: String, invitationKey: String) {
        let walletHandler = self.walletHandle ?? 0
        self.connectionHelper.packMessage(walletHandler: walletHandler, label: label, recipientKey: recipientKey, id: connectionRecordId, myDid: myDid, myVerKey: verKey, serviceEndPoint: "", routingKey: "", deleteItemId: "", type: .createInbox,isRoutingKeyEnabled: false) { [unowned self](packedSuccessfully, packedData, error) in
            if (packedSuccessfully){
                NetworkManager.shared.sendMsg(isMediator: true, msgData: packedData ?? Data()) {[unowned self] (statuscode,recievedData) in
                   
                    self.connectionHelper.updateWalletRecord(walletHandler: walletHandler,recipientKey: recipientKey,label: label, type: .inboxCreated, id: connectionRecordId, theirDid: theirDid, myDid: myDid ,invitiationKey: invitationKey, completion: {[unowned self] (updatedSuccessfully, updatedRecordId, error) in
                        if(updatedSuccessfully){
                            self.connectionHelper.updateWalletTags(walletHandler: walletHandler, id: connectionRecordId, myDid: myDid, theirDid: theirDid, recipientKey: recipientKey, serviceEndPoint: "", invitiationKey: invitationKey, type: .mediatorActive) {[unowned self] (tagUpdated, error) in
                                if (tagUpdated){
                                    self.pollingMediator(connectionRecordId: connectionRecordId, verKey: verKey, myDid: myDid, recipientKey: recipientKey, label: label, packageMsgType: .pollingMediator, routingKey: "", serviceEndPoint: "")
                                }
                                }
                            }
                })
                }
            }
        }
    }

    func pollingMediator(connectionRecordId: String,verKey: String, myDid: String, recipientKey: String, label: String, packageMsgType: PackMessageType, routingKey: String, serviceEndPoint: String) {
        let walletHandler = self.walletHandle ?? 0
        self.connectionHelper.packMessage(walletHandler: walletHandler, label: label, recipientKey: recipientKey, id:connectionRecordId , myDid: myDid, myVerKey: verKey, serviceEndPoint: serviceEndPoint, routingKey: routingKey, deleteItemId: "", type: .pollingMediator, isRoutingKeyEnabled: false, completion: { [unowned self] (packedSuccessfully, packedData, error) in
            if (packedSuccessfully){
                self.pollingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.pollingInterval), repeats: true, block: { [unowned self](timer) in
                    NetworkManager.shared.polling(msgData: packedData ?? Data()) {[unowned self] (statuscode,recievedData) in
                        //                        print("polling......")
                        if recievedData != nil {
                            self.connectionHelper.unpackMessage(walletHandler: walletHandler, messageData: recievedData ?? Data(), completion: { [unowned self](unpackedSuccessfully, unpackedData, error) in
                                if let messageModel = try? JSONSerialization.jsonObject(with: unpackedData ?? Data(), options: []) as? [String : Any] {
                                    let messageString = messageModel["message"] as? String
                                    let msgDict = UIApplicationUtils.shared.convertToDictionary(text: messageString ?? "")
                                    let items = msgDict?["Items"] as? [[String: Any]] ?? []
                                    if items.count > 0 {
                                        print("items -- \(items.count)")
                                        let itemDict = items.first ?? [String : Any]()
                                        let dataDict = itemDict["Data"] as? [String : Any]
                                        if let data = try? JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted) {
                                            self.connectionHelper.unpackMessage(walletHandler: walletHandler, messageData: data, completion: { [unowned self](unpackMsgSuccess, unpackedMsgData, error) in
                                                if let messageModel = try? JSONSerialization.jsonObject(with: unpackedMsgData ?? Data(), options: []) as? [String : Any] {
                                                    print("unpackmsg -- \(messageModel)")
                                                    let msgString = (messageModel)["message"] as? String
                                                    let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "")
                                                    //connection~sig
                                                    let itemType = (msgDict?["@type"] as? String)?.split(separator: "/").last ?? ""
                                                    let connSigDict = (msgDict)?["connection~sig"] as? [String:Any]
                                                    
                                                    let sigDataBase64String = (connSigDict)?["sig_data"] as? String
                                                    let sigDataString = sigDataBase64String?.decodeBase64_first8bitRemoved()
                                                    let sigDataDict = UIApplicationUtils.shared.convertToDictionary(text: sigDataString ?? "") ?? [String:Any]()
                                                    let itemId = itemDict["@id"] as? String ?? ""
                                                    let recipient_verkey = (messageModel)["recipient_verkey"] as? String ?? ""
                                                    let sender_verkey = (messageModel)["sender_verkey"] as? String ?? ""
                                                    print("itemType -- \((itemType,itemId))")
                                                    
                                                    //                                                    delete Item
                                                    self.connectionHelper.packMessage(walletHandler: walletHandler, label: label, recipientKey: recipientKey, id: connectionRecordId, myDid: myDid, myVerKey: verKey, serviceEndPoint: serviceEndPoint, routingKey: routingKey, deleteItemId: itemId, type: .deleteInboxItem, isRoutingKeyEnabled: false) {[unowned self] (packedSuccessfully, packedData, error) in
                                                        if(packedSuccessfully) {
                                                            NetworkManager.shared.sendMsg(isMediator: true, msgData: packedData ?? Data()) { [unowned self](statuscode,deleteResponse) in
                                                               
                                                                print("Item deleted")
                                                                switch itemType {
                                                                    case "response":
                                                                        AriesCloudAgentHelper.shared.addWalletRecord_CloudAgent(walletHandle: self.walletHandle, connectionRecordId: connectionRecordId,verKey: recipient_verkey, recipientKey: sender_verkey,  packageMsgType: .initialCloudAgent, sigDataDict:sigDataDict as [String : Any])
                                                                    case "ping_response":
                                                                        AriesCloudAgentHelper.shared.pingResponseHandler(walletHandle: self.walletHandle, verKey: recipient_verkey, recipientKey: sender_verkey)
                                                                        
                                                                    case "offer-credential":
                                                                        print("Offer-Cert Recieved")
                                                                        let docModel = CertificateIssueModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? CertificateIssueModel
                                                                        self.certificateOfferRecieved(verKey: recipient_verkey, recipientKey: sender_verkey, certIssueModel: docModel!)
                                                                    case "issue-credential":
                                                                        print("Issue Credential")
                                                                        let issueCredentialModel = IssueCredentialMesage.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? IssueCredentialMesage
                                                                        let threadID = (msgDict?["~thread"] as? [String:Any])?["thid"] as? String ?? ""
                                                                        self.issueCredential(model: issueCredentialModel,myVerKey: recipient_verkey,recipientKey: sender_verkey,threadId: threadID)
                                                                    case "request-presentation":
                                                                        print("Presentation request recieved")
                                                                        let requestPresentationMessageModel = RequestPresentationMessageModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? RequestPresentationMessageModel
                                                                        self.requestPresentationRecieved(requestPresentationMessageModel:requestPresentationMessageModel,myVerKey: recipient_verkey,recipientKey: sender_verkey)
                                                                        
                                                                    default:
                                                                        break
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                            })
                                            
                                        }
                                        
                                    }
                                }
                            })
                        }
                    }
                })
                self.pollingTimer?.fire()
            }
        })
    }
    
}

extension WalletViewModel {
    
    func certificateOfferRecieved(verKey: String, recipientKey: String, certIssueModel: CertificateIssueModel){
        let walletHandler = self.walletHandle ?? 0
        self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.certType, searchType: .searchWithThreadId, threadId: certIssueModel.id ?? "") { (Success, searchHandler, error) in
            self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, result, error) in
                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: result)
                let count = resultDict?["totalCount"] as? Int ?? 0
                if (count > 0) {
                    print("Cert Already added to wallet")
                    return
                }
                self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithMyVerKey, myVerKey: verKey) { [unowned self](Success, searchHandler, error) in
                    self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, result, error) in
                        let resultDict = UIApplicationUtils.shared.convertToDictionary(text: result,boolKeys: ["delete"])
                        let requestArray = resultDict?["records"] as? [[String:Any]] ?? []
                        let requestDict = requestArray.first?["value"] as? [String:Any]
                        let request_id = requestDict?["request_id"] as? String ?? ""
                        let firstRecord = requestArray.first
                        let connectionModel = CloudAgentConnectionWalletModel.decode(withDictionary: firstRecord as NSDictionary? ?? NSDictionary()) as? CloudAgentConnectionWalletModel
                        self.connectionHelper.addWalletRecord(threadID: certIssueModel.id ?? "", connectionRecordId: request_id, certIssueModel: certIssueModel, walletHandler: walletHandler, type: .offerCredential) {[unowned self] (Added, recordId, error) in
                            print("cert offer record saved")
                            self.connectionHelper.addWalletRecord(threadID: certIssueModel.id ?? "",connectionRecordId: request_id,certIssueModel: certIssueModel, connectionModel: connectionModel,orgRecordId:recordId, walletHandler: walletHandler, type: .inbox) {[unowned self] (success, id, error) in
                                NotificationCenter.default.post(Notification.init(name: Constants.didRecieveCertOffer))
                                UIApplicationUtils.showSuccessSnackbar(message: "New certificate offer recieved".localized(),navToNotifScreen:true)
                            }
                           
                }
                    }
                }
            }
        }
    }
    
}

// MARK: ISSUE CREDENTIAL

extension WalletViewModel {
    func issueCredential(model:IssueCredentialMesage?,myVerKey: String,recipientKey: String,threadId: String) {
        let walletHandler = self.walletHandle ?? 0
        let base64Data = model?.credentialsAttach?.first?.data?.base64?.decodeBase64() ?? ""
        let credentialAttachDict = UIApplicationUtils.shared.convertToDictionary(text: base64Data)
        let credentialAttachModel = SearchCertificateRawCredential.decode(withDictionary: credentialAttachDict as NSDictionary? ?? NSDictionary()) as? SearchCertificateRawCredential
        self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithMyVerKey,myVerKey: myVerKey) {[unowned self] (success, searchHandler, error) in
            self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, record, error) in
                let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: record,boolKeys: ["delete"])
                let records = recordResponse?["records"] as? [[String:Any]]
                let firstRecord = records?.first
                let connectionModel = CloudAgentConnectionWalletModel.decode(withDictionary: firstRecord as NSDictionary? ?? NSDictionary()) as? CloudAgentConnectionWalletModel
                self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.certType, searchType: .searchWithThreadId, threadId: threadId) {[unowned self] (success, searchHandler, error) in
                    self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, certRecords, error) in
                        let certCecordResponse = UIApplicationUtils.shared.convertToDictionary(text: certRecords)
                        let certificatedModel = SearchCertificateResponse.decode(withDictionary: certCecordResponse as NSDictionary? ?? NSDictionary()) as? SearchCertificateResponse
                        var tempCert = certificatedModel?.records?.first
                        tempCert?.value?.rawCredential = credentialAttachModel
                        tempCert?.value?.state = "credential_received"
                        tempCert?.tags?.state = "credential_received"
                        self.connectionHelper.updateWalletRecord(walletHandler: walletHandler, type: .issueCredential, id: tempCert?.id ?? "", certModel: tempCert ?? SearchCertificateRecord.init()) { [unowned self](success, updatedID, error) in
                            AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler,id:connectionModel?.value?.requestID ?? "", type: .issueCredential, threadId: tempCert?.value?.threadID ?? "",state: tempCert?.tags?.state) { [unowned self] (success, error) in
                                print("Credential Recieved Successfully")
                                self.credentialAckToIssuer(connectionDetailModel: connectionModel, threadId: tempCert?.value?.threadID ?? "", recipientKey: recipientKey, myKey: myVerKey, certModel: tempCert ?? SearchCertificateRecord.init())
                            }
                        }
                    }
                }
            }
        }
    }
    
    func credentialAckToIssuer(connectionDetailModel:CloudAgentConnectionWalletModel?, threadId:String,recipientKey: String,myKey:String,certModel:SearchCertificateRecord) {
        let walletHandler = self.walletHandle ?? 0
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type:
                                                                    AriesAgentFunctions.cloudAgentDidDoc,searchType: .searchWithTheirDid, theirDid: connectionDetailModel?.value?.theirDid ?? "", completion: {[unowned self] (success, searchWalletHandler, error) in
                                                                        if (success){
                                                                            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: {
                                                                                [unowned self](fetchedSuccessfully,results,error) in
                                                                                if (fetchedSuccessfully) {
                                                                                    let resultDict = UIApplicationUtils.shared.convertToDictionary(text: results)
                                                                                    let didDocModel = SearchDidDocModel.decode(withDictionary: resultDict as NSDictionary? ?? NSDictionary()) as? SearchDidDocModel
                                                                                    AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler,recipientKey: recipientKey, myVerKey: myKey, threadId: threadId, type: .credentialAck, isRoutingKeyEnabled: connectionDetailModel?.value?.routingKey?.count ?? 0 > 0,externalRoutingKey: connectionDetailModel?.value?.routingKey ?? []) {[unowned self] (success, data, error) in
                                                                                        
                                                                                        NetworkManager.shared.baseURL = didDocModel?.records?.first?.value?.service?.first?.serviceEndpoint ?? ""
                                                                                        NetworkManager.shared.sendMsg(isMediator: false, msgData: data ?? Data()) { [unowned self] (statuscode,responseData) in
                                                                                           
                                                                                            self.saveCredentialToWallet(certModel: certModel,connectionDetailModel:connectionDetailModel)
                                                                                        }
                                                                                    }
                                                                                }
                                                                            })
                                                                            }
                                                                    })
    }
    
    func saveCredentialToWallet(certModel: SearchCertificateRecord,connectionDetailModel:CloudAgentConnectionWalletModel?) {
        let walletHandler = self.walletHandle ?? 0
        AriesPoolHelper.shared.pool_setProtocol(version: 2) {[unowned self] (success, error) in
            AriesPoolHelper.shared.pool_openLedger(name: "default", config: [String : Any]()) {[unowned self] (success, poolHandler, error) in
                AriesPoolHelper.shared.pool_prover_store_credential(walletHandle: walletHandler, credentialModel: certModel) { [unowned self](success, outCredID, error) in
                    AriesPoolHelper.shared.pool_prover_get_credentials(id: outCredID, walletHandle: walletHandler) { [unowned self] (success, credID, error) in
                        if success {
                            self.connectionHelper.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.certType, id: certModel.id ?? "") {[unowned self] (deletedSuccessfully, error) in
                                print("Cert Added \(deletedSuccessfully)")
                                self.deleteFromInbox(threadId: certModel.value?.threadID ?? "")
                                let credentialDict = UIApplicationUtils.shared.convertToDictionary(text: credID)
                                let walletCredentialModel = WalletCredentialModel.decode(withDictionary: credentialDict as NSDictionary? ?? NSDictionary()) as? WalletCredentialModel
                                let customWalletModel = CustomWalletRecordCertModel.init()
                                customWalletModel.referent = walletCredentialModel
                                customWalletModel.schemaID = certModel.value?.schemaID
                                customWalletModel.certInfo = certModel
                                customWalletModel.connectionInfo = connectionDetailModel
                                AriesAgentFunctions.shared.addWalletRecord(connectionRecordId: "",walletCert:customWalletModel, walletHandler: walletHandler, type: .walletCert) { [unowned self](success, response, error) in
                                    if success {
                                        UIApplicationUtils.showSuccessSnackbar(message: "New certificate is added to wallet".localized())
                                        self.getSavedCertificates()
                                    } else {
                                        UIApplicationUtils.showErrorSnackbar(message: "Error saving certificate to wallet")
                                    }
                                   
                                }
                               
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteFromInbox(threadId:String){
        let walletHandler = self.walletHandle ?? 0
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, searchType: .searchWithThreadId,threadId: threadId) { [unowned self](success, searchHanlder, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHanlder) {[unowned self] (sucess, response, error) in
                let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: response,boolKeys: ["auto_present","trace","auto_offer","auto_issue","auto_remove"])
                let resultModel = SearchInboxModel.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? SearchInboxModel
                let recordId = resultModel?.records?.first?.id ?? ""
                AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, id: recordId) {[unowned self] (success, error) in
                    if success{
                        print("Cert removed from inbox records")
                    }
                }
            }
        }
    }
    func deleteCredentialWith(id:String,walletRecordId: String?){
        let walletHandler = self.walletHandle ?? 0
        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.walletCertificates, id: walletRecordId ?? "") { [unowned self](success, error) in
            AriesPoolHelper.shared.deleteCredentialFromWallet(withId: id, walletHandle: walletHandler) { [unowned self](success, error) in
                self.getSavedCertificates()
            }
        }
    }
}

//MARK: request-presentation
extension WalletViewModel {

    func requestPresentationRecieved(requestPresentationMessageModel: RequestPresentationMessageModel?,myVerKey: String,recipientKey: String) {
        let walletHandler = self.walletHandle ?? 0
        let base64String = requestPresentationMessageModel?.requestPresentationsAttach?.first?.data?.base64?.decodeBase64() ?? ""
        let base64DataDict = UIApplicationUtils.shared.convertToDictionary(text: base64String)
        let presentationRequestModel = PresentationRequestModel.decode(withDictionary: base64DataDict as NSDictionary? ?? NSDictionary()) as? PresentationRequestModel
        self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithMyVerKey,myVerKey: myVerKey) { [unowned self](success, searchHandler, error) in
            self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, record, error) in
                let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: record,boolKeys: ["delete"])
                let cloudAgentSearchConnectionModel = CloudAgentSearchConnectionModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? CloudAgentSearchConnectionModel
                if cloudAgentSearchConnectionModel?.totalCount ?? 0 > 0 {
                    self.connectionHelper.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.presentationExchange,searchType:.searchWithThreadId, threadId: requestPresentationMessageModel?.id ?? "") {[unowned self] (success, prsntnExchngSearchWallet, error) in
                        self.connectionHelper.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: prsntnExchngSearchWallet) {[unowned self] (success, response, error) in
                            let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: response)
                            if (recordResponse?["totalCount"] as? Int ?? 0) > 0 {
                                return
                            }
//                            let searchPresentationExchangeModel = SearchPresentationExchangeModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? SearchPresentationExchangeModel
                            let connectionModel = cloudAgentSearchConnectionModel?.records?.first
                            var  presentationExchangeWalletModel = PresentationRequestWalletRecordModel.init()
                            presentationExchangeWalletModel.threadID = requestPresentationMessageModel?.id
                            presentationExchangeWalletModel.connectionID = connectionModel?.value?.requestID
                            presentationExchangeWalletModel.createdAt = AgentWrapper.shared.getCurrentDateTime()
                            presentationExchangeWalletModel.updatedAt = AgentWrapper.shared.getCurrentDateTime()
                            presentationExchangeWalletModel.initiator = "external"
                            presentationExchangeWalletModel.presentationRequest = presentationRequestModel
                            presentationExchangeWalletModel.role = "prover"
                            presentationExchangeWalletModel.state = "request_received"
                            presentationExchangeWalletModel.autoPresent = true
                            presentationExchangeWalletModel.trace = false
                            
                            self.connectionHelper.addWalletRecord(connectionRecordId: connectionModel?.value?.requestID, presentationExchangeModel:presentationExchangeWalletModel, walletHandler: walletHandler,  type: .presentationRequest) { [unowned self](success, recordId, error) in
                                self.connectionHelper.addWalletRecord(connectionRecordId: connectionModel?.value?.requestID, presentationExchangeModel:presentationExchangeWalletModel, connectionModel: connectionModel,orgRecordId:recordId,  walletHandler: walletHandler, type: .inbox) { [unowned self](success, id, error) in
                                    print("Add wallet record - Presentation Request")
                                    NotificationCenter.default.post(name: Constants.didRecieveDataExchangeRequest, object: nil)
                                    UIApplicationUtils.showSuccessSnackbar(message: "New exchange data request recieved".localized(),navToNotifScreen:true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


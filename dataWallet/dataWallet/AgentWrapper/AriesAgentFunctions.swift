//
//  AriesAgentHelper.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 16/11/20.
//

import Foundation
import UIKit

enum UpdateWalletType {
    case initial
    case updateTheirDid
    case inboxCreated
    case initialCloudAgent
    case updateCloudAgentRecord
    case trusted
    case credentialExchange
    case issueCredential
}

enum UpdateWalletTagType {
    case initial
    case updateTheirDid
    case initialCloudAgent
    case updateCloudAgentTag
    case mediatorActive
    case cloudAgentActive
    case issueCredential
    case credentialExchange

}

enum AddWalletType {
    case mediatorConnection
    case mediatorInvitation
    case connection
    case invitation
    case offerCredential
    case presentationRequest
    case walletCert
    case inbox
}

enum PackMessageType {
    case initialMediator
    case initialCloudAgent
    case pollingMediator
    case addRoute
    case createInbox
    case trustPing
    case deleteInboxItem
    case credentialRequest
    case credentialAck
    case proposePresentation
    case queryIgrantAgent
    case getIgrantOrgDetail
    case getIgrantCertTypeResponse
    case presentation
    case informDuplicateConnection
}

enum WalletSearch {
    case withoutQuery
    case searchWithInvitationKey
    case searchWithId
    case searchtWithDidKey
    case searchWithThreadId
    case searchWithTheirDid
    case searchWithReciepientKey
    case offerRecieved
    case getActiveConnections
    case checkExistingConnection
    case inbox_offerRecieved
    case searchWithOrgId
    case searchWithMyVerKey
}

class AriesAgentFunctions {
    static var shared = AriesAgentFunctions()
    private init(){}
    static var mediatorConnection = "mediator_connection"
    static var mediatorConnectionInvitation = "mediator_connection_invitation"
    static var cloudAgentConnection = "connection"
    static var cloudAgentConnectionInvitation = "invitation"
    static var mediatorDidDoc = "mediator_didDoc"
    static var mediatorDidKey = "mediator_didKey"
    static var cloudAgentDidDoc = "did_doc"
    static var cloudAgentDidKey = "did_Key"
    static var certType = "credential_exchange_v10"
    static var presentationExchange = "presentationexchange_v10"
    static var walletCertificates = "wallet_cert"
    static var inbox = "inbox"
    
    func addWalletRecord(invitationKey: String = "", threadID: String = "", label: String = "",serviceEndPoint: String = "", connectionRecordId: String?,myVerKey: String? = "", certIssueModel: CertificateIssueModel? = nil, imageURL:String = "", reciepientKey: String? = "", presentationExchangeModel: PresentationRequestWalletRecordModel? = PresentationRequestWalletRecordModel.init(),walletCert: CustomWalletRecordCertModel? = nil,connectionModel:CloudAgentConnectionWalletModel? = CloudAgentConnectionWalletModel(),orgRecordId: String? = "", walletHandler: IndyHandle,type: AddWalletType,routingKey: String = "",orgID: String? = "", completion: @escaping (Bool,String,Error?) -> Void){ //Success,connectionRecordId,error
        var value = [String : Any?]()
        var recordType = ""
        var tagJson = [String : Any?]()
        switch type {
        case .mediatorConnection,.connection:
            value = [
                "invitation_key": invitationKey,// - recipientkey
                "created_at": AgentWrapper.shared.getCurrentDateTime(),
                "updated_at": AgentWrapper.shared.getCurrentDateTime(),//"2020-10-22 12:20:23.188047Z",
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label, //- label in inv
                "state": "invitation",
                "imageURL" : imageURL,
                "routing_key" : routingKey,
                "orgID": orgID ?? ""
            ] as [String : Any?]
            
            tagJson = [
                "invitation_key": invitationKey,
                "routing_key" : routingKey,
                "orgID": orgID ?? "",
                "myVerKey": myVerKey
            ] as [String : Any?]
            
            recordType = type == .mediatorConnection ? AriesAgentFunctions.mediatorConnection : "connection"
        case .mediatorInvitation,.invitation:
            value = [
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation",
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),// - random
                "serviceEndpoint": serviceEndPoint ,
                "imageURL" : imageURL,
                "recipientKeys": [
                    reciepientKey
                ],
                "label": label,
                "routing_key" : routingKey
            ] as [String : Any]
            
            tagJson = [
                "connection_id": connectionRecordId,
                "request_id": connectionRecordId,
                "invitation_key": invitationKey,
                "routing_key" : routingKey
            ]
            recordType = type == .mediatorInvitation ? AriesAgentFunctions.mediatorConnectionInvitation : AriesAgentFunctions.cloudAgentConnectionInvitation
            
        case .offerCredential:
            var attributeDict: [[String: Any]] = []
            for attr in certIssueModel?.credentialPreview?.attributes ?? []{
                attributeDict.append([
                    "name": attr.name,
                    "value": attr.value
                ])
            }
            let base64Content = certIssueModel?.offersAttach?.first?.data?.base64?.decodeBase64() ?? ""
            let base64ContentDict = UIApplicationUtils.shared.convertToDictionary(text: base64Content) ?? [String: Any]()
            value = [
                "thread_id": certIssueModel?.id,
                  "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                  "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                  "connection_id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                  "credential_proposal_dict": [
                    "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/propose-credential",
                    "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                    "comment": "string",
                    "cred_def_id": base64ContentDict["cred_def_id"],
                    "schema_id": base64ContentDict["schema_id"],
                    "credential_proposal": [
                      "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/credential-preview",
                      "attributes": attributeDict
                    ]
                  ],
                  "credential_offer_dict": nil,
                  "credential_offer": base64ContentDict,
                  "credential_request": nil,
                  "credential_request_metadata": nil,
                  "error_msg": nil,
                  "auto_offer": false,
                  "auto_issue": false,
                  "auto_remove": true,
                  "raw_credential": nil,
                  "credential": nil,
                  "parent_thread_id": nil,
                  "initiator": "external",
                  "credential_definition_id": base64ContentDict["cred_def_id"],
                  "schema_id": base64ContentDict["schema_id"],
                  "credential_id": nil,
                  "revoc_reg_id": nil,
                  "revocation_id": nil,
                  "role": "holder",
                  "state": "offer_received",
                  "trace": false
            ]
            
            tagJson = [
                "thread_id" : threadID,
                "request_id": connectionRecordId,
                "state": "offer_received"
            ]
            recordType = AriesAgentFunctions.certType
        case .presentationRequest:
            value = presentationExchangeModel?.dictionary ?? [String:Any]()
            tagJson = ["thread_id": presentationExchangeModel?.threadID]
            recordType = AriesAgentFunctions.presentationExchange
            
        case .walletCert:
            value = walletCert?.dictionary ?? [String:Any]()
            tagJson = [
                "connection_id": walletCert?.connectionInfo?.value?.requestID,
                "request_id": walletCert?.connectionInfo?.value?.requestID,
                "invitation_key": walletCert?.connectionInfo?.value?.invitationKey
            ]
            recordType = AriesAgentFunctions.walletCertificates
        case .inbox:
            var attributeDict: [[String: Any]] = []
            for attr in certIssueModel?.credentialPreview?.attributes ?? [] {
                attributeDict.append([
                    "name": attr.name,
                    "value": attr.value
                ])
            }
            let base64Content = certIssueModel?.offersAttach?.first?.data?.base64?.decodeBase64() ?? ""
            let base64ContentDict = UIApplicationUtils.shared.convertToDictionary(text: base64Content) ?? [String: Any]()
            let searchPresentationModel = SearchPresentationExchangeValueModel.init(type: "", id: orgRecordId, value: presentationExchangeModel)
            let cred_def_id = base64ContentDict["cred_def_id"] as? String ?? ""
            let schema_id =  base64ContentDict["schema_id"] as? String ?? ""
            value = [
                "orgRecordId": orgRecordId ?? "",
                "connectionModel": connectionModel?.dictionary ?? [String:Any](),
                "presentationRequest": presentationExchangeModel?.threadID == nil ? nil : searchPresentationModel.dictionary ?? [String:Any](),
                "offerCredential" :presentationExchangeModel?.threadID != nil ? nil : [
                    "id": orgRecordId ?? "",
                    "type": "",
                    "tags" : [String:Any](),
                    "value": [
                    "thread_id": certIssueModel?.id,
                      "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                      "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                      "connection_id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                      "credential_proposal_dict": [
                        "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/propose-credential",
                        "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                        "comment": "string",
                        "cred_def_id": cred_def_id,
                        "schema_id": schema_id,
                        "credential_proposal": [
                          "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/credential-preview",
                          "attributes": attributeDict
                        ]
                      ],
                      "credential_offer_dict": nil,
                      "credential_offer": base64ContentDict,
                      "credential_request": nil,
                      "credential_request_metadata": nil,
                      "error_msg": nil,
                      "auto_offer": false,
                      "auto_issue": false,
                      "auto_remove": true,
                      "raw_credential": nil,
                      "credential": nil,
                      "parent_thread_id": nil,
                      "initiator": "external",
                      "credential_definition_id": cred_def_id,
                      "schema_id": schema_id,
                      "credential_id": nil,
                      "revoc_reg_id": nil,
                      "revocation_id": nil,
                      "role": "holder",
                      "state": "offer_received",
                      "trace": false
                ]],
                "type" : presentationExchangeModel?.threadID != nil ? InboxType.certRequest.rawValue : InboxType.certOffer.rawValue
            ]
            tagJson = [
                "type" : presentationExchangeModel?.threadID != nil ? InboxType.certRequest.rawValue : InboxType.certOffer.rawValue,
                "thread_id": presentationExchangeModel?.threadID ?? threadID,
                "request_id": connectionRecordId,
            ]
            recordType = AriesAgentFunctions.inbox
        }
        
        let connectionRecordId = AgentWrapper.shared.generateRandomId_BaseUID4()
        
        AgentWrapper.shared.addWalletRecord(inWallet: walletHandler, type: recordType, id: connectionRecordId , value: UIApplicationUtils.shared.getJsonString(for: value), tagsJson: UIApplicationUtils.shared.getJsonString(for: tagJson)) { (error) in
            if(error?._code == 0){
                print("connection record saved")
                completion(true,connectionRecordId ,error)
            } else {
                completion(false,connectionRecordId ,error)
            }
            
        }
    }
    
    func getWallerRecord(walletHandler: IndyHandle, connectionRecordId: String,isMediator: Bool, completion: @escaping (Bool,Error?) -> Void){
        let optionJson = [
            "retrieveType": false,
            "retrieveValue": true,
            "retrieveTags": false
        ] as [String : Any?]
        
        AgentWrapper.shared.getWalletRecord(walletHandle: walletHandler, type: isMediator ? AriesAgentFunctions.mediatorConnection : "connection", id: connectionRecordId, optionsJson: UIApplicationUtils.shared.getJsonString(for: optionJson)) { (error, response) in
            //            print("get wallet records -- \(response)")
            if(error?._code != 0){
                completion(false,error)
                return;
            }
            completion(true,error)
        }
    }
    
    func createAndStoreId(walletHandler: IndyHandle,completion: @escaping(Bool,String?,String?,Error?) -> Void){ //Success,did,verkey,error
        AgentWrapper.shared.createAndStoreDid(did: "{}", walletHandle: walletHandler) { (error, did, verKey) in
            print("Create and store did")
            if(error?._code != 0){
                completion(false,did,verKey,error)
                return;
            }
            completion(true,did,verKey,error)
        }
    }
    
    func setMetadata(walletHandler: IndyHandle, myDid: String,verKey: String, completion: @escaping (Bool) -> Void){
        let metadata = [
            "did" : myDid,
            "verkey" : verKey,
            "tempVerkey" : nil,
            "metadata" : nil
        ] as [String : Any?]
        
        AgentWrapper.shared.setMetadata(metadata: UIApplicationUtils.shared.getJsonString(for: metadata), forDid: myDid, walletHandle: walletHandler) { (error) in
            print("set meta")
            if(error?._code != 0){
                completion(false)
                return;
            }
            completion(true)
        }
    }
    
    func updateWalletRecord(walletHandler: IndyHandle,recipientKey: String = "", label: String = "",type: UpdateWalletType, id: String,theirDid: String = "", myDid: String = "",imageURL: String = "", invitiationKey: String? = "",isIgrantAgent: Bool? = false,certModel: SearchCertificateRecord = SearchCertificateRecord.init(),routingKey: [String]? = [], presentationReqModel: PresentationRequestWalletRecordModel? = nil,orgDetails:OrganisationInfoModel? = nil, orgID: String? = "", completion: @escaping(Bool,String,Error?) -> Void) {
        //let updateAndWalletId = AgentWrapper.shared.generateRandomId_BaseUID4()
        var updateWalletRecord = [String : Any?]()
        var walletType = AriesAgentFunctions.mediatorConnection
        
        switch type {
        case .initial:
            updateWalletRecord = [
                "request_id": id,
                "my_did": myDid,
                "invitation_key": recipientKey ,
                "routing_key" : routingKey,
                "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label ,
                "state": "request"
            ] as [String : Any?]
        case .updateTheirDid:
            updateWalletRecord = [
                "their_did": "\(theirDid)",
                "request_id": id,
                "my_did": myDid,
                "invitation_key": recipientKey,
                "routing_key" : routingKey,
                "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label ,
                "state": "response",
            ] as [String : Any?]
        case .inboxCreated:
            updateWalletRecord = [
                "their_did": "\(theirDid)",
                "request_id": id,
                "my_did": myDid,
                "invitation_key": invitiationKey,
                "routing_key" : routingKey,
                "reciepientKey" : recipientKey,
                "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label ,
                "state": "active",
                "inbox_id": "",
                "inbox_Key": "",
            ] as [String : Any?]
            
        case .updateCloudAgentRecord:
            updateWalletRecord = [
                "their_did": "\(theirDid)",
                "request_id": id,
                "my_did": myDid,
                "invitation_key": invitiationKey,
                "reciepientKey" : recipientKey,
                "routing_key" : routingKey,
                "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label ,
                "state": "response",
                "isIgrantAgent": (isIgrantAgent ?? false) ? "1" : "0",
                "imageURL" : imageURL,
                "orgID": orgID ?? ""
            ] as [String : Any?]
            walletType = "connection"
        case .initialCloudAgent:
            updateWalletRecord = [
                "request_id": id,
                "my_did": myDid,
                "invitation_key": invitiationKey ,
                "reciepientKey" : recipientKey,
                "routing_key" : routingKey,
                "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label ,
                "state": "request",
                "isIgrantAgent": (isIgrantAgent ?? false) ? "1" : "0",
                "imageURL" : imageURL,
                "orgID": orgID ?? ""

            ] as [String : Any?]
            walletType = "connection"
        case .trusted:
            updateWalletRecord = [
                "their_did": "\(theirDid)",
                "request_id": id,
                "my_did": myDid,
                "invitation_key": invitiationKey,
                "routing_key" : routingKey,
                "reciepientKey" : recipientKey,
                "created_at":  AgentWrapper.shared.getCurrentDateTime(),
                "updated_at":  AgentWrapper.shared.getCurrentDateTime(),
                "initiator": "external",
                "their_role": nil,
                "inbound_connection_id": nil,
                "routing_state": "none",
                "accept": "manual",
                "invitation_mode": "once",
                "alias": nil,
                "error_msg": nil,
                "their_label": label ,
                "state": "active",
                "inbox_id": "",
                "inbox_Key": "",
                "isIgrantAgent": (isIgrantAgent ?? false) ? "1" : "0",
                "imageURL" : imageURL,
                "orgDetails" : orgDetails?.dictionary ?? [String:Any](),
                "orgID": orgID ?? ""
            ] as [String : Any?]
            walletType = "connection"
        case .credentialExchange:
            let tempCertModel = presentationReqModel ?? PresentationRequestWalletRecordModel.init()
            updateWalletRecord = tempCertModel.dictionary ?? [String:Any]()
            walletType = AriesAgentFunctions.presentationExchange
        case .issueCredential:
            let tempCertModel = certModel.value ?? SearchCertificateValue.init()
            updateWalletRecord = tempCertModel.dictionary ?? [String:Any]()
            walletType = AriesAgentFunctions.certType
        }
        
        AgentWrapper.shared.updateWalletRecord(inWallet: walletHandler, type: walletType, id: id, value: UIApplicationUtils.shared.getJsonString(for: updateWalletRecord)) { (error) in
            print("update wallet records")
            if(error?._code != 0){
                completion(false,id,error)
                return;
            }
            completion(true,id,error)
        }
    }
    
    func updateWalletTags(walletHandler: IndyHandle,id: String?, myDid: String? = "", theirDid: String? = "",recipientKey: String? = "",
                          serviceEndPoint: String? = "",invitiationKey: String? = "",type: UpdateWalletTagType,threadId: String? = "",isIgrantAgent: Bool? = false, state: String? = "",routingKey: String? = "",orgID: String? = "",myVerKey:String? = "", completion: @escaping(Bool,Error?) -> Void){
        var tagsJson = [String:Any?]()
        var walletType = AriesAgentFunctions.mediatorConnection
        
        switch type {
        case .initial:
            tagsJson = [
                "request_id": id ?? "",
                "my_did": myDid ?? "",
                "invitation_key": invitiationKey ?? "",
                "routing_key" : routingKey,
                "orgID": orgID ?? ""
            ]
        case .updateTheirDid:
            tagsJson = [
                "their_did": "\(theirDid ?? "")",
                "request_id": id ?? "",
                "my_did": myDid ?? "",
                "invitation_key": invitiationKey ?? "",
                "reciepientKey": recipientKey ?? "",
                "routing_key" : routingKey,
                "orgID": orgID ?? ""
            ]
        case .updateCloudAgentTag:
            tagsJson = [
                "their_did": "\(theirDid ?? "")",
                "request_id": id ?? "",
                "my_did": myDid ?? "",
                "invitation_key": invitiationKey ?? "",
                "reciepientKey": recipientKey ?? "",
                "routing_key" : routingKey,
                "orgID": orgID ?? "",
                "myVerKey": myVerKey
            ]
            walletType = AriesAgentFunctions.cloudAgentConnection
        case .initialCloudAgent:
            tagsJson = [
                "request_id": id ?? "",
                "my_did": myDid ?? "",
                "invitation_key": invitiationKey ?? "",
                "routing_key" : routingKey,
                "serviceEndPoint": serviceEndPoint ?? "",
                "reciepientKey" : recipientKey ?? "",
                "isIgrantAgent": (isIgrantAgent ?? false) ? "1" : "0",
                "state": "request",
                "orgID": orgID ?? "",
                "myVerKey": myVerKey
            ]
            walletType = AriesAgentFunctions.cloudAgentConnection
        case .mediatorActive:
            tagsJson = [
            "their_did": "\(theirDid ?? "")",
            "request_id": id ?? "",
            "my_did": myDid ?? "",
            "invitation_key": invitiationKey ?? "",
            "reciepientKey" : recipientKey ?? "",
            "state": "active",
                ]
        case .cloudAgentActive:
            tagsJson = [
            "their_did": "\(theirDid ?? "")",
            "request_id": id ?? "",
            "my_did": myDid ?? "",
            "invitation_key": invitiationKey ?? "",
            "reciepientKey" : recipientKey ?? "",
            "state": "active",
                "routing_key" : routingKey,
            "isIgrantAgent": (isIgrantAgent ?? false) ? "1" : "0",
                "orgID": orgID ?? "",
                "myVerKey": myVerKey
                ]
            walletType = AriesAgentFunctions.cloudAgentConnection
        case .issueCredential:
            tagsJson = [
                "thread_id": threadId ?? "",
                "request_id": id ?? "",
                "state": state
            ]
            walletType = AriesAgentFunctions.certType
            case .credentialExchange:
                tagsJson = [
                    "thread_id": threadId ?? "",
                    "request_id": id ?? "",
                    "state": state
                ]
                walletType = AriesAgentFunctions.presentationExchange
        }
        AgentWrapper.shared.updateWalletTags(inWallet: walletHandler, type: walletType, id: id, tagsJson: UIApplicationUtils.shared.getJsonString(for: tagsJson)) { (error) in
            print("Update wallet tags")
            if(error?._code != 0){
                completion(false,error)
                return;
            }
            completion(true,error)
        }
    }
    
    func getMyDidWithMeta(walletHandler: IndyHandle, myDid: String,completion: @escaping (Bool,String?, Error?) -> Void){
        AgentWrapper.shared.getMyDidWithMeta(did: myDid, walletHandle: walletHandler) { (error, response) in
            print("get Did meta --- \(response ?? "")")
            if(error?._code != 0){
                completion(false,response,error)
                return;
            }
            completion(true,response,error)
        }
    }
    
    func openWalletSearch(walletHandler: IndyHandle, id: String, completion: @escaping(Bool,IndyHandle,Error?) -> Void){
        let queryDic = [
            "connection_id": id,
            "request_id" : id
        ]
        let optionDict = [
            "retrieveRecords": true,
            "retrieveTotalCount": false,
            "retrieveType": false,
            "retrieveValue": true,
            "retrieveTags": true
        ]
        
        AgentWrapper.shared.openWalletSearch(inWallet: walletHandler, type:AriesAgentFunctions.mediatorConnectionInvitation, queryJson: UIApplicationUtils.shared.getJsonString(for: queryDic), optionsJson: UIApplicationUtils.shared.getJsonString(for: optionDict)) { (error, indyHandle) in
            print("Open wallet search")
            if(error?._code != 0){
                completion(false,indyHandle,error)
                return;
            }
            completion(true,indyHandle,error)
        }
    }
    
    func openWalletSearch_type(walletHandler: IndyHandle,type:String, searchType: WalletSearch, invitationKey: String = "", serviceEndPoint: String = "", record_id: String = "",didKey: String = "",threadId: String = "",myDid:String = "",theirDid:String = "",reciepientKey: String = "", orgID:String = "",myVerKey:String = "", completion: @escaping(Bool,IndyHandle,Error?) -> Void){
        var queryDic = [String:Any]()
        switch searchType {
        case .withoutQuery: break
        case .searchWithInvitationKey:
            queryDic = [
                "invitation_key" : invitationKey
            ]
        case .searchWithId:
            queryDic = [
                "request_id": record_id
            ]
        case .searchtWithDidKey:
            queryDic = [
                "key": didKey
            ]
        case .searchWithThreadId:
            queryDic = [
                "thread_id": threadId
            ]
        case .searchWithTheirDid:
            queryDic = [
                "did" : theirDid
            ]
        case .searchWithReciepientKey:
            queryDic = [
                "reciepientKey" : reciepientKey
            ]
            
        case .offerRecieved:
            queryDic = [
                "request_id": record_id,
                "state": "offer_received"
        ]
            case .getActiveConnections:
                queryDic = [
                    "state": "active",
            ]
            case .checkExistingConnection:
                queryDic = [
                    "invitation_key" : invitationKey,
                    "state": "active",
            ]
        case .inbox_offerRecieved:
            queryDic = [
                "type" : InboxType.certOffer.rawValue,
                "request_id": record_id
            ]
        case .searchWithOrgId:
            queryDic = [
                "orgID" : orgID ?? "",
                "state": "active",
            ]
            case .searchWithMyVerKey:
                queryDic = [
                    "myVerKey": myVerKey
                ]
        }
        
        
        let optionDict = [
            "retrieveRecords": true,
            "retrieveTotalCount": true,
            "retrieveType": false,
            "retrieveValue": true,
            "retrieveTags": true
        ]
        
        AgentWrapper.shared.openWalletSearch(inWallet: walletHandler, type: type, queryJson: UIApplicationUtils.shared.getJsonString(for: queryDic), optionsJson: UIApplicationUtils.shared.getJsonString(for: optionDict)) { (error, indyHandle) in
            print("Open wallet search -- \(type)")
            if(error?._code != 0){
                completion(false,indyHandle,error)
                return;
            }
            completion(true,indyHandle,error)
        }
    }
    
    func fetchWalletSearchNextRecords(walletHandler: IndyHandle, searchWalletHandler: IndyHandle,count: Int? = 1000, completion: @escaping (Bool,String,Error?) -> Void){
        AgentWrapper.shared.fetchNextRecords(fromSearch: searchWalletHandler, walletHandle: walletHandler, count: NSNumber.init(value: count ?? 1)) { (error, response) in
            print("fetch next records -- \(response ?? "")")
            if(error?._code != 0){
                completion(false,"",error)
                return;
            }
            completion(true,response ?? "",error)
            //Close wallet search handle after use
        }
    }
    
    func packMessage(walletHandler: IndyHandle,label: String = "",recipientKey: String,id: String = "", myDid: String = "", myVerKey: String,serviceEndPoint: String = "",routingKey: String = "",routedestination: String? = "",deleteItemId: String = "",threadId: String? = "",credReq: String? = "",attributes: ProofExchangeAttributesArray? = nil, type: PackMessageType,isRoutingKeyEnabled:Bool, externalRoutingKey: [String]? = [],presentation: PRPresentation? = nil,theirDid: String? = "",QR_ID:String? = "", completion: @escaping (Bool,Data?,Error?) -> Void){
        var messageDict = [String : Any?]()
        switch type {
        case .initialMediator :
            messageDict = [
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/request",
                "@id": id,
                "label": label ,
                "connection": [
                    "DID": myDid,
                    "DIDDoc": [
                        "@context": "https://w3id.org/did/v1",
                        "id": "did:sov:\(myDid)",
                        "publicKey": [
                            [
                                "id": "did:sov:\(myDid)#1",
                                "type": "Ed25519VerificationKey2018",
                                "controller": "did:sov:\(myDid)",
                                "publicKeyBase58": myVerKey  // - verkey
                            ]
                        ],
                        "authentication": [
                            [
                                "type": "Ed25519SignatureAuthentication2018",
                                "publicKey": "did:sov:\(myDid)#1"
                            ]
                        ],
                        "service": [
                            [
                                "id": "did:sov:\(myDid);indy",
                                "type": "IndyAgent",
                                "priority": 0,
                                "recipientKeys": [
                                    myVerKey
                                ],
                                "serviceEndpoint": ""
                            ]
                        ]
                    ]
                ],
                "~transport" : [
                    "return_route": "all"
                ]
            ] as [String : Any?]
            
        case .initialCloudAgent:
            messageDict = [
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/request",
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                "label": UIDevice.current.name,
                "connection": [
                    "DID": myDid,
                    "DIDDoc": [
                        "@context": "https://w3id.org/did/v1",
                        "id": "did:sov:\(myDid)",
                        "publicKey": [
                            [
                                "id": "did:sov:\(myDid)#1",
                                "type": "Ed25519VerificationKey2018",
                                "controller": "did:sov:\(myDid)",
                                "publicKeyBase58": myVerKey  // - verkey
                            ]
                        ],
                        "authentication": [
                            [
                                "type": "Ed25519SignatureAuthentication2018",
                                "publicKey": "did:sov:\(myDid)#1"
                            ]
                        ],
                        "service": [
                            [
                                "id": "did:sov:\(myDid);indy",
                                "type": "IndyAgent",
                                "priority": 0,
                                "routingKeys": [
                                    routingKey
                                ],
                                "recipientKeys": [
                                    myVerKey
                                ],
                                "serviceEndpoint": NetworkManager.shared.mediatorEndPoint
                            ]
                        ],
                    ]
                ],
                "~transport" : [
                    "return_route": "all"
                ]
            ] as [String : Any?]
            
        case .pollingMediator:
            
            messageDict = [
                "@id": id,
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/basic-routing/1.0/get-inbox-items",
                "~transport": [
                    "return_route": "all"
                ]
            ]

        case .addRoute:
            messageDict = [
                   "@id" : AgentWrapper.shared.generateRandomId_BaseUID4(),
                   "@type" : "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/basic-routing/1.0/add-route",
                   "routedestination": routedestination,
                   "~transport": [
                       "return_route" : "all"
                   ]
            ] as [String : Any]
        case .createInbox:
            messageDict = [
                "@id": id,
                    "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/basic-routing/1.0/create-inbox",
                    "~transport": [
                        "return_route": "all"
                    ]
            ]
        case .trustPing:
            messageDict = [
                "@type": "https://didcomm.org/trust_ping/1.0/ping",
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                "comment": "ping",
                "response_requested": true
            ]
        case .deleteInboxItem:
            messageDict = [
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/basic-routing/1.0/delete-inbox-items",
                "inboxitemids": [
                  deleteItemId
                ],
                "~transport": [
                  "return_route": "all"
                ]
            ]
        case .credentialRequest:
            messageDict = [
                  "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/request-credential",
                  "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                  "~thread": [
                    "thid": threadId ?? ""
                  ],
                  "requests~attach": [
                    [
                      "@id": "libindy-cred-request-0",
                      "mime-type": "application/json",
                      "data": [
                        "base64": credReq?.encodeBase64()
                      ]
                    ]
                  ]
            ]
        case .credentialAck:
            messageDict = [
                  "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/issue-credential/1.0/ack",
                  "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                  "~thread": [
                    "thid": threadId ?? ""
                  ],
                  "status": "OK"
            ]
        case .proposePresentation:
            messageDict = [
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/present-proof/1.0/propose-presentation",
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                "qr_id":QR_ID,
                "presentation_proposal": [
                  "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/present-proof/1.0/presentation-preview",
                    "attributes": attributes?.dictionary?["items"] ?? [String:Any](),
                  "predicates": []
                ],
                "comment": "Proposing credentials",
                "~transport": [
                  "return_route": "all"
                ]
              ]
        case .queryIgrantAgent:
            messageDict = [
                    "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/discover-features/1.0/query",
                    "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                    "query": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/igrantio-operator/*",
                    "comment": "Querying features available.",
                    "~transport": [
                        "return_route": "all"
                    ]
                ]
        case .getIgrantOrgDetail:
            messageDict = [
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/igrantio-operator/1.0/organization-info",
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                "~transport": [
                    "return_route": "all"
                ]
              ]
        case .getIgrantCertTypeResponse:
            messageDict = [
                "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/igrantio-operator/1.0/list-data-certificate-types",
                "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                "~transport": [
                    "return_route": "all"
                ]
                ]
            case .presentation:
                let modelDict = presentation?.dictionary ?? [String:Any]()
                let base64 = modelDict.toString()?.encodeBase64()
                messageDict = [
                  "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/present-proof/1.0/presentation",
                  "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                  "~thread": [
                    "thid": threadId
                  ],
                  "presentations~attach": [
                    [
                      "@id": "libindy-presentation-0",
                      "mime-type" : "application/json",
                        "data" : ["base64" : base64]
                    ]
                  ],
                  "comment": "auto-presented for proof request nonce=1234567890"
                ]
            case .informDuplicateConnection:
                messageDict = [
                      "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/igrantio-operator/1.0/org-multiple-connections",
                    "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
                    "theirdid": theirDid ?? "",
//                    "~transport": [
//                        "return_route": "all"
//                    ]
                    ]
        }
        let messageJsonString = UIApplicationUtils.shared.getJsonString(for: messageDict)
        let messageData = Data(messageJsonString.utf8)
        
        //Note: the message is posted to responders service endpoint with header `{'Content-Type': 'application/ssi-agent-wire'}`
        
        if isRoutingKeyEnabled {
            AgentWrapper.shared.packMessage(message: messageData, myKey: myVerKey, recipientKey: "[\"\(recipientKey)\"]", walletHandle: walletHandler) { (error, data) in
                print("pack message")
                self.forwardMessagePack(walletHandler: walletHandler, message: data ?? Data(), recipient_key: recipientKey, routingKey: externalRoutingKey ?? [], myVerKey: myVerKey, completion: completion)
            }
        } else {
            AgentWrapper.shared.packMessage(message: messageData, myKey: myVerKey, recipientKey: "[\"\(recipientKey)\"]", walletHandle: walletHandler) { (error, data) in
                print("pack message")
                if(error?._code != 0){
                    completion(false,data,error)
                    return;
                }
                completion(true,data,error)
            }
        }
    }
    
    func unpackMessage(walletHandler: IndyHandle,messageData: Data, completion: @escaping (Bool,Data?,Error?) -> Void){
        AgentWrapper.shared.unpackMessage(message: messageData, walletHandle: walletHandler) { (error, data) in
            print("unpack message")
            if(error?._code != 0){
                completion(false,data,error)
                return;
            }
            completion(true,data,error)
        }
    }
    
    func addWalletRecord_DidDoc(walletHandler: IndyHandle,invitationKey: String, theirDid: String, recipientKey: String, serviceEndPoint: String,routingKey:String,isMediator: Bool, completion: @escaping (Bool,String,Error?) -> Void){ //Success,didDocRecordId,error
        let value = [
            "@context" : "https://w3id.org/did/v1",
            "id": "did:sov:\(theirDid)",
            "publicKey": [
                [
                    "id" : "did:sov:\(theirDid)#1",
                    "type": "Ed25519VerificationKey2018",
                    "controller": "did:sov:\(theirDid)",
                    "publicKeyBase58": "\(recipientKey)"
                ]
            ],
            "authentication": [
                [
                    "type" : "Ed25519SignatureAuthentication2018",
                    "publicKey": "did:sov:\(theirDid)#1"
                ]
            ],
            "service": [
                [
                    "id" : "did:sov:\(theirDid);indy",
                    "type": "IndyAgent",
                    "priority": 0,
                    "routingKeys":[
                        "\(routingKey)"
                    ],
                    "recipientKeys": [
                        "\(recipientKey)"
                    ],
                    "serviceEndpoint": "\(serviceEndPoint)"
                ]
            ]
        ] as [String : Any?]
        
        let tagJson = [
            "did": "\(theirDid)",
            "invitation_key": invitationKey
        ] as [String : Any?]
        
        let didDocRecordId = AgentWrapper.shared.generateRandomId_BaseUID4()
        
        AgentWrapper.shared.addWalletRecord(inWallet: walletHandler, type: isMediator ? AriesAgentFunctions.mediatorDidDoc : AriesAgentFunctions.cloudAgentDidDoc, id: didDocRecordId , value: UIApplicationUtils.shared.getJsonString(for: value), tagsJson: UIApplicationUtils.shared.getJsonString(for: tagJson)) { (error) in
            if(error?._code == 0){
                print("did doc record saved")
                completion(true,didDocRecordId,error)
            } else {
                completion(false,didDocRecordId,error)
            }
            
        }
    }
    
    func addWalletRecord_DidKey(walletHandler: IndyHandle, theirDid: String, recipientKey: String,isMediator: Bool, completion: @escaping (Bool,String,Error?) -> Void){ //Success,didDocRecordId,error
        let value = [
            "their_did": "\(theirDid)", "their_Key": "\(recipientKey)"
        ] as [String : Any?]
        let tagJson = [
            "did": "\(theirDid)", "key": "\(recipientKey)"
        ] as [String : Any?]
        
        let didDocRecordId = AgentWrapper.shared.generateRandomId_BaseUID4()
        
        AgentWrapper.shared.addWalletRecord(inWallet: walletHandler, type: isMediator ? AriesAgentFunctions.mediatorDidKey : AriesAgentFunctions.cloudAgentDidKey, id: didDocRecordId , value:  UIApplicationUtils.shared.getJsonString(for: value), tagsJson: UIApplicationUtils.shared.getJsonString(for: tagJson)) { (error) in
            if(error?._code == 0){
                print("did doc record saved")
                completion(true,didDocRecordId,error)
            } else {
                completion(false,didDocRecordId,error)
            }
            
        }
    }
    
    func deleteWalletRecord(walletHandler: IndyHandle,type: String, id: String,completion: @escaping(Bool,Error?) -> Void) {
        AgentWrapper.shared.deleteWalletRecord(inWallet: walletHandler, type: type, id: id, completion: { (error) in
            if(error?._code == 0) {
                print("did doc record saved")
                completion(true,error)
            } else {
                completion(false,error)
            }
        })
    }
   
    func forwardMessagePack(walletHandler: IndyHandle,message: Data,recipient_key: String,routingKey: [String], myVerKey:String,count:Int = 0, completion: @escaping (Bool,Data?,Error?) -> Void) {
      
        var messageDict = [String : Any?]()
        let message = String(decoding: message, as: UTF8.self)
        messageDict = [
                    "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/routing/1.0/forward",
                    "@id": AgentWrapper.shared.generateRandomId_BaseUID4(),
            "to": count == 0 ? recipient_key : routingKey[count - 1],
            "msg": UIApplicationUtils.shared.convertToDictionary(text: message)
            ]
        let messageJsonString = UIApplicationUtils.shared.getJsonString(for: messageDict)
        let messageData = Data(messageJsonString.utf8)
        
        AgentWrapper.shared.packMessage(message: messageData, myKey: myVerKey, recipientKey: "[\"\(routingKey[count])\"]", walletHandle: walletHandler) { (error, data) in
            print("pack message")
           
            if count == routingKey.count - 1 {
                if(error?._code != 0) {
                    completion(false,data,error)
                    return;
                }
                completion(true,data,error)
            } else {
                self.forwardMessagePack(walletHandler: walletHandler, message: data ?? Data(), recipient_key: recipient_key, routingKey: routingKey, myVerKey: myVerKey,count: count + 1, completion: completion)
        }
    }
    }
}

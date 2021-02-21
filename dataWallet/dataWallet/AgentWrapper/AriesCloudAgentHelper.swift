//
//  AriesAgentHelper.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 18/12/20.
//

import Foundation
import SVProgressHUD

struct AriesCloudAgentHelper{
    static var shared = AriesCloudAgentHelper()
    static var onTrustPingSuccessBlock : ((CloudAgentConnectionWalletModel?,String?,String?)-> Void)?
    private init(){}
    private static var routerKey:[String]?
    private static var OrgID: String?
    private static var orgDetails: OrganisationInfoModel?
}

//MARK: CloudAgentConnection

extension AriesCloudAgentHelper {
    
    func newConnectionConfigCloudAgent(walletHandler: IndyHandle, label: String, theirVerKey: String,serviceEndPoint: String, routingKey: [String]?, imageURL: String,pollingEnabled: Bool = true, orgId: String?, orgDetails: OrganisationInfoModel? ,completion: @escaping((CloudAgentConnectionWalletModel?,String?,String?) -> Void)){
        NetworkManager.shared.baseURL = serviceEndPoint
        AriesCloudAgentHelper.onTrustPingSuccessBlock = completion
        AriesCloudAgentHelper.routerKey = routingKey
        AriesCloudAgentHelper.OrgID = orgId
        AriesCloudAgentHelper.orgDetails = orgDetails
//        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .checkExistingConnection, invitationKey: theirVerKey) { (success, searchInvitationHandler, error) in
//            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchInvitationHandler) { (fetchSuccess, results, error) in
//                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: results)
//                let count = resultDict?["totalCount"] as? Int ?? 0
//                if (count > 0){
//                    UIApplicationUtils.showSuccessSnackbar(message: "Connection already existing".localized())
//                    completion(CloudAgentConnectionWalletModel.init(),"","")
//                    return
//                }
                
                AriesAgentFunctions.shared.addWalletRecord(invitationKey: theirVerKey, label: label, serviceEndPoint: serviceEndPoint, connectionRecordId: "",imageURL: imageURL, walletHandler: walletHandler,type: .connection, orgID:orgId, completion: { (addRecord_Connection_Completed, connectionRecordId, error) in
                    if addRecord_Connection_Completed{
                        AriesAgentFunctions.shared.addWalletRecord(invitationKey:theirVerKey,label: label, serviceEndPoint: serviceEndPoint,connectionRecordId: connectionRecordId, reciepientKey: theirVerKey, walletHandler: walletHandler,type: .invitation) { (addWalletRecord_ConnectionInvitation_Completed, connectionInvitationRecordId, error) in
                            if (addWalletRecord_ConnectionInvitation_Completed){
                                AriesAgentFunctions.shared.getWallerRecord(walletHandler: walletHandler,connectionRecordId: connectionRecordId, isMediator: false, completion: { (getWalletRecordSuccessfully, error) in
                                    if getWalletRecordSuccessfully {
                                        AriesAgentFunctions.shared.createAndStoreId(walletHandler: walletHandler) { (createDidSuccess, myDid, verKey,error) in
                                            let myDid = myDid
                                            let myVerKey = verKey
                                            print("verKey \(verKey)")
                                            AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: theirVerKey, myVerKey: myVerKey ?? "", type: .queryIgrantAgent, isRoutingKeyEnabled: false) { (success, data, error) in
                                                NetworkManager.shared.sendMsg(isMediator: false, msgData: data ?? Data()) { (statuscode,responseData) in
//                                                    if statuscode != 200 {
//                                                        if let trustPingSuccess = AriesCloudAgentHelper.onTrustPingSuccessBlock {
//                                                            trustPingSuccess(nil,nil,nil)
//                                                            SVProgressHUD.dismiss()
//                                                            return
//                                                        }
//                                                    }
                                                    if statuscode == 200 {
                                                        AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: responseData ?? Data()) { (success, unpackedData, error) in
                                                            if let messageModel = try? JSONSerialization.jsonObject(with: unpackedData ?? Data(), options: []) as? [String : Any] {
                                                                let msgString = (messageModel)["message"] as? String
                                                                let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "")
                                                                let queryAgentResponseModel = QueryAgentResponseModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? QueryAgentResponseModel
                                                                self.updateWalletRecords(walletHandler: walletHandler, myDid: myDid, verKey: verKey, imageURL: imageURL, isIgrantAgent: (queryAgentResponseModel?.protocols?.count ?? 0 > 0), label: label, recipientKey: theirVerKey, connectionRecordId: connectionRecordId,serviceEndPoint: serviceEndPoint,routingKey: routingKey,pollingEnabled: pollingEnabled)
                                                            }
                                                        }
                                                    } else {
                                                        self.updateWalletRecords(walletHandler: walletHandler, myDid: myDid, verKey: verKey, imageURL: imageURL, isIgrantAgent: false, label: label, recipientKey: theirVerKey, connectionRecordId: connectionRecordId,serviceEndPoint: serviceEndPoint,routingKey: routingKey,pollingEnabled: pollingEnabled)
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
//            }
//        }
    }
    
    func updateWalletRecords(walletHandler: IndyHandle, myDid:String?, verKey:String?, imageURL:String,isIgrantAgent:Bool,label: String, recipientKey: String,connectionRecordId:String,serviceEndPoint: String,routingKey: [String]?,pollingEnabled:Bool ){
        AriesAgentFunctions.shared.setMetadata(walletHandler: walletHandler, myDid: myDid ?? "",verKey:verKey ?? "", completion: { (metaAdded) in
            if(metaAdded){
                AriesAgentFunctions.shared.updateWalletRecord(walletHandler: walletHandler,recipientKey: recipientKey,label: label, type: UpdateWalletType.initialCloudAgent, id: connectionRecordId, theirDid: "", myDid: myDid ?? "",imageURL: imageURL,invitiationKey: recipientKey, isIgrantAgent: isIgrantAgent, routingKey: routingKey,orgID:AriesCloudAgentHelper.OrgID, completion: { (updateWalletRecordSuccess,updateWalletRecordId ,error) in
                    if(updateWalletRecordSuccess){
                        AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler, id: connectionRecordId, myDid: myDid ?? "", theirDid: "",recipientKey: recipientKey,serviceEndPoint: serviceEndPoint, invitiationKey: recipientKey, type: .initialCloudAgent,isIgrantAgent: isIgrantAgent,orgID: AriesCloudAgentHelper.OrgID ?? "",myVerKey: verKey, completion: { (updateWalletTagSuccess, error) in
                            if(updateWalletTagSuccess){
                                self.registerRouter(walletHandler: walletHandler,connectionRecordId: connectionRecordId, verKey: verKey ?? "", myDid: myDid ?? "", recipientKey: recipientKey, label: label,serviceEndPoint: serviceEndPoint, routingKey: routingKey,mediatorVerKey: WalletViewModel.mediatorVerKey ?? "",pollingEnabled: pollingEnabled,isIgrantAgent: isIgrantAgent)
                            }
                        })
                    }
                })
            }
        })
    }
    
    func registerRouter(walletHandler: IndyHandle,connectionRecordId: String,verKey: String, myDid: String, recipientKey: String, label: String,serviceEndPoint: String, routingKey: [String]?, mediatorVerKey: String,pollingEnabled: Bool = true,isIgrantAgent: Bool = false){
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type:
                                                            AriesAgentFunctions.mediatorDidDoc,searchType: .withoutQuery, completion: { (success, searchWalletHandler, error) in
                                                                if (success) {
                                                                    AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchWalletHandler, completion: {
                                                                        (fetchedSuccessfully,results,error) in
                                                                        if (fetchedSuccessfully){
                                                                            let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: results)
                                                                            let docModel = SearchDidDocModel.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? SearchDidDocModel
                                                                            let mediatorRoutingKey = docModel?.records?.first?.value?.service?.first?.routingKeys?.first ?? ""
                                                                            let mediatorRecipientKey = docModel?.records?.first?.value?.service?.first?.recipientKeys?.first ?? ""
                                                                            //let routerKey =
                                                                            AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, label: label, recipientKey: mediatorRecipientKey, id: connectionRecordId, myDid: myDid, myVerKey: mediatorVerKey , serviceEndPoint: serviceEndPoint, routingKey: mediatorRoutingKey , routedestination: verKey, deleteItemId: "", type: .addRoute,isRoutingKeyEnabled: false, externalRoutingKey: []) { (packedSuccessfully, packedData, error) in
                                                                                if packedSuccessfully {
                                                                                    NetworkManager.shared.sendMsg(isMediator: true, msgData: packedData ?? Data()) { (statuscode,recievedData) in
                                                                                        if statuscode != 200 {
                                                                                            if let trustPingSuccess = AriesCloudAgentHelper.onTrustPingSuccessBlock {
                                                                                                trustPingSuccess(nil,nil,nil)
                                                                                                SVProgressHUD.dismiss()
                                                                                                return
                                                                                            }
                                                                                        }
                                                                                        let registerRouterResponse = try? JSONSerialization.jsonObject(with: recievedData ?? Data() , options: [.allowFragments]) as? [String : Any]
                                                                                        
                                                                                        self.getRecordAndConnectForCloudAgent(walletHandler: walletHandler,connectionRecordId: connectionRecordId, verKey: verKey, myDid: myDid, recipientKey: recipientKey, label: label, packageMsgType: .initialCloudAgent, routingKey: mediatorRoutingKey,serviceEndPoint: serviceEndPoint,pollingEnabled: pollingEnabled)
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    })
                                                                }
                                                            })
    }
    
    func getRecordAndConnectForCloudAgent(walletHandler: IndyHandle,connectionRecordId: String,verKey: String, myDid: String, recipientKey: String, label: String, packageMsgType: PackMessageType,routingKey: String, serviceEndPoint: String,pollingEnabled: Bool = true){//routingKey: String,
        AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler,label: label, recipientKey: recipientKey,  id: connectionRecordId, myDid: myDid , myVerKey: verKey ,serviceEndPoint: serviceEndPoint, routingKey: routingKey, deleteItemId: "", type: .initialCloudAgent,isRoutingKeyEnabled: AriesCloudAgentHelper.routerKey?.count ?? 0 > 0, externalRoutingKey: AriesCloudAgentHelper.routerKey ?? [], completion:{ (packMsgSuccess, messageData, error) in
            if (packMsgSuccess){
                NetworkManager.shared.sendMsg(isMediator:false,msgData: messageData ?? Data()) { (statuscode,recievedData) in
                    print("Cloud Agent Request Send")
                    if statuscode != 200 {
                        if let trustPingSuccess = AriesCloudAgentHelper.onTrustPingSuccessBlock {
                            trustPingSuccess(nil,nil,nil)
                            SVProgressHUD.dismiss()
                            return
                        }
                    }
                    AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: recievedData ?? Data(), completion: { (unpackedSuccessfully, unpackedData, error) in
                        if let messageModel = try? JSONSerialization.jsonObject(with: unpackedData ?? Data(), options: []) as? [String : Any] {
                            let msgString = (messageModel)["message"] as? String
                            let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "")
                            //connection~sig
                            let itemType = (msgDict?["@type"] as? String)?.split(separator: "/").last ?? ""
                            let connSigDict = (msgDict)?["connection~sig"] as? [String:Any]
                            
                            let sigDataBase64String = (connSigDict)?["sig_data"] as? String
                            let sigDataString = sigDataBase64String?.decodeBase64_first8bitRemoved()
                            let sigDataDict = UIApplicationUtils.shared.convertToDictionary(text: sigDataString ?? "") ?? [String:Any]()
                            let recipient_verkey = (messageModel)["recipient_verkey"] as? String ?? ""
                            let sender_verkey = (messageModel)["sender_verkey"] as? String ?? ""
                            AriesCloudAgentHelper.shared.addWalletRecord_CloudAgent(walletHandle: walletHandler, connectionRecordId: connectionRecordId,verKey: recipient_verkey, recipientKey: sender_verkey,  packageMsgType: .initialCloudAgent, sigDataDict:sigDataDict as [String : Any])
                        }
                    })
                }
            }
        })
    }
    
    func addWalletRecord_CloudAgent(walletHandle: IndyHandle?,connectionRecordId: String,verKey: String, recipientKey: String, packageMsgType: PackMessageType, sigDataDict: [String:Any]?){
        let walletHandler = walletHandle ?? 0
        
        if let sigDataDict = sigDataDict {
            
            let theirDid = sigDataDict["DID"] as? String ?? ""
            let dataDic = ((sigDataDict["DIDDoc"] as? [String:Any])?["service"] as? [[String:Any]])?.first
            let senderVerKey = (dataDic?["recipientKeys"] as? [String])?.first ?? ""
            let serviceEndPoint = (dataDic?["serviceEndpoint"] as? String) ?? ""
            let routingKey = (dataDic?["serviceEndpoint"] as? String) ?? ""
            if let externalRoutingKey = (dataDic?["routingKeys"] as? [String]) {
                AriesCloudAgentHelper.routerKey = externalRoutingKey
            }
            NetworkManager.shared.baseURL = serviceEndPoint
            
            AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithMyVerKey, myVerKey: verKey) { (searchCompleted, searchedWalletHandler, error) in
                AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchedWalletHandler) { (searchCompleted, results, error) in
                    if let messageModel = UIApplicationUtils.shared.convertToDictionary(text: results,boolKeys: ["delete"]) {
                        let requestArray = messageModel["records"] as? [[String:Any]] ?? []
                        let requestDict = requestArray.first?["value"] as? [String:Any]
                        let request_id = requestDict?["request_id"] as? String ?? ""
                        let myDid_cloudAgent =  requestDict?["my_did"] as? String ?? ""
                        let label_cloudAgent =  requestDict?["their_label"] as? String ?? ""
                        let isIgrantAgent = requestDict?["isIgrantAgent"] as? String ?? "0"
                        let invitationKey = requestDict?["invitation_key"] as? String ?? ""
                        let imageUrl = requestDict?["imageURL"] as? String ?? ""
                        AriesAgentFunctions.shared.addWalletRecord_DidDoc(walletHandler: walletHandler, invitationKey: invitationKey, theirDid: theirDid , recipientKey: senderVerKey , serviceEndPoint: serviceEndPoint, routingKey: routingKey , isMediator: false, completion: { (didDocRecordAdded, didDocRecordId, error) in
                            if (didDocRecordAdded){
                                AriesAgentFunctions.shared.addWalletRecord_DidKey(walletHandler: walletHandler, theirDid: theirDid, recipientKey: senderVerKey, isMediator: false, completion: { (didKeyRecordAdded, didKeyRecordId, error) in
                                    
                                    AriesAgentFunctions.shared.updateWalletRecord(walletHandler: walletHandler,recipientKey: senderVerKey,label: label_cloudAgent, type: .updateCloudAgentRecord, id: request_id, theirDid: theirDid, myDid: myDid_cloudAgent ,imageURL: imageUrl,invitiationKey: invitationKey, isIgrantAgent: isIgrantAgent == "1", routingKey: AriesCloudAgentHelper.routerKey ?? [],orgID: AriesCloudAgentHelper.OrgID ,completion: { (updatedSuccessfully, updatedRecordId, error) in
                                                                                    if(updatedSuccessfully){
                                                                                        AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler, id: request_id, myDid: myDid_cloudAgent ,
                                                                                                                                    theirDid: theirDid, recipientKey: senderVerKey, serviceEndPoint: serviceEndPoint,invitiationKey: invitationKey, type: .updateCloudAgentTag,isIgrantAgent: isIgrantAgent == "1",orgID: AriesCloudAgentHelper.OrgID ?? "",myVerKey: verKey, completion: { (updatedSuccessfully, error) in
                                                                                                                                        if (updatedSuccessfully){
                                                                                                                                            print("Cloud Agent Added")
                                                                                                                                            AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: myDid_cloudAgent) { (getMetaSuccessfully, metadata, error) in
                                                                                                                                                let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                                                                                                                                                if let cloud_verKey = metadataDict?["verkey"] as? String{
                                                                                                                                                    self.trustPing(walletHandle: walletHandle, connectionRecordId: request_id, verKey: cloud_verKey, myDid: myDid_cloudAgent, recipientKey: senderVerKey, label: label_cloudAgent, packageMsgType: .trustPing, routingKey: routingKey, serviceEndPoint: serviceEndPoint)
                                                                                                                                                }
                                                                                                                                            }
                                                                                                                                        }
                                                                                                                                    })
                                                                                    }
                                                                                  })
                                })
                                
                            }
                        })
                    }
                }
            }
        }
    }
    
    func trustPing(walletHandle: IndyHandle?,connectionRecordId: String,verKey: String, myDid: String, recipientKey: String, label: String, packageMsgType: PackMessageType, routingKey: String, serviceEndPoint: String){
        let walletHandler = walletHandle ?? 0
        print("recipientKey - ping send \(recipientKey)")
        print("verKey - ping send \(verKey)")
        AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, label: label, recipientKey: recipientKey, id: connectionRecordId, myDid: myDid, myVerKey: verKey, serviceEndPoint: serviceEndPoint, routingKey: routingKey,deleteItemId: "", type: .trustPing,isRoutingKeyEnabled: AriesCloudAgentHelper.routerKey?.count ?? 0 > 0, externalRoutingKey: AriesCloudAgentHelper.routerKey ?? []) { (packedSuccessfully, packedData, error) in
            NetworkManager.shared.sendMsg(isMediator: false, msgData: packedData ?? Data()) { (statuscode,responseData) in
                if statuscode != 200 {
                    if let trustPingSuccess = AriesCloudAgentHelper.onTrustPingSuccessBlock {
//                        trustPingSuccess(nil,nil,nil)
//                        SVProgressHUD.dismiss()
                        pingResponseHandler(walletHandle: walletHandler, verKey: verKey, recipientKey: recipientKey)
                        return
                    }
                }
                print("Ping send")
            }
        }
    }
    
    func pingResponseHandler(walletHandle: IndyHandle?, verKey: String, recipientKey: String) {
        let walletHandler = walletHandle ?? 0
        
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithReciepientKey, serviceEndPoint: "", reciepientKey: recipientKey) { (searchCompleted, searchedWalletHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchedWalletHandler) { (searchCompleted, results, error) in
                if let messageModel = UIApplicationUtils.shared.convertToDictionary(text: results,boolKeys: ["delete"]){
                    let records = messageModel["records"] as? [[String:Any]]
                    let firstRecord = records?.first
                    let connectionModel = CloudAgentConnectionWalletModel.decode(withDictionary: firstRecord as NSDictionary? ?? NSDictionary()) as? CloudAgentConnectionWalletModel
                    self.getiGrantOrgDetails(walletHandle: walletHandler, reqId: connectionModel?.id ?? "") { (success, orgModel) in
                        AriesAgentFunctions.shared.updateWalletRecord(walletHandler: walletHandler,recipientKey: recipientKey,label: connectionModel?.value?.theirLabel ?? "", type: .trusted, id: connectionModel?.value?.requestID ?? "", theirDid: connectionModel?.value?.theirDid ?? "", myDid: connectionModel?.value?.myDid ?? "" ,imageURL: connectionModel?.value?.imageURL ?? "",invitiationKey: connectionModel?.value?.invitationKey, isIgrantAgent: connectionModel?.value?.isIgrantAgent == "1",orgDetails: orgModel,orgID: AriesCloudAgentHelper.OrgID, completion: { (updatedSuccessfully, updatedRecordId, error) in
                            if(updatedSuccessfully){
                                AriesAgentFunctions.shared.updateWalletTags(walletHandler: walletHandler, id: updatedRecordId, myDid: connectionModel?.value?.myDid ?? "", theirDid: connectionModel?.value?.theirDid ?? "", recipientKey: recipientKey, serviceEndPoint: "", invitiationKey: connectionModel?.value?.invitationKey, type: .cloudAgentActive,orgID: AriesCloudAgentHelper.OrgID, myVerKey: connectionModel?.tags?.myVerKey) { (tagUpdated, error) in
                                    if (tagUpdated){
                                        print("Cloud Agent Trusted")
                                        if let trustPingSuccess = AriesCloudAgentHelper.onTrustPingSuccessBlock,let connctnModel = connectionModel {
                                            trustPingSuccess(connctnModel,recipientKey,verKey)
                                        }else{
                                            print("No Popup completion method available")
                                        }
                                    }
                                }}
                        })
                    }
                }
            }
        }
    }
    
    func getiGrantOrgDetails(walletHandle: IndyHandle?, reqId: String, completion:@escaping((Bool,OrganisationInfoModel?) -> Void)) {
        
        if let details = AriesCloudAgentHelper.orgDetails {
            completion(true,details)
            return
        }
        let walletHandler = walletHandle ?? 0
        
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithId, record_id: reqId ) { (success, searchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) { (success, invResult, error) in
                let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: invResult,boolKeys: ["delete"])
                let searchConnModel = CloudAgentSearchConnectionModel.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? CloudAgentSearchConnectionModel
                let connModel = searchConnModel?.records?.first
                AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: connModel?.value?.myDid ?? "", completion: { (metadataRecieved,metadata, error) in
                    let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                    if let verKey = metadataDict?["verkey"] as? String{
                        
                        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnectionInvitation, searchType: .searchWithId,record_id: connModel?.value?.requestID ?? "") { (success, searchHandler, error) in
                            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) { (searchSuccess, records, error) in
                                let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: records)
                                let invitationRecord = (resultsDict?["records"] as? [[String: Any]])?.first
                                let serviceEndPoint = (invitationRecord?["value"] as? [String: Any])?["serviceEndpoint"] as? String ?? ""
                                let externalRoutingKey = (invitationRecord?["value"] as? [String: Any])?["routing_key"] as? String ?? ""
                                NetworkManager.shared.baseURL = serviceEndPoint
                                AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: connModel?.value?.reciepientKey ?? "", myVerKey: verKey, type: .getIgrantOrgDetail,isRoutingKeyEnabled: false) { (success, orgPackedData, error) in
                                    NetworkManager.shared.sendMsg(isMediator: false, msgData: orgPackedData ?? Data()) { (statuscode,orgServerResponseData) in
                                        if statuscode != 200 {
                                                completion(false,nil)
                                                return
                                        }
                                        AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: orgServerResponseData ?? Data()) { (unpackedSuccessfully, orgDetailsData, error) in
                                            if let messageModel = try? JSONSerialization.jsonObject(with: orgDetailsData ?? Data(), options: []) as? [String : Any] {
                                                print("unpackmsg -- \(messageModel)")
                                                let msgString = (messageModel)["message"] as? String
                                                let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "",boolKeys: ["delete"])
                                                let recipient_verkey = (messageModel)["recipient_verkey"] as? String ?? ""
                                                let sender_verkey = (messageModel)["sender_verkey"] as? String ?? ""
                                                print("Org details recieved")
                                                let orgInfoModel = OrganisationInfoModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? OrganisationInfoModel
                                                completion(true,orgInfoModel)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    func checkConnectionWithSameOrgExist(walletHandler: IndyHandle, label: String, theirVerKey: String,serviceEndPoint: String, routingKey: [String]?, imageURL: String,pollingEnabled: Bool = true,isFromDataExchange: Bool,completion: @escaping((Bool,OrganisationInfoModel?,CloudAgentConnectionWalletModel?) -> Void)){
        AriesCloudAgentHelper.orgDetails = nil
        AriesCloudAgentHelper.OrgID = nil
        AriesAgentFunctions.shared.createAndStoreId(walletHandler: walletHandler) { (createDidSuccess, myDid, verKey,error) in
//            let myDid = myDid
            let myVerKey = verKey
            print("verKey \(verKey)")
            AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: theirVerKey, myVerKey: myVerKey ?? "", type: .queryIgrantAgent, isRoutingKeyEnabled: false) { (success, data, error) in
                NetworkManager.shared.baseURL = serviceEndPoint
                NetworkManager.shared.sendMsg(isMediator: false, msgData: data ?? Data()) { (statuscode,responseData) in
                    if statuscode != 200 {
                        completion(false,nil,nil)
                        SVProgressHUD.dismiss()
                        return
                    }
                    if statuscode == 200 {
                        AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: responseData ?? Data()) { (success, unpackedData, error) in
                            if let messageModel = try? JSONSerialization.jsonObject(with: unpackedData ?? Data(), options: []) as? [String : Any] {
                                let msgString = (messageModel)["message"] as? String
                                let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "")
                                let queryAgentResponseModel = QueryAgentResponseModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? QueryAgentResponseModel
                                if (queryAgentResponseModel?.protocols?.count ?? 0 > 0){
                                    AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey:theirVerKey, myVerKey: myVerKey ?? "", type: .getIgrantOrgDetail,isRoutingKeyEnabled: false) { (success, orgPackedData, error) in
                                        NetworkManager.shared.sendMsg(isMediator: false, msgData: orgPackedData ?? Data()) { (statuscode,orgServerResponseData) in
                                            if statuscode != 200 {
                                                completion(false,nil,nil)
                                                SVProgressHUD.dismiss()
                                                return
                                            }
                                            AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: orgServerResponseData ?? Data()) { (unpackedSuccessfully, orgDetailsData, error) in
                                                if let messageModel = try? JSONSerialization.jsonObject(with: orgDetailsData ?? Data(), options: []) as? [String : Any] {
                                                    print("unpackmsg -- \(messageModel)")
                                                    let msgString = (messageModel)["message"] as? String
                                                    let msgDict = UIApplicationUtils.shared.convertToDictionary(text: msgString ?? "",boolKeys: ["delete"])
                                                    let recipient_verkey = (messageModel)["recipient_verkey"] as? String ?? ""
                                                    let sender_verkey = (messageModel)["sender_verkey"] as? String ?? ""
                                                    print("Org details recieved")
                                                    let orgDetail = OrganisationInfoModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? OrganisationInfoModel
                                             
                                        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithOrgId,orgID: orgDetail?.orgId ?? "") { (success, searchHandler, error) in
                                            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) { (success, response, error) in
                                                if let messageModel = UIApplicationUtils.shared.convertToDictionary(text: response,boolKeys: ["delete"]){
                                                    let records = messageModel["records"] as? [[String:Any]]
                                                    let count = messageModel["totalCount"] as? Int ?? 0
                                                    let firstRecord = records?.first
                                                    let connectionModel = CloudAgentConnectionWalletModel.decode(withDictionary: firstRecord as NSDictionary? ?? NSDictionary()) as? CloudAgentConnectionWalletModel
                                                    if (count > 0){
                                                        if !isFromDataExchange {
                                                            UIApplicationUtils.showSuccessSnackbar(message: "Connection already existing".localized())
                                                        }
                                                        AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: theirVerKey, myVerKey: myVerKey ?? "", type: .informDuplicateConnection, isRoutingKeyEnabled: false,theirDid: connectionModel?.value?.theirDid ?? "") { (success, data, error) in
//                                                            print("Informed duplicate connection to server")
//                                                            completion(false,nil,connectionModel)
                                                            NetworkManager.shared.sendMsg(isMediator: false, msgData: data ?? Data()) { (statuscode,responseData) in
                                                                if statuscode != 200 {
                                                                    completion(false,nil,nil)
                                                                    SVProgressHUD.dismiss()
                                                                    return
                                                                }
                                                                if statuscode == 200 {
                                                                    print("Informed duplicate connection to server")
                                                                    completion(true,nil,connectionModel)
                                                                    return
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        completion(false,orgDetail,connectionModel)
                                                        return
                                                    }
                                                } else {
                                                    completion(false,nil,nil)
                                                    return
                                                }
                                            }
                                        }
                                                }
                                            }
                                        }
                                    }
                                    } else {
                                        completion(false,nil,nil)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
}



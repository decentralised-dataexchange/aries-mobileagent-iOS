//
//  IgrantAgentOrgDetailViewModel.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 21/12/20.
//

import Foundation
import SVProgressHUD

protocol IgrantAgentOrgDetailViewModelDelegate: class {
    func goBack()
}

class IgrantAgentOrgDetailViewModel {
    var walletHandle: IndyHandle?
    var reqId : String?
    var certificates: [InboxModelRecord]?
    var orgInfo: OrganisationInfoModel?
    var orgCertListModel: OrganisationListDataCERTModel?
    weak var delegate: IgrantAgentOrgDetailViewModelDelegate?
    var isiGrantOrg: Bool = false
    var connectionModel: CloudAgentConnectionWalletModel?
    private var connectionInvitationRecordId: String?

    init(walletHandle: IndyHandle?,reqId: String?,isiGrantOrg: Bool?) {
        self.walletHandle = walletHandle
        self.reqId = reqId
        self.isiGrantOrg = isiGrantOrg ?? false
    }
    
    func fetchCertificates(completion: @escaping (Bool) -> Void) {
        let walletHandler = self.walletHandle ?? IndyHandle()
        SVProgressHUD.show()
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .searchWithId, record_id: self.reqId ?? "") {[unowned self] (success, searchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) {[unowned self] (success, invResult, error) in
                let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: invResult,boolKeys: ["delete"])
                let searchConnModel = CloudAgentSearchConnectionModel.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? CloudAgentSearchConnectionModel
                let connModel = searchConnModel?.records?.first
                self.connectionModel = connModel
                completion(true)  // reaload view with connection data
                AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler, myDid: connModel?.value?.myDid ?? "", completion: { [unowned self](metadataRecieved,metadata, error) in
                    let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                    if let verKey = metadataDict?["verkey"] as? String{
                      
                            AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnectionInvitation, searchType: .searchWithId,record_id: connModel?.value?.requestID ?? "") { [unowned self](success, searchHandler, error) in
                                AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler) { [unowned self](searchSuccess, records, error) in
                                    let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: records)
                                    let invitationRecord = (resultsDict?["records"] as? [[String: Any]])?.first
                                    let serviceEndPoint = (invitationRecord?["value"] as? [String: Any])?["serviceEndpoint"] as? String ?? ""
                                    let externalRoutingKey = (invitationRecord?["value"] as? [String: Any])?["routing_key"] as? [String] ?? []
                                    self.connectionInvitationRecordId = (invitationRecord?["value"] as? [String: Any])?["@id"] as? String ?? ""
                                    NetworkManager.shared.baseURL = serviceEndPoint
                                    AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: connModel?.value?.reciepientKey ?? "", myVerKey: verKey, type: .getIgrantOrgDetail,isRoutingKeyEnabled: false) {[unowned self] (success, orgPackedData, error) in
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
                                                let orgInfoModel = OrganisationInfoModel.decode(withDictionary: msgDict as NSDictionary? ?? NSDictionary()) as? OrganisationInfoModel
                                                self.orgInfo = orgInfoModel
                                                
                                                //Get cert list
                                                AriesAgentFunctions.shared.packMessage(walletHandler: walletHandler, recipientKey: connModel?.value?.reciepientKey ?? "", myVerKey: verKey, type: .getIgrantCertTypeResponse,isRoutingKeyEnabled: false) {[unowned self] (certListSuccess, certListData, error) in
                                                    NetworkManager.shared.sendMsg(isMediator: false, msgData: certListData ?? Data()) {[unowned self] (statuscode,certListServerResponse) in
                                                       
                                                        AriesAgentFunctions.shared.unpackMessage(walletHandler: walletHandler, messageData: certListServerResponse ?? Data()) { [unowned self](certListUnpackedSuccess, certListUnpackedData, error) in
                                                            
                                                            if let certListUnpackedResponseModel = try? JSONSerialization.jsonObject(with: certListUnpackedData ?? Data(), options: []) as? [String : Any] {
                                                                let certListString = (certListUnpackedResponseModel)["message"] as? String
                                                                let certListDict = UIApplicationUtils.shared.convertToDictionary(text: certListString ?? "")
                                                                let certListModel = OrganisationListDataCERTModel.decode(withDictionary: certListDict as NSDictionary? ?? NSDictionary()) as? OrganisationListDataCERTModel
                                                                self.orgCertListModel = certListModel
                                                                print("Org List Data cert")
                                                                AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, searchType: .inbox_offerRecieved, record_id: self.reqId ?? "") {[unowned self] (success, searchHandle, error) in
                                                                    AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandle,count: 100) {[unowned self] (success, response, error) in
                                                                        let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: response,boolKeys: ["auto_present","trace","auto_offer","auto_issue","auto_remove"])
                                                                        let resultModel = SearchInboxModel.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? SearchInboxModel
                                                                        let records = resultModel?.records
                                                                        self.certificates = records
                                                                        for cert in self.orgCertListModel?.dataCertificateTypes ?? []{
                                                                            let tempArray =   self.certificates?.filter({ (element) -> Bool in
                                                                                return element.value?.offerCredential?.value?.schemaID == cert.schemaID
                                                                            })
                                                                            if tempArray?.count ?? 0 > 0 {
                                                                                cert.offerAvailable = true
                                                                                cert.certificates = tempArray?.first
                                                                                cert.attrArray = tempArray?.first?.value?.offerCredential?.value?.credentialProposalDict?.credentialProposal?.attributes ?? []
                                                                            } else {
                                                                                cert.offerAvailable = false
                                                                                var attr: [SearchCertificateAttribute] = []
                                                                                for item in cert.schemaAttributes ?? []{
                                                                                    attr.append(SearchCertificateAttribute.init(name: item, value: ""))
                                                                                }
                                                                                cert.attrArray = attr
                                                                            }
                                                                        }
                                                                        completion(true)
                                                                        SVProgressHUD.dismiss()
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
                        }
                    }
                    
                })
                
            }
        }
    }
    
    func deleteOrg() {
        let walletHandler = self.walletHandle ?? IndyHandle()
        SVProgressHUD.show()
        var numberOfBlockCompleted = 0
        
        //Use dispatch Queue - future improvements
        
        //delete didDoc
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentDidDoc, searchType: .searchWithTheirDid,theirDid: self.connectionModel?.value?.theirDid ?? "") {[unowned self] (success, searchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler, count: 1) {[unowned self] (success, response, error) in
                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: response)
                let didDocModel = SearchDidDocModel.decode(withDictionary: resultDict as NSDictionary? ?? NSDictionary()) as? SearchDidDocModel
                AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type:AriesAgentFunctions.cloudAgentDidDoc , id: didDocModel?.records?.first?.value?.id ?? "") { [unowned self](success, error) in
                    print("delete didDoc")
                    numberOfBlockCompleted += 1
                    self.deletedSuccessfully(count: numberOfBlockCompleted)
                }
            }
        }
        
        //delete didKey
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentDidKey, searchType: .searchWithTheirDid,theirDid: self.connectionModel?.value?.theirDid ?? "") { [unowned self](success, searchHandler, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler, count: 1) {[unowned self] (success, response, error) in
                let resultDict = UIApplicationUtils.shared.convertToDictionary(text: response)
                let record = (resultDict?["records"] as? [[String: Any]])?.first
                let id = (record?["value"] as? [String: Any])?["@id"] as? String ?? ""
                AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type:AriesAgentFunctions.cloudAgentDidKey , id: id ) { [unowned self](success, error) in
                    print("delete didkey")
                    numberOfBlockCompleted += 1
                    self.deletedSuccessfully(count: numberOfBlockCompleted)
                }
            }
        }
        
        //delete certType
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.certType, searchType: .searchWithId, record_id: self.reqId ?? "") { [unowned self](success, searchHandler, error) in
                AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler, count: 1000) { [unowned self](success, result, error) in
                    let resultDict = UIApplicationUtils.shared.convertToDictionary(text: result)
                    let certificatedModel = SearchCertificateResponse.decode(withDictionary: resultDict as NSDictionary? ?? NSDictionary()) as? SearchCertificateResponse
                    if certificatedModel?.totalCount == 0 {
                        print("delete notifications")
                        numberOfBlockCompleted += 1
                        self.deletedSuccessfully(count: numberOfBlockCompleted)
                        return
                    }
                    var count = 1
                    for item in certificatedModel?.records ?? [] {
                        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, id: item.id ?? "") { [unowned self](deletedSuccessfully, error) in
                            if count == certificatedModel?.records?.count ?? 2 - 1 {
                                print("delete certType")
                                numberOfBlockCompleted += 1
                                self.deletedSuccessfully(count: numberOfBlockCompleted)
                            }
                            count += 1
                        }
                    }
                }
            }
        
        //delete presentationExchange
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.presentationExchange, searchType: .searchWithId, record_id: self.reqId ?? "") {[unowned self] (success, searchHandler, error) in
                AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler, count: 1000) { [unowned self](success, result, error) in
                    let resultDict = UIApplicationUtils.shared.convertToDictionary(text: result)
                    let presentationExchangeModel = SearchPresentationExchangeModel.decode(withDictionary: resultDict as NSDictionary? ?? NSDictionary()) as? SearchPresentationExchangeModel
                    if presentationExchangeModel?.totalCount == 0 {
                        print("delete notifications")
                        numberOfBlockCompleted += 1
                        self.deletedSuccessfully(count: numberOfBlockCompleted)
                        return
                    }
                    var count = 1
                    for item in presentationExchangeModel?.records ?? [] {
                        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, id: item.id ?? "") {[unowned self] (deletedSuccessfully, error) in
                            if count == presentationExchangeModel?.records?.count ?? 2 - 1 {
                                print("delete presentationExchange")
                                numberOfBlockCompleted += 1
                                self.deletedSuccessfully(count: numberOfBlockCompleted)
                            }
                            count += 1
                        }
                    }
                }
            }
        
        //delete notifications
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, searchType: .searchWithId, record_id: self.reqId ?? "") { [unowned self](success, searchHandler, error) in
                AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandler, count: 1000) {[unowned self] (success, result, error) in
                    let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: result,boolKeys: ["auto_present","trace","auto_offer","auto_issue"])
                    let searchInboxModel = SearchInboxModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? SearchInboxModel
                    if searchInboxModel?.totalCount == 0 {
                        print("delete notifications")
                        numberOfBlockCompleted += 1
                        self.deletedSuccessfully(count: numberOfBlockCompleted)
                        return
                    }
                    var count = 1
                    for item in searchInboxModel?.records ?? [] {
                        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, id: item.id ?? "") { [unowned self](deletedSuccessfully, error) in
                            if count == searchInboxModel?.records?.count ?? 2 - 1 {
                                print("delete notifications")
                                numberOfBlockCompleted += 1
                                self.deletedSuccessfully(count: numberOfBlockCompleted)
                            }
                            count += 1
                        }
                    }
                }
            }
    }
    
    func deletedSuccessfully(count: Int){
        if count != 5 {
            return
        }
        print("deleted all")
        let walletHandler = self.walletHandle ?? IndyHandle()
        //delete Connection
        AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, id: self.reqId ?? "") {[unowned self] (deletedSuccessfully, error) in
            //delete connection Invitation
            AriesAgentFunctions.shared.deleteWalletRecord(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnectionInvitation, id: self.connectionInvitationRecordId ?? "") { [unowned self](success, error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    SVProgressHUD.dismiss()
                    UIApplicationUtils.showSuccessSnackbar(message: "Organisation removed successfully".localized())
                    self.delegate?.goBack()
                }) 
            }
        }
    }
}

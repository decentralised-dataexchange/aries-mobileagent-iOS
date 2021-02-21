//
//  OrganisationListViewModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 07/12/20.
//

import Foundation

protocol OrganisationListDelegate: class {
    func reloadData()
}

class OrganisationListViewModel {
    var walletHandle: IndyHandle?
    var connections: [SearchConnectionRecord]?
    var connectionHelper = AriesAgentFunctions.shared
    var mediatorVerKey: String?
    var searchedConnections: [SearchConnectionRecord]?
    weak var delegate: OrganisationListDelegate?
    
    init(walletHandle: IndyHandle?,mediatorVerKey: String?) {
        self.walletHandle = walletHandle
        self.mediatorVerKey = mediatorVerKey ?? ""
    }
    
    func fetchOrgList(completion: @escaping (Bool) -> Void) {
        let walletHandler = self.walletHandle ?? IndyHandle()
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.cloudAgentConnection, searchType: .getActiveConnections) {[unowned self] (success, searchHandle, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: searchHandle,count: 100) {[unowned self] (success, response, error) in
                let resultsDict = UIApplicationUtils.shared.convertToDictionary(text: response,boolKeys: ["delete"])
                let resultModel = SearchConnectionResponse.decode(withDictionary: resultsDict as NSDictionary? ?? NSDictionary()) as? SearchConnectionResponse
                if let records = resultModel?.records {
                    self.connections = records
                    self.searchedConnections = records
                    completion(true)
                }else{
                    self.connections = []
                    self.searchedConnections = []
                    completion(false)
                }
            }
        }
    }
    
    func newConnectionConfigCloudAgent(label: String, theirVerKey: String,serviceEndPoint: String, routingKey: [String], imageURL: String,completion:@escaping(Bool)-> Void) {
        let walletHandler = self.walletHandle ?? IndyHandle()
        ConnectionPopupViewController.showConnectionPopup(orgName: label, orgImageURL: imageURL, walletHandler: walletHandler, recipientKey: theirVerKey, serviceEndPoint: serviceEndPoint, routingKey: routingKey, isFromDataExchange: false) { [unowned self] (connModel,recipientKey,myVerKey) in
            completion(true)
        }
    }
    
    func updateSearchedItems(searchString: String){
        if searchString == "" {
            self.searchedConnections = connections
            delegate?.reloadData()
            return
        }
        let filteredArray = self.connections?.filter({ (item) -> Bool in
            return (item.value?.theirLabel?.contains(searchString)) ?? false
        })
        self.searchedConnections = filteredArray
        delegate?.reloadData()
        return
    }
    
    deinit {
        print("Org obj removed from memory")
    }
}

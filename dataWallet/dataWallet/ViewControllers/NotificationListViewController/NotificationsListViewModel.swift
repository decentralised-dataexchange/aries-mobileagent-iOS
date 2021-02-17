//
//  ExchangeDataListViewModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 14/12/20.
//

import Foundation

class NotificationsListViewModel{
    var walletHandle: IndyHandle?
    var notifications: [InboxModelRecord]?

    init(walletHandle: IndyHandle?) {
        self.walletHandle = walletHandle
    }
    
    func fetchNotifications(completion: @escaping (Bool) -> Void) {
        let walletHandler = self.walletHandle ?? IndyHandle()
        AriesAgentFunctions.shared.openWalletSearch_type(walletHandler: walletHandler, type: AriesAgentFunctions.inbox, searchType:.withoutQuery) { [unowned self](success, prsntnExchngSearchWallet, error) in
            AriesAgentFunctions.shared.fetchWalletSearchNextRecords(walletHandler: walletHandler, searchWalletHandler: prsntnExchngSearchWallet, count: 100) {[unowned self] (success, response, error) in
                let recordResponse = UIApplicationUtils.shared.convertToDictionary(text: response,boolKeys: ["auto_present","trace","auto_offer","auto_issue"])
                let searchInboxModel = SearchInboxModel.decode(withDictionary: recordResponse as NSDictionary? ?? NSDictionary()) as? SearchInboxModel
                if let records = searchInboxModel?.records {
                    self.notifications = records
                    completion(true)
                }else{
                    self.notifications = []
                    completion(false)
                }
            }
        }
    }
    
}

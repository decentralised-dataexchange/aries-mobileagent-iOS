//
//  AgentWrapper.swift
//  Indy_Demo
//
//  Created by Mohamed Rebin on 16/10/20.
//

import Foundation
import UIKit

class AgentWrapper {
    static let shared = AgentWrapper()
    let wallet = IndyWallet.sharedInstance()
    var transport: TransportMode?
    private init() {}
    
    func createWallet(withConfig: String, credentials: String, completion: @escaping (Error?) -> Void) {
        wallet?.createWallet(withConfig: withConfig, credentials: credentials, completion: completion)
    }
    
    func openWallet(withConfig: String, credentials: String, completion: @escaping (Error?,IndyHandle) -> Void) {
        wallet?.open(withConfig: withConfig,credentials: credentials,completion: completion)
    }
    
    func closeWallet(withHandle: IndyHandle,completion: @escaping (Error?) -> Void) {
        wallet?.close(withHandle: withHandle, completion: completion)
    }
    
    func createAndStoreDid(did: String,walletHandle: IndyHandle, completion: @escaping (Error?,String?,String?) -> Void) {
        IndyDid.createAndStoreMyDid(did, walletHandle: walletHandle, completion: completion)
    }
    
    func packMessage(message: Data!,myKey: String!, theirKey: String!, walletHandle: IndyHandle, completion: @escaping (Error?, Data?) -> Void) {
        IndyCrypto.packMessage(message, receivers: theirKey, sender: myKey, walletHandle: walletHandle, completion: completion)
    }
    
    func unpackMessage(message: Data!,myKey: String!, theirKey: String!, walletHandle: IndyHandle, completion: @escaping (Error?,Data?) -> Void){
        IndyCrypto.unpackMessage(message, walletHandle: walletHandle,completion: completion)
    }
    
}

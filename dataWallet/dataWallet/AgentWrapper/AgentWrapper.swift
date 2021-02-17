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
    
    //MARK:WALLET
    func createWallet(withConfig: String, credentials: String, completion: @escaping (Error?) -> Void) {
        wallet?.createWallet(withConfig: withConfig, credentials: credentials, completion: completion)
    }
    
    func openWallet(withConfig: String, credentials: String, completion: @escaping (Error?,IndyHandle) -> Void) {
        wallet?.open(withConfig: withConfig,credentials: credentials,completion: completion)
    }
    
    func closeWallet(withHandle: IndyHandle,completion: @escaping (Error?) -> Void) {
        wallet?.close(withHandle: withHandle, completion: completion)
    }
    
    func addWalletRecord(inWallet: IndyHandle, type: String!, id: String!, value: String!, tagsJson: String!, completion: @escaping (Error?) -> Void) {
        IndyNonSecrets.addRecord(inWallet: inWallet, type: type, id: id, value: value, tagsJson: tagsJson, completion: completion)
    }
    
    func getWalletRecord(walletHandle: IndyHandle, type: String!, id: String!, optionsJson: String!, completion: @escaping ((Error?, String?) -> Void)){
        IndyNonSecrets.getRecordFromWallet(walletHandle, type: type, id: id, optionsJson: optionsJson, completion: completion)
    }
    
    func openWalletSearch(inWallet: IndyHandle, type: String!, queryJson: String!, optionsJson: String!, completion: @escaping ((Error?, IndyHandle) -> Void)){
        IndyNonSecrets.openSearch(inWallet: inWallet, type: type, queryJson: queryJson, optionsJson: optionsJson, completion: completion)
    }
    
    func fetchNextRecords(fromSearch: IndyHandle, walletHandle: IndyHandle, count: NSNumber!, completion: @escaping ((Error?, String?) -> Void)){
        IndyNonSecrets.fetchNextRecords(fromSearch: fromSearch, walletHandle: walletHandle, count: count, completion: completion)
    }
    
    func getMyDidWithMeta(did: String!, walletHandle: IndyHandle, completion: @escaping ((Error?, String?) -> Void)){
        IndyDid.getMetadataForDid(did, walletHandle: walletHandle, completion: completion)
    }
    
    func createAndStoreDid(did: String,walletHandle: IndyHandle, completion: @escaping (Error?,String?,String?) -> Void) {
        IndyDid.createAndStoreMyDid(did, walletHandle: walletHandle, completion: completion)
    }
    
    func setMetadata(metadata: String!, forDid: String!, walletHandle: IndyHandle, completion: @escaping ((Error?) -> Void)){
        IndyDid.setMetadata(metadata, forDid: forDid, walletHandle: walletHandle, completion: completion)
    }
    func updateWalletRecord(inWallet: IndyHandle, type: String!, id: String!, value: String!, completion: @escaping ((Error?) -> Void)){
        IndyNonSecrets.updateRecordValue(inWallet: inWallet, type: type, id: id, value: value, completion: completion)
    }
    
    func updateWalletTags(inWallet: IndyHandle, type: String!, id: String!, tagsJson: String!, completion: @escaping ((Error?) -> Void)){
        IndyNonSecrets.updateRecordTags(inWallet: inWallet, type: type, id: id, tagsJson: tagsJson, completion: completion)
    }
    
    func packMessage(message: Data!,myKey: String!, recipientKey: String!, walletHandle: IndyHandle, completion: @escaping (Error?, Data?) -> Void) {
        IndyCrypto.packMessage(message, receivers: recipientKey, sender: myKey, walletHandle: walletHandle, completion: completion)
    }
    
    func unpackMessage(message: Data!, walletHandle: IndyHandle, completion: @escaping (Error?,Data?) -> Void){
        IndyCrypto.unpackMessage(message, walletHandle: walletHandle,completion: completion)
    }
    
    func deleteWalletRecord(inWallet: IndyHandle, type: String, id: String, completion: @escaping (Error?) -> Void) {
        IndyNonSecrets.deleteRecord(inWallet: inWallet, type: type, id: id, completion: completion)
    }
    
    //MARK: Pool & Ledger
    func pool_setProtocol(protocolVersion: NSNumber!, completion: @escaping (Error?) -> Void){
        IndyPool.setProtocolVersion(protocolVersion, completion: completion)
    }
    
    func pool_openPool(withName: String, poolConfig: String, completion: @escaping ((Error?, IndyHandle) -> Void)){
        IndyPool.openLedger(withName: withName, poolConfig: poolConfig, completion: completion)
    }
    
    func pool_prover_create_master_secret(masterSecretID: String, walletHandle: IndyHandle, completion: @escaping (Error?, String?) -> Void){
        IndyAnoncreds.proverCreateMasterSecret(masterSecretID, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_store_credential(credJson: String!, credID: String!, credReqMetadataJSON: String!, credDefJSON: String!, revRegDefJSON: String?, walletHandle: IndyHandle, completion: @escaping (Error?, String?) -> Void) {
        IndyAnoncreds.proverStoreCredential(credJson, credID: credID, credReqMetadataJSON: credReqMetadataJSON, credDefJSON: credDefJSON, revRegDefJSON: revRegDefJSON, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_create_credential_request(forCredentialOffer: String!, credentialDefJSON: String!, proverDID: String!, masterSecretID: String!, walletHandle: IndyHandle, completion: @escaping ((Error?, String?, String?) -> Void)){
        IndyAnoncreds.proverCreateCredentialReq(forCredentialOffer: forCredentialOffer, credentialDefJSON: credentialDefJSON, proverDID: proverDID, masterSecretID: masterSecretID, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_get_credential(withId: String, walletHandle: IndyHandle, completion: @escaping ((Error?, String?) -> Void)){
        IndyAnoncreds.proverGetCredential(withId: withId, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_delete_credential(withId: String!, walletHandle: IndyHandle, completion: @escaping ((Error?) -> Void)){
        IndyAnoncreds.proverDeleteCredentials(withId: withId, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_search_credentials(forQuery: String, walletHandle: IndyHandle, completion: @escaping ((Error?, IndyHandle, NSNumber?) -> Void)){
        IndyAnoncreds.proverSearchCredentials(forQuery: forQuery, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_fetch_credentials(withSearchHandle: IndyHandle, count: NSNumber!, completion: @escaping ((Error?, String?) -> Void)){
        IndyAnoncreds.proverFetchCredentials(withSearchHandle: withSearchHandle, count: count, completion: completion)
    }
        
    func pool_prover_search_credentials(forProofRequest: String!, extraQueryJSON: String!, walletHandle: IndyHandle, completion: @escaping ((Error?, IndyHandle) -> Void)) {
        IndyAnoncreds.proverSearchCredentials(forProofRequest: forProofRequest, extraQueryJSON: extraQueryJSON, walletHandle: walletHandle, completion: completion)
    }
    
    func pool_prover_fetch(forProofReqItemReferent: String!, searchHandle: IndyHandle, count: NSNumber!, completion: ((Error?, String?) -> Void)!){
        IndyAnoncreds.proverFetchCredentials(forProofReqItemReferent: forProofReqItemReferent, searchHandle: searchHandle, count: count, completion: completion)
    }
    
    func pool_prover_close_credentialSearch_proofReq(withHandle: IndyHandle, completion: @escaping ((Error?) -> Void)){
        IndyAnoncreds.proverCloseCredentialsSearchForProofReq(withHandle: withHandle, completion: completion)
    }
    
    
    func pool(){
        
    }
    
    func pool_delete(withName: String!, completion: @escaping ((Error?) -> Void)){
        IndyPool.deleteLedgerConfig(withName: withName, completion: completion)
    }
    
    func pool_create(withPoolName: String!, poolConfig: String!, completion: @escaping ((Error?) -> Void)){
        IndyPool.createPoolLedgerConfig(withPoolName: withPoolName, poolConfig: poolConfig, completion: completion)
    }
    
    func provercreateproof(forRequest: String, requestedCredentialsJSON: String, masterSecretID: String, schemasJSON: String, credentialDefsJSON: String, revocStatesJSON: String, walletHandle: IndyHandle, completion: @escaping ((Error?, String?) -> Void)){
        IndyAnoncreds.proverCreateProof(forRequest: forRequest, requestedCredentialsJSON: requestedCredentialsJSON, masterSecretID: masterSecretID, schemasJSON: schemasJSON, credentialDefsJSON: credentialDefsJSON, revocStatesJSON: revocStatesJSON, walletHandle: walletHandle, completion: completion)
    }
    
    func ledger_build_get_acceptance_mechanisms_request(withSubmitterDid: String!, timestamp: NSNumber!, version: String!, completion: @escaping ((Error?, String?) -> Void)){
        IndyLedger.buildGetAcceptanceMechanismsRequest(withSubmitterDid: withSubmitterDid, timestamp: timestamp, version: version, completion: completion)
    }
    
    func ledger_submitRequest(requestJSON: String!, poolHandle: IndyHandle, completion: @escaping ((Error?, String?) -> Void)){
        IndyLedger.submitRequest(requestJSON, poolHandle: poolHandle, completion: completion)
    }
    
    func ledger_build_get_txn_author_agreement_request(withSubmitterDid: String!, data: String!, completion: @escaping ((Error?, String?) -> Void)) {
        IndyLedger.buildGetTxnAuthorAgreementRequest(withSubmitterDid: withSubmitterDid, data: data, completion: completion)
    }
    
    func ledger_build_get_cred_definition_request(withSubmitterDid: String!, id: String!, completion: @escaping ((Error?, String?) -> Void)) {
        IndyLedger.buildGetCredDefRequest(withSubmitterDid: withSubmitterDid, id: id, completion: completion)
    }
    
    func ledger_build_get_schema_request(withSubmitterDid: String!, id: String!, completion: @escaping ((Error?, String?) -> Void)) {
        IndyLedger.buildGetSchemaRequest(withSubmitterDid: withSubmitterDid, id: id, completion: completion)
    }
    
    func ledger_build_get_schema_response(getSchemaResponse: String, completion: @escaping((Error?, String?, String?) -> Void)) {
        IndyLedger.parseGetSchemaResponse(getSchemaResponse, completion: completion)
    }
    
    func ledger_parse_get_cred_def_response(getCredDefResponse: String!, completion: @escaping((Error?, String?, String?) -> Void)) {
        IndyLedger.parseGetCredDefResponse(getCredDefResponse, completion: completion)
    }
    

    func pool_close_ledger(withHandle: IndyHandle, completion: @escaping ((Error?) -> Void)){
        IndyPool.closeLedger(withHandle: withHandle, completion: completion)
    }
    
    //MARK: General
    func generateRandomId_BaseUID4() -> String{
        let uuid = UUID().uuidString.lowercased()
        return uuid
    }
    
    func getCurrentDateTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS'Z'"
        return dateFormatter.string(from: date)
    }
    
}

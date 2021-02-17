//
//  AgentPoolHelper.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 28/11/20.
//

import Foundation
import SVProgressHUD

struct AriesPoolHelper {
    static let shared = AriesPoolHelper()
    static var poolHandler = IndyHandle()
    private init() {}

    func configurePool(walletHandler: IndyHandle,completion: @escaping (Bool?) -> Void) {
        self.pool_prover_create_master_secret(walletHandle: walletHandler) { (success, masterSecretHandler, error) in
                self.fetchAndSaveGenesis { (genesisFilePath) in
                    self.closePoolLedger(poolHandler: AriesPoolHelper.poolHandler) { (success, error) in
                    self.deleteDefaultPool { (success, error) in
                        self.createDefaultPool(genesisPath: genesisFilePath) { (success, error) in
                            if success {
                                self.pool_setProtocol(version: 2) { (success, error) in
                                    if success {
                                        self.pool_openLedger(name: "default", config: [String:Any]()) { (success, poolLedgerHandler, error) in
                                            if success {
                                                AriesPoolHelper.poolHandler = poolLedgerHandler
                                                completion(true)
//                                                self.buildGetAcceptanceMechanismRequest { (success, buildAcceptanceMechanismResponse, error) in
//                                                    if success {
//                                                        self.submitRequest(poolHandle: poolLedgerHandler, requestJSON: buildAcceptanceMechanismResponse) { (success, response, error) in
//                                                            if success {
//                                                                self.buildGetTxnAuthorAgreementRequest { (success, buildGetTxnAuthorAgreementResponse, error) in
//                                                                    if success {
//                                                                        self.submitRequest(poolHandle: poolLedgerHandler, requestJSON: buildGetTxnAuthorAgreementResponse) { (success,response , error) in
//                                                                            if success {
//                                                                                SVProgressHUD.dismiss()
//                                                                            }
//                                                                        }
//                                                                    }
//                                                                }
//                                                            }
//                                                        }
//                                                    }
//                                                }
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
    
    func pool_setProtocol(version: NSNumber,completion: @escaping (Bool,Error?) -> Void){
        AgentWrapper.shared.pool_setProtocol(protocolVersion: version) { (error) in
            if(error?._code == 0){
                print("pool set protocol")
                completion(true,error)
            } else {
                completion(false,error)
            }
            
        }
    }
    
    func pool_openLedger(name: String,config: [String:Any], completion: @escaping(Bool,IndyHandle,Error?) -> Void){
        AgentWrapper.shared.pool_openPool(withName: name, poolConfig: UIApplicationUtils.shared.getJsonString(for:config)) { (error, poolHandler) in
            if(error?._code == 0){
                print("pool set protocol")
                completion(true,poolHandler,error)
            } else {
                completion(false,poolHandler,error)
            }
        }
    }
    
    func pool_prover_create_master_secret(walletHandle: IndyHandle,completion: @escaping(Bool,String,Error?) -> Void){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let masterSecretID = "iGrantMobileAgent-\(deviceID)"
        AgentWrapper.shared.pool_prover_create_master_secret(masterSecretID: masterSecretID, walletHandle: walletHandle) { (error, response) in
            if(error?._code == 0){
                print("pool set protocol")
                completion(true,response ?? "",error)
            } else {
                completion(false,response ?? "",error)
            }
        }
    }
    
    func pool_prover_create_credential_request(walletHandle: IndyHandle, forCredentialOffer: String, credentialDefJSON: String, proverDID: String,completion: @escaping(Bool,String,String,Error?) -> Void){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let masterSecretID = "iGrantMobileAgent-\(deviceID)"
        AgentWrapper.shared.pool_prover_create_credential_request(forCredentialOffer: forCredentialOffer, credentialDefJSON: credentialDefJSON, proverDID: proverDID, masterSecretID: masterSecretID, walletHandle: walletHandle) { (error, credReqJSON, credReqMetadataJSON) in
            if(error?._code == 0){
                print("pool set protocol")
                completion(true,credReqJSON ?? "",credReqMetadataJSON ?? "",error)
            } else {
                completion(false,"", "" ,error)
            }
        }
    }
    
    func pool_prover_store_credential(walletHandle: IndyHandle,credentialModel: SearchCertificateRecord,completion: @escaping(Bool,String,Error?) -> Void) {
        let credJson = UIApplicationUtils.shared.getJsonString(for: credentialModel.value?.rawCredential?.dictionary ?? [String:Any]())
        let credReqMetadataJSON = UIApplicationUtils.shared.getJsonString(for: credentialModel.value?.credentialRequestMetadata?.dictionary ?? [String:Any]())
        let credDefJSON = UIApplicationUtils.shared.getJsonString(for: credentialModel.value?.credDefJson?.dictionary ?? [String:Any]())
        AgentWrapper.shared.pool_prover_store_credential(credJson: credJson,
                                                         credID: credentialModel.value?.credentialID ?? AgentWrapper.shared.generateRandomId_BaseUID4(),
                                                         credReqMetadataJSON: credReqMetadataJSON,
                                                         credDefJSON: credDefJSON,
                                                         revRegDefJSON: nil,
                                                         walletHandle: walletHandle) { (error, outCredID) in
            if(error?._code == 0){
                print("pool set protocol")
                completion(true,outCredID ?? "",error)
            } else {
                completion(false,"" ,error)
            }
        }
    }
    
    func pool_prover_get_credentials(id: String,walletHandle: IndyHandle,completion: @escaping(Bool,String,Error?) -> Void) {
        AgentWrapper.shared.pool_prover_get_credential(withId: id, walletHandle: walletHandle) { (error, credID) in
            if(error?._code == 0){
                print("pool set protocol")
                completion(true,credID ?? "",error)
            } else {
                completion(false,"" ,error)
            }
        }
    }
    
    func fetchAndSaveGenesis(completion: @escaping(String) -> Void){
//        NetworkManager.shared.getGenesis { (data) in
//            if let stringResponse = String.init(bytes: data ?? Data(), encoding: .ascii){
//            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
//                                                                in: .userDomainMask).first {
////                let formattedString = stringResponse.replacingOccurrences(of: "\"", with: "")
//                let pathWithFilename = documentDirectory.appendingPathComponent("indy_genesis_transactions.txn")
//                do {
//                    if FileManager.default.createFile(atPath: pathWithFilename.path, contents: data ?? Data(), attributes: nil) {
//                        completion(pathWithFilename.path)
//                    }
//
//                } catch {
//                    // Handle error
//                    print("writing file failed")
//                    completion("")
//                }
//
////                //reading
////                   do {
////                       let text2 = try String(contentsOf: pathWithFilename, encoding: .utf8)
////                   }
////                   catch {/* error handling here */}
//            }
//        }
//        }
        
        let ledgerIndex = UserDefaults.standard.value(forKey: Constants.userDefault_ledger) as? Int ?? 0
        let ledger = LedgerListViewController.ledgers[ledgerIndex]
        
        switch ledger {
            case Constants.ledger_igrant_sandbox:
                completion(Bundle.main.path(forResource: "igrant_sandbox_genesis", ofType: "txn") ?? "")
            case Constants.ledger_sovrin_builder:
                completion(Bundle.main.path(forResource: "pool_transactions_builder_genesis", ofType: "txn") ?? "")
            case Constants.ledger_sovrin_live:
                completion(Bundle.main.path(forResource: "pool_transactions_live_genesis", ofType: "txn") ?? "")
            case Constants.ledger_sovrin_sandbox:
                completion(Bundle.main.path(forResource: "pool_transactions_sandbox_genesis", ofType: "txn") ?? "")
            default:
                completion(Bundle.main.path(forResource: "igrant_sandbox_genesis", ofType: "txn") ?? "")
        }
        
        //let stringPath = Bundle.main.path(forResource: "input", ofType: "txt")

    }
    
    func stringToUnsafeMutablePointer(message: String) -> UnsafeMutablePointer<Int8> {
        var messageCString = message.utf8CString
        return messageCString.withUnsafeMutableBytes { mesUMRBP in
            return mesUMRBP.baseAddress!.bindMemory(to: Int8.self, capacity: mesUMRBP.count)
        }

    }
    
    func deleteDefaultPool(completion: @escaping(Bool,Error?) -> Void){
        AgentWrapper.shared.pool_delete(withName: "default") { (error) in
            if(error?._code == 0){
                print("delete default pool")
                completion(true,error)
            } else {
                completion(false,error)
            }
        }
    }
    
    func createDefaultPool(genesisPath: String,completion: @escaping(Bool,Error?) -> Void){
        let config = [
            "genesis_txn" : genesisPath
        ]
        AgentWrapper.shared.pool_create(withPoolName: "default", poolConfig: UIApplicationUtils.shared.getJsonString(for: config)) { (error) in
            if(error?._code == 0){
                print("create default pool")
                completion(true,error)
            } else {
                completion(false,error)
            }
        }
    }
    
    func createProof(forRequest: String, requestedCredentialsJSON: String, masterSecretID: String, schemasJSON: String, credentialDefsJSON: String, revocStatesJSON: String, walletHandle: IndyHandle, completion: @escaping ((Bool,String,Error?) -> Void)){
        AgentWrapper.shared.provercreateproof(forRequest: forRequest, requestedCredentialsJSON: requestedCredentialsJSON, masterSecretID: masterSecretID, schemasJSON: schemasJSON, credentialDefsJSON: credentialDefsJSON, revocStatesJSON: revocStatesJSON, walletHandle: walletHandle) { (error, proofJSON) in
            if(error?._code == 0){
                print("create default pool")
                completion(true,proofJSON ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
        
    }
    
    func buildGetAcceptanceMechanismRequest(completion: @escaping(Bool,String,Error?) -> Void){
        
        AgentWrapper.shared.ledger_build_get_acceptance_mechanisms_request(withSubmitterDid: nil, timestamp: nil, version: nil) { (error, response) in
            if(error?._code == 0){
                print("build_get_acceptance_mechanisms_request")
                completion(true,response ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
    }
    
    func submitRequest(poolHandle: IndyHandle, requestJSON: String,completion: @escaping(Bool,String,Error?) -> Void){
        
        AgentWrapper.shared.ledger_submitRequest(requestJSON: requestJSON, poolHandle: poolHandle) { (error, response) in
            if(error?._code == 0){
                print("submitRequest")
                completion(true,response ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
    }
    
    func buildGetTxnAuthorAgreementRequest(completion: @escaping(Bool,String,Error?) -> Void){
        AgentWrapper.shared.ledger_build_get_txn_author_agreement_request(withSubmitterDid: nil, data: nil) { (error, response) in
            if(error?._code == 0){
                print("build_get_txn_author_agreement_request")
                completion(true,response ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
    }
    
    func buildGetCredDefRequest(id: String,completion: @escaping(Bool,String,Error?) -> Void){
        AgentWrapper.shared.ledger_build_get_cred_definition_request(withSubmitterDid: nil, id: id) { (error, response) in
            if(error?._code == 0){
                print("build_get_cred_definition_request")
                completion(true,response ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
    }
    
    func buildGetSchemaRequest(id: String,completion: @escaping(Bool,String,Error?) -> Void){
        AgentWrapper.shared.ledger_build_get_schema_request(withSubmitterDid: nil, id: id) { (error, response) in
            if(error?._code == 0){
                print("build_get_cred_definition_request")
                completion(true,response ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
    }
    
    func buildGetSchemaResponse(getSchemaResponse: String,completion: @escaping(Bool,String,String,Error?) -> Void){
        AgentWrapper.shared.ledger_build_get_schema_response(getSchemaResponse: getSchemaResponse) { (error, defID, defJson) in
            if(error?._code == 0){
                print("build_get_cred_definition_request")
                completion(true,defID ?? "",defJson ?? "",error)
            } else {
                completion(false,"","",error)
            }
        }
    }
    
    func parseGetCredDefResponse(response: String,completion: @escaping(Bool,String,String,Error?) -> Void){
        AgentWrapper.shared.ledger_parse_get_cred_def_response(getCredDefResponse: response) { (error, credDefId, credDefJson) in
   
            if(error?._code == 0){
                print("parseGetCredDefResponse")
                completion(true,credDefId ?? "",credDefJson ?? "",error)
            } else {
                completion(false,"","",error)
            }
        }
    }
    
    func closePoolLedger(poolHandler: IndyHandle,completion: @escaping(Bool,Error?) -> Void){
        AgentWrapper.shared.pool_close_ledger(withHandle: poolHandler) { (error) in
            if(error?._code == 0){
                print("pool_close_ledger")
                completion(true,error)
            } else {
                completion(false,error)
            }
        }
    }
    
    func getCredentialsFromWallet(walletHandler: IndyHandle,completion: @escaping(Bool,String,Error?) -> Void){
        AgentWrapper.shared.pool_prover_search_credentials(forQuery: "{}", walletHandle: walletHandler) { (error, searchHandler, count) in
            AgentWrapper.shared.pool_prover_fetch_credentials(withSearchHandle: searchHandler, count: 100) { (error, records) in
                if(error?._code == 0){
                    print("getCredentialsFromWallet")
                    completion(true,records ?? "",error)
                } else {
                    completion(false,"",error)
                }
            }
        }
    }
    
    func deleteCredentialFromWallet(withId: String,walletHandle: IndyHandle, completion:@escaping (Bool,Error?)-> Void){
        AgentWrapper.shared.pool_prover_delete_credential(withId: withId, walletHandle: walletHandle) { (error) in
            if(error?._code == 0){
                print("delete Credential from wallet")
                completion(true,error)
            } else {
                completion(false,error)
            }
        }
    }
    
    func pool_prover_search_credentials(forProofRequest: String!, extraQueryJSON: String!, walletHandle: IndyHandle,completion: @escaping(Bool,IndyHandle?,Error?) -> Void){
        AgentWrapper.shared.pool_prover_search_credentials(forProofRequest: forProofRequest, extraQueryJSON: extraQueryJSON, walletHandle: walletHandle) { (error, searchHandle) in
            if(error?._code == 0){
                print("search credentials - proofreq")
                completion(true,searchHandle,error)
            } else {
                completion(false,searchHandle,error)
            }
        }
    }
    
    func proverfetchcredentialsforproof_req(forProofReqItemReferent: String!, searchHandle: IndyHandle, count: NSNumber!, completion: @escaping ((Bool, String?,Error?) -> Void)) {
        AgentWrapper.shared.pool_prover_fetch(forProofReqItemReferent: forProofReqItemReferent, searchHandle: searchHandle, count: count) { (error, response) in
            if(error?._code == 0){
                print("fetch credential - proof req")
                completion(true,response ?? "",error)
            } else {
                completion(false,"",error)
            }
        }
    }
    
    func proverclosecredentialssearchforproofreq(withHandle: IndyHandle, completion: @escaping ((Bool,Error?) -> Void)) {
        AgentWrapper.shared.pool_prover_close_credentialSearch_proofReq(withHandle: withHandle) { (error) in
            if(error?._code == 0){
                print("close proof search req")
                completion(true,error)
            } else {
                completion(false,error)
            }
        }
    }
}

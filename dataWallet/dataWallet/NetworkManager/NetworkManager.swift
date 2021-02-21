//
//  NetworkManager.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 15/11/20.
//

import Foundation
import Moya
import SVProgressHUD
import Alamofire

class NetworkManager {
    let provider = MoyaProvider<MyService>()
    public static let shared = NetworkManager()
    var baseURL = "https://mediator.igrant.io"
    var mediatorEndPoint = "https://mediator.igrant.io"
    private init() {
        provider.session.session.configuration.timeoutIntervalForRequest = 60
    }

    func getAgentConfig(completion: @escaping((AgentConfigurationResponse?) -> Void)){
        provider.request(.agentConfig) { (result) in
            switch result {
                case let .success(moyaResponse):
                    if moyaResponse.statusCode != 200 {
                        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
                        SVProgressHUD.dismiss()
                        completion(nil)
                    }
                    let data = moyaResponse.data // Data, your JSON response is probably in here!
                    let agentConfigurationResponse = try? JSONDecoder().decode(AgentConfigurationResponse.self, from: data)
                    completion(agentConfigurationResponse)
                case let .failure(error):
                        print(error.localizedDescription)
                    self.showError(error: error)
                    //                        if error._code == NSURLErrorTimedOut {
//
//                        }
                        completion(nil)
                    // TODO: handle the error == best. comment. ever.
                }
        }
    }
    
    func sendMsg(isMediator: Bool,msgData:Data,completion: @escaping((Int,Data?) -> Void)){
        provider.request(.sendMessage(toMediator: isMediator,msgData: msgData)) { (result) in
            switch result {
                case let .success(moyaResponse):
//                    print(moyaResponse.request)
//                    print(moyaResponse.statusCode)
                    if moyaResponse.statusCode != 200 {
//                        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
//                        SVProgressHUD.dismiss()
                        completion(0,nil)
                        return
                    }
                    let data = moyaResponse.data // Data, your JSON response is probably in here!
                    completion(moyaResponse.statusCode,data)
                case let .failure(error):
                    self.showError(error: error)
                    print(error.localizedDescription)
                    completion(0,nil)
                    // TODO: handle the error == best. comment. ever.
                }
        }
    }
    
    func polling(msgData:Data,completion: @escaping((Int,Data?) -> Void)){
        provider.request(.polling(msgData: msgData)) { (result) in
            switch result {
                case let .success(moyaResponse):
                    if moyaResponse.statusCode != 200 {
                        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
                        SVProgressHUD.dismiss()
                        completion(0,nil)
                    }
//                    print(moyaResponse.request)
//                    print(moyaResponse.statusCode)
                    let data = moyaResponse.data // Data, your JSON response is probably in here!
                    completion(moyaResponse.statusCode,data)
                case let .failure(error):
//                    self.showError(error: error)
                    print(error.localizedDescription)
                    completion(0,nil)
                    // TODO: handle the error == best. comment. ever.
                }
        }
    }
    
    func mediator(param:[String:Any],completion: @escaping((Data?) -> Void)){
        provider.request(.mediator(param: param)) { (result) in
            switch result {
                case let .success(moyaResponse):
                    if moyaResponse.statusCode != 200 {
                        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
                        SVProgressHUD.dismiss()
                        completion(nil)
                    }
                    let data = moyaResponse.data // Data, your JSON response is probably in here!
                    completion(data)
                case let .failure(error):
                    self.showError(error: error)
                    print(error.localizedDescription)
                        completion(nil)
                    // TODO: handle the error == best. comment. ever.
                }
        }
    }
    
    func getQRCodeDetails(completion: @escaping((Data?)) -> Void) {
        provider.request(.QRCode){ (result) in
            switch result {
                case let .success(moyaResponse):
                    if moyaResponse.statusCode != 200 {
                        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
                        SVProgressHUD.dismiss()
                        completion(nil)
                    }
                    let data = moyaResponse.data // Data, your JSON response is probably in here!
                    completion(data)
                case let .failure(error):
//                    self.showError(error: error)
                    print(error.localizedDescription)
                        completion(nil)
                    // TODO: handle the error == best. comment. ever.
                }
        }
    }
    
    func getGenesis(completion: @escaping((Data?) -> Void)) {
        provider.request(.getGenesis) { (result) in
            switch result {
                case let .success(moyaResponse):
                    if moyaResponse.statusCode != 200 {
                        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
                        SVProgressHUD.dismiss()
                        completion(nil)
                    }
                    let data = moyaResponse.data // Data, your JSON response is probably in here!
                    completion(data)
                case let .failure(error):
                    self.showError(error: error)
                        print(error.localizedDescription)
                        completion(nil)
                    // TODO: handle the error == best. comment. ever.
                }
        }
    }
    
    func showError(error: MoyaError){
        UIApplicationUtils.showErrorSnackbar(message: "Unexpected error. Please try again.".localized())
        SVProgressHUD.dismiss()
        print("Taking longer than expected. Please try again ?")
    }
}

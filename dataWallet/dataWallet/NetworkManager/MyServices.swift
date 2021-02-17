//
//  Alamofire
//
//  Created by Mohamed Rebin on 15/11/20.
//

import Foundation
import Moya

enum MyService {
    case agentConfig
    case sendMessage(toMediator:Bool,msgData: Data)
    case mediator(param: [String: Any])
    case connectionRequestToCloudAgent(param: [String: Any])
    case getGenesis
    case QRCode
    case polling(msgData: Data)
}

// MARK: - TargetType Protocol Implementation
extension MyService: TargetType {
    
    //    https://mediator.igrant.io/.well-known/agent-configuration
    var baseURL: URL {
        switch self {
            case .connectionRequestToCloudAgent:
                return URL(string: NetworkManager.shared.baseURL) ?? URL(string: "https://mediator.igrant.io")!
            case .sendMessage(toMediator: let isMediator, msgData: _):
                return isMediator ? URL(string: "https://mediator.igrant.io")! : URL(string: NetworkManager.shared.baseURL)!
            case .getGenesis:
                return  URL(string: "https://indy.igrant.io/genesis")!
            case .QRCode:
                return URL(string: NetworkManager.shared.baseURL) ?? URL(string: "https://mediator.igrant.io")!
            case .polling:
                return URL(string: "https://mediator.igrant.io")!
            default:
                return URL(string: "https://mediator.igrant.io")!
        }
    }
    var path: String {
        switch self {
            case .agentConfig,.mediator(param: _):
                return "/.well-known/agent-configuration"
            case .connectionRequestToCloudAgent(param: _):
                return ""
            case .sendMessage(toMediator: let toMediator, msgData: _):
                return toMediator ? "/.well-known/agent-configuration" : ""
            case .getGenesis:
                return ""
            case .QRCode:
                return ""
            case .polling:
                return "/.well-known/agent-configuration"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .agentConfig,.getGenesis:
                return .get
            case .sendMessage,.mediator:
                return .post
            case .connectionRequestToCloudAgent:
                return .post
            case .QRCode:
                return .post
            case .polling:
                return .post
        }
    }
    var task: Task {
        switch self {
            case .agentConfig,.getGenesis,.QRCode: // Send no parameters
                return .requestPlain
            case let.sendMessage(_,msgData):
                return .requestData(msgData)
            case let .mediator(param: param):
                return .requestParameters(parameters: param, encoding: JSONEncoding.default)
            case .connectionRequestToCloudAgent(param: let param):
                return .requestParameters(parameters: param, encoding: JSONEncoding.default)
            case .polling(msgData: let data):
                return .requestData(data)
        }
    }
    var sampleData: Data {
        return "".utf8Encoded
        //        switch self {
        //        case .agentConfig:
        //            return "".utf8Encoded
        //        case .showUser(let id):
        //            return "{\"id\": \(id), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".utf8Encoded
        //        case .createUser(let firstName, let lastName):
        //            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
        //        case .updateUser(let id, let firstName, let lastName):
        //            return "{\"id\": \(id), \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
        //        case .showAccounts:
        //            // Provided you have a file named accounts.json in your bundle.
        //            guard let url = Bundle.main.url(forResource: "accounts", withExtension: "json"),
        //                let data = try? Data(contentsOf: url) else {
        //                    return Data()
        //            }
        //            return data
        //        }
    }
    var headers: [String: String]? {
        switch self {
            case .agentConfig,.mediator,.connectionRequestToCloudAgent,.getGenesis: // Send no parameters
                return ["Content-type": "application/json"]
            case .sendMessage:
                return ["Content-Type": "application/ssi-agent-wire"]
            case .QRCode:
                return nil
            case .polling:
                return ["Content-Type": "application/ssi-agent-wire"]
        }
        
    }
}
// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

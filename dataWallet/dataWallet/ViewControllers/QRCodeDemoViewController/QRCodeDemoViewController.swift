//
//  HomeViewController.swift
//  Indy_Demo
//
//  Created by Mohamed Rebin on 17/10/20.
//

import UIKit

class QRCodeDemoViewController: AriesBaseViewController {
    
    @IBOutlet weak var walletName: UITextField!
    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var shareDIDButton: UIButton!
    @IBOutlet weak var getDIDButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMsgButton: UIButton!
    @IBOutlet weak var viewMsgButton: UIButton!
    @IBOutlet weak var recievedMsgLabel: UILabel!
    @IBOutlet weak var baseStackView: UIStackView!
    
    @IBOutlet weak var baseScrollView: UIScrollView!
    @IBOutlet weak var myDidQR: UIImageView!
    @IBOutlet weak var myDIDLabel: UILabel!
    @IBOutlet weak var myVerKeyLabel: UILabel!
    @IBOutlet weak var receiveDIDLabel: UILabel!
    @IBOutlet weak var receiveVerKeyLabel: UILabel!
    @IBOutlet weak var messageQR: UIImageView!
    
    var walletHandle: IndyHandle?
    var myDID: String?
    var myVerKey: String?
    var recievedDID: String?
    var recievedVerKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AgentWrapper.shared.transport = QRTransportMode()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.baseScrollView.contentSize = CGSize.init(width: self.baseStackView.frame.width, height: self.baseStackView.frame.height + 60)
    }
    
    @IBAction func createWalletAction(_ sender: Any) {
        openWallet()
    }
    
    @IBAction func shareDidAction(_ sender: Any) {
        shareDid()
    }
    
    @IBAction func getDIDAction(_ sender: Any) {
        getDid()
    }
    
    @IBAction func sendMsgAction(_ sender: Any) {
        sendMessage()
    }
    
    @IBAction func viewMsgAction(_ sender: Any) {
        recieveMessage()
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [ .allowFragments]) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

//Agent Functions
extension QRCodeDemoViewController {
    func createWallet() {
        let config = "{\"id\": \"\(walletName.text ?? "")\"}"
        let credentials = "{\"key\": \"\(walletName.text ?? "")\"}"
        AgentWrapper.shared.createWallet(withConfig: config, credentials: credentials, completion: { [unowned self](error) in
            if (error != nil) {
                print("wallet created")
                self.openWallet()
            }
        })
    }
    
    func openWallet() {
        let config = "{\"id\": \"\(walletName.text ?? "")\"}"
        let credentials = "{\"key\": \"\(walletName.text ?? "")\"}"
        AgentWrapper.shared.openWallet(withConfig: config, credentials: credentials) {[unowned self] (error, indyHandle) in
            if (indyHandle == 0){
                self.createWallet()
            }else {
                self.walletHandle = indyHandle
                print("wallet opened")

            }
        }
    }
    
    func createAndStoreDID() {
        let did =  "{}"
        guard let handle = self.walletHandle else { return }
        AgentWrapper.shared.createAndStoreDid(did: did, walletHandle: handle) {[unowned self] (error, DID, verKey) in
            self.myDID = DID
            self.myVerKey = verKey
            self.myDIDLabel.text = DID
            self.myVerKeyLabel.text = verKey
            self.shareDid()
            print("did created")
        }
    }
    
    func shareDid() {
        if (self.myDID == nil){
            createAndStoreDID()
            return
        }
        let msg = "{\"did\":\"\(myDID ?? "")\",\"verifiedKey\":\"\(myVerKey ?? "")\"}"
        AgentWrapper.shared.transport?.sendData(msg: msg, completion: { [unowned self](obj) in
            if let image = obj as? UIImage {
                self.myDidQR.image = image
//                let VC = UIViewController()
//                let imageView = UIImageView.init(frame: VC.view.frame)
//                VC.view.addSubview(imageView)
//                imageView.image = image
//                imageView.contentMode = .center
//                self.navigationController?.pushViewController(VC, animated: true)
            }
            print("share did")
        })
    }
    
    func getDid(){
        AgentWrapper.shared.transport?.getData(completion: {[unowned self] (recievedData) in
            guard let jsonString = recievedData else {return}
            let dataDID = self.convertToDictionary(text: jsonString)
            self.recievedDID = dataDID?["did"] as? String ?? ""
            self.recievedVerKey = dataDID?["verifiedKey"] as? String ?? ""
            self.receiveDIDLabel.text = self.recievedDID
            self.receiveVerKeyLabel.text = self.recievedVerKey
            print("get did")
        })
    }
    
    func sendMessage() {
        guard let message = self.messageTextView.text,let walletHandle = self.walletHandle else{return}
        let msgData = Data(message.utf8)
        let recieversArray = "[\"\(self.recievedVerKey ?? "")\"]"

        AgentWrapper.shared.packMessage(message: msgData, myKey: self.myVerKey, recipientKey: recieversArray, walletHandle: walletHandle) { [unowned self](error, data) in
            guard let criptData = data else{return}
            let msg = String.init(decoding: criptData, as: UTF8.self)
            AgentWrapper.shared.transport?.sendData(msg: msg, completion: { [unowned self](obj) in
                if let image = obj as? UIImage {
                    self.messageQR.image = image
//                    let VC = UIViewController()
//                    let imageView = UIImageView.init(frame: VC.view.frame)
//                    VC.view.addSubview(imageView)
//                    imageView.image = image
//                    imageView.contentMode = .center
//                    self.navigationController?.pushViewController(VC, animated: true)
                }
                print("send msg")
            })
        }
    }
    
    func recieveMessage(){
        AgentWrapper.shared.transport?.getData(completion: { [unowned self](recievedData) in
            guard let jsonString = recievedData else {return}
            let msgData = Data(jsonString.utf8)
            guard let walletHandle = self.walletHandle else{return}
            AgentWrapper.shared.unpackMessage(message: msgData, walletHandle: walletHandle) {[unowned self] (error, data) in
                if let recievedData = data {
                    let recievedMsg = String.init(decoding: recievedData, as: UTF8.self)
                    self.recievedMsgLabel.text = recievedMsg
                }
            }
            print("get did")
        })
       
    }
}

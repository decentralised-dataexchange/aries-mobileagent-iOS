//
//  SplashViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 19/01/21.
//

import UIKit

class SplashViewController: AriesBaseViewController {
    @IBOutlet weak var loadingStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
            let mainStoryBoard = UIStoryboard(name: "AriesMobileAgent", bundle: nil)
            let walletVC = mainStoryBoard.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
            self.openWallet(model: walletVC.viewModel) {[unowned self] (success) in
                DispatchQueue.main.async {
                    self.navigationController?.viewControllers = [walletVC];
            }
        }
    }
    
    func createWallet(model: WalletViewModel,completion: @escaping (Bool?) -> Void) {
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let config = "{\"id\": \"\(deviceID)\"}"
        let credentials = "{\"key\": \"\(deviceID)\"}"
        AgentWrapper.shared.createWallet(withConfig: config, credentials: credentials, completion: { [unowned self](error) in
            if (error != nil) {
                print("wallet created")
    self.openWallet(model: model,completion: completion)
            }
        })
    }
    
    func openWallet(model: WalletViewModel,completion: @escaping (Bool?) -> Void) {
        self.loadingStatus.text = "Configuring wallet...".localized()
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let config = "{\"id\": \"\(deviceID)\"}"
        let credentials = "{\"key\": \"\(deviceID)\"}"
        AgentWrapper.shared.openWallet(withConfig: config, credentials: credentials) {[unowned self] (error, indyHandle) in
            if (indyHandle == 0){
                self.createWallet(model: model,completion: completion)
            } else {
                model.walletHandle = indyHandle
                print("wallet opened")
                model.checkMediatorConnectionAvailable()
                self.loadingStatus.text = "Configuring pool...".localized()
                AriesPoolHelper.shared.configurePool(walletHandler: indyHandle,completion: completion)
            }
        }
    }
}

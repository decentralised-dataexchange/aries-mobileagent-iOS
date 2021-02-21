//
//  ConnectionPopupViewController.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 18/12/20.
//

import UIKit
import Loady
import SVProgressHUD



class ConnectionPopupViewController: AriesBaseViewController {

    @IBOutlet weak var orgImage: UIImageView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var connectButton: LoadyButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    var viewModel: ConnectionPopupViewModel?
    var completion: ((CloudAgentConnectionWalletModel,String,String) -> Void)?
    var orgName: String? {
        didSet{
//            self.descriptionLabel.attributedText = NSMutableAttributedString().normal("Allow".localized()).bold(" " + (orgName ?? "")).normal(" ").normal("to connect with you".localized())
            self.descriptionLabel.text = orgName ?? ""
        }
    }
    
    static func showConnectionPopup(orgName: String?,orgImageURL: String?,walletHandler: IndyHandle?,recipientKey: String?,serviceEndPoint: String?,routingKey: [String]?,isFromDataExchange: Bool,completion: @escaping ((CloudAgentConnectionWalletModel?,String?,String?) -> Void)){ //connmodel,recipeintkey,myverkey
        SVProgressHUD.show()

        //check connection with same Org Exist
        AriesCloudAgentHelper.shared.checkConnectionWithSameOrgExist(walletHandler: walletHandler ?? IndyHandle(), label: orgName ?? "", theirVerKey: recipientKey ?? "", serviceEndPoint: serviceEndPoint ?? "", routingKey: routingKey, imageURL: orgImageURL ?? "",isFromDataExchange: isFromDataExchange) { (connectionExist, orgDetails,connModel) in
            if !isFromDataExchange{
                SVProgressHUD.dismiss()
            }
            
            if let connectionModel = connModel {
                if connectionExist {
                    AriesAgentFunctions.shared.getMyDidWithMeta(walletHandler: walletHandler ?? IndyHandle(), myDid: connModel?.value?.myDid ?? "", completion: { (metadataRecieved,metadata, error) in
                        let metadataDict = UIApplicationUtils.shared.convertToDictionary(text: metadata ?? "")
                        if let verKey = metadataDict?["verkey"] as? String {
                            completion(connectionModel ,connectionModel.value?.reciepientKey ?? "",verKey)
                        }
                    })
                    return
                }
            }
            
            if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "ConnectionPopupViewController") as? ConnectionPopupViewController {
                controller.viewModel = ConnectionPopupViewModel.init(orgName: orgName, orgImageURL: orgImageURL, walletHandler: walletHandler, recipientKey: recipientKey, serviceEndPoint: serviceEndPoint, routingKey: routingKey,orgId:orgDetails?.orgId ,orgDetails: orgDetails)
                controller.modalPresentationStyle = .overFullScreen
                controller.completion = completion
                let VC = UIApplicationUtils.shared.getTopVC()
                if let navVC = VC as? UINavigationController {
                    let firstVC = navVC.viewControllers.first ?? navVC
                    firstVC.present(controller, animated: false, completion: nil)
                    return
                }
                DispatchQueue.main.async {
                    VC?.present(controller, animated: false, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        connectButton.setAnimation(LoadyAnimationType.android())
        self.orgName = viewModel?.orgName ?? ""
        UIApplicationUtils.shared.setRemoteImageOn(self.orgImage, url: viewModel?.orgImageURL)
        self.connectButton.layer.cornerRadius = 15
        self.rejectButton.layer.cornerRadius = 15
        self.orgImage.layer.cornerRadius = 40
        self.baseView.layer.cornerRadius = 20
        self.shadowView.setShadowWithColor(color: .gray, opacity: 0.5, offset: CGSize.zero, radius: 5, viewCornerRadius: 40)
        connectButton.backgroundColor = AriesMobileAgent.themeColor
//        rejectButton.backgroundColor = AriesMobileAgent.themeColor.withAlphaComponent(0.7)
        connectButton.loadingColor = AriesMobileAgent.themeColor
        connectButton.backgroundFillColor = AriesMobileAgent.themeColor
        self.view.backgroundColor = .clear
    }

    override func localizableValues() {
        super.localizableValues()
        self.connectButton.setTitle("Connect".localized(), for: .normal)
        self.orgName = viewModel?.orgName ?? ""
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        connectButton.isUserInteractionEnabled = false
        connectButton.startLoading()
//        rejectButton.isHidden = true
        viewModel?.startConnection()
    }
}

extension ConnectionPopupViewController: ConnectionPopupViewModelDelegate{
    func connectionEstablised(connModel:CloudAgentConnectionWalletModel, recipientKey: String, myVerKey:String) {
        connectButton.stopLoading()
        connectButton.isUserInteractionEnabled = true
        self.dismiss(animated: false, completion: nil)
        if let completionBlock = completion {
            completionBlock(connModel,recipientKey,myVerKey)
        }
    }
    
    func dismissPopup(){
        self.dismiss(animated: false, completion: nil)
    }
}

//
//  WalletViewController.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 14/11/20.
//

import Foundation
import SVProgressHUD

class WalletViewController: AriesBaseViewController,WalletDelegate{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exchangeButton: UIButton!
    var viewModel = WalletViewModel()
    @IBOutlet weak var titleLabel: UILabel!
    var themeColor = UIColor.black
    @IBOutlet weak var searchBarBgView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var notifactionButtonNavBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        AriesMobileAgent.themeColor = themeColor
        
        self.navigationController?.navigationBar.barTintColor =  #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9647058824, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.backgroundColor =  #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9647058824, alpha: 1)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWallet), name: Constants.reloadWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkNewNotif), name: Constants.didRecieveCertOffer, object: nil)

      //  viewModel.openWallet()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
        searchBar.delegate = self
        self.title = ""
        exchangeButton.backgroundColor = AriesMobileAgent.themeColor
        exchangeButton.layer.cornerRadius = 23
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
//        searchBarBgView.layer.borderColor = UIColor.darkGray.cgColor
//        searchBarBgView.layer.borderWidth = 0.5
        searchBarBgView.layer.cornerRadius = 8
        searchBar.removeBg()
        self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.titleLabel.text = "Data Wallet".localized()
        self.exchangeButton.setTitle("Exchange data".localized(), for: .normal)
        self.searchBar.placeholder = "Search".localized()
        self.cancelButton.setTitle("Cancel".localized(), for: .normal)
        self.tableView.reloadData()
    }
    
    @objc func checkNewNotif() {
        viewModel.fetchNotifications { [unowned self] (success) in
            if success {
                self.notifactionButtonNavBarItem.image = UIImage(systemName: "bell.badge")
            } else {
                self.notifactionButtonNavBarItem.image = UIImage(systemName: "bell")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNewNotif()
        self.searchBar.placeholder = "Search".localized()
    }
    
    @objc func reloadWallet(){
        viewModel.getSavedCertificates()
        checkNewNotif()
    }
    
    @IBAction func exchangeDataAction(_ sender: Any) {
        self.initaiateNewExchangeData()
    }
    
    func walletDataUpdated() {
        self.tableView.reloadData()
        checkNewNotif()
    }
    
    @IBAction func addNewCertificate(_ sender: Any) {
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "OrganisationListViewController") as? OrganisationListViewController {
            controller.viewModel = OrganisationListViewModel.init(walletHandle: viewModel.walletHandle,mediatorVerKey: WalletViewModel.mediatorVerKey)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func tappedOnSettings(_ sender: Any) {
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "SettingsViewController") as? SettingsViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func searchBarCancelButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.cancelButton.isEnabled = false
    }
    
    @IBAction func tappedOnNotificationIcon(_ sender: Any) {
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "NotificationListViewController") as? NotificationListViewController {
            controller.viewModel = NotificationsListViewModel.init(walletHandle: viewModel.walletHandle)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


extension WalletViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.searchCert.count == 0 {
            self.tableView.setEmptyMessage(viewModel.certificates.count == 0 ? "No data available".localized() : "No result found".localized())
            } else {
                self.tableView.restore()
            }
        return viewModel.searchCert.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WalletCredentialTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "WalletCredentialTableViewCell") as? WalletCredentialTableViewCell
        let cert = viewModel.searchCert[indexPath.row]
        let schemeSeperated = cert.value?.schemaID?.split(separator: ":")
        cell?.certName.text = "\(schemeSeperated?[2] ?? "")".uppercased()
        cell?.deleteButton.addTarget(self, action: #selector(deleteCredential(sender:)), for: .touchUpInside)
        cell?.deleteButton.tag = indexPath.row
        cell?.orgName.text = cert.value?.connectionInfo?.value?.theirLabel ?? ""
        cell?.locationName.text = cert.value?.connectionInfo?.value?.orgDetails?.location ?? ""
        UIApplicationUtils.shared.setRemoteImageOn((cell?.certLogo)!, url: cert.value?.connectionInfo?.value?.imageURL ?? "")
        cell?.selectionStyle = .none
        if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
            cell?.separatorInset = UIEdgeInsets(top: 0, left: cell?.bounds.size.width ?? 0, bottom: 0, right: 0)
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cert = viewModel.searchCert[indexPath.row]
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "WalletCertificateDetailViewController") as? WalletCertificateDetailViewController {
            controller.viewModel = WalletCertificateDetailViewModel.init(walletHandle: viewModel.walletHandle, reqId: cert.value?.certInfo?.id, certDetail: cert.value?.certInfo,inboxId: nil, certModel: cert)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func deleteCredential(sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            let cert = self.viewModel.searchCert[sender.tag]
            self.viewModel.deleteCredentialWith(id: cert.value?.referent?.referent ?? "",walletRecordId: cert.id)
            alert.dismiss(animated: true, completion: nil)
              }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
              }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension WalletViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearchedItems(searchString: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.cancelButton.isEnabled = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.cancelButton.isEnabled = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

//Cloud connection
extension WalletViewController: QRScannerViewDelegate {
    func initaiateNewExchangeData(){
        AgentWrapper.shared.transport = QRTransportMode()
        let newVC = UIViewController()
        let qrScannerView = QRScannerView(frame: newVC.view.bounds)
        newVC.view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self)
        qrScannerView.startRunning()
        newVC.title = "Scan"
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        self.navigationController?.popViewController(animated: true)
        let value = "\(code.split(separator: "=").last ?? "")".decodeBase64() ?? ""
        let data = UIApplicationUtils.shared.convertToDictionary(text: value)
        let qrModel = ExchangeDataQRCodeModel.decode(withDictionary: data as NSDictionary? ?? NSDictionary()) as? ExchangeDataQRCodeModel
        if qrModel?.invitationURL == nil {
            SVProgressHUD.show()
            if code.contains("igrantio-operator/data-exchange/qr-link") {
                NetworkManager.shared.baseURL = code
                NetworkManager.shared.getQRCodeDetails { (newInvitationData) in
//                    let newDict = try? JSONSerialization.jsonObject(with: newInvitationData ?? Data(), options: []) as? [String : Any]
                    let newInv = String(decoding: newInvitationData ?? Data(), as: UTF8.self)
                    print("QRData ... \(newInv)")
                    let newDict = UIApplicationUtils.shared.convertToDictionary(text: newInv)
                    let invitationURL = newDict?["dataexchange_url"] as? String ?? ""
                    let newValue = "\(invitationURL.split(separator: "=").last ?? "")".decodeBase64() ?? ""
                    let newInvDict = UIApplicationUtils.shared.convertToDictionary(text: newValue)
                    let newQRModel = ExchangeDataQRCodeModel.decode(withDictionary: newInvDict as NSDictionary? ?? NSDictionary()) as? ExchangeDataQRCodeModel

                    SVProgressHUD.dismiss()
                    if newQRModel?.invitationURL == nil {
                        UIApplicationUtils.showErrorSnackbar(message: "Sorry, could not open scan content".localized())
                        return
                    }
                    if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "ExchangeDataPreviewViewController") as? ExchangeDataPreviewViewController {
                        controller.viewModel = ExchangeDataPreviewViewModel.init(walletHandle: self.viewModel.walletHandle, reqDetail: nil,QRData: newQRModel,isFromQR: true,inboxId: nil,connectionModel: nil,QR_ID: "\(code.split(separator: "/").last ?? "")")
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    return
                }
            } else {
                SVProgressHUD.dismiss()
                UIApplicationUtils.showErrorSnackbar(message: "Sorry, could not open scan content".localized())
                return
            }
        } else {
            if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "ExchangeDataPreviewViewController") as? ExchangeDataPreviewViewController {
                controller.viewModel = ExchangeDataPreviewViewModel.init(walletHandle: viewModel.walletHandle, reqDetail: nil,QRData: qrModel,isFromQR: true,inboxId: nil,connectionModel: nil)
                self.navigationController?.pushViewController(controller, animated: true)
            }

        }
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        
    }
    
}

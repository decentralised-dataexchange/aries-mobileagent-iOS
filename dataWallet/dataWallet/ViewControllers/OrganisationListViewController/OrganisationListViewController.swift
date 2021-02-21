//
//  OrganisationListViewController.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 06/12/20.
//

import Foundation
import Kingfisher
import SVProgressHUD

class OrganisationListViewController: AriesBaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel : OrganisationListViewModel?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionViewBaseView: UIView!
    @IBOutlet weak var orgHeaderLabel: UILabel!
    @IBOutlet weak var orgDescriptionLabel: UILabel!
    @IBOutlet weak var searchBarBgView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        collectionView.delegate = self
        collectionView.dataSource = self
        viewModel?.delegate = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        viewModel?.fetchOrgList(completion: { [unowned self] (success) in
            self.collectionView.reloadData()
        })
        searchBar.delegate = self
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
//        searchBarBgView.layer.borderColor = UIColor.darkGray.cgColor
//        searchBarBgView.layer.borderWidth = 0.5
        searchBarBgView.layer.cornerRadius = 8
        searchBar.removeBg()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: Constants.reloadOrgList, object: nil)
    }
    
    @objc func reloadList() {
        viewModel?.fetchOrgList(completion: { [unowned self] (success) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.collectionView.reloadData()
            })
        })
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.orgHeaderLabel.text = "Organisations".localized()
        self.orgDescriptionLabel.text = "Choose the organisation to add data to the data wallet. For adding new organisations, click + above".localized()
        self.searchBar.placeholder = "Search".localized()
        self.cancelButton.setTitle("Cancel".localized(), for: .normal)
        self.collectionView.reloadData()
    }
    
    func setupUI() {
//        collectionViewBaseView.layer.borderColor = UIColor.lightGray.cgColor
        collectionViewBaseView.layer.cornerRadius = 10
//        collectionViewBaseView.layer.borderWidth = 1
//        let button = UIButton(type: .custom)
//        if #available(iOS 13.0, *) {
//            button.setImage(UIImage.init(systemName: "plus.circle"), for: .normal)
//        } else {
//            button.setTitle("+", for: .normal)
//        }
//        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
//        button.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
//        let barButton = UIBarButtonItem(customView: button)
//        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchBar.placeholder = "Search".localized()
    }
    
    @IBAction func addNewOrgButtonAction(_ sender: Any) {
        self.initaiateNewConnectionToCloudAgent()
    }
    
    @IBAction func searchBarCancelButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.cancelButton.isEnabled = false
    }
//    @objc func addButtonPressed() {
//        self.initaiateNewConnectionToCloudAgent()
//    }
}

extension OrganisationListViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel?.searchedConnections?.count == 0 || viewModel?.searchedConnections == nil {
            self.collectionView.setEmptyMessage(self.searchBar.text == "" ? "No connections available".localized() : "No result found".localized())
            self.collectionViewBaseView.backgroundColor = self.view.backgroundColor
            } else {
                self.collectionView.restore()
                self.collectionViewBaseView.backgroundColor = .white

            }
        return viewModel?.searchedConnections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrganisationListCollectionViewCell", for: indexPath as IndexPath) as! OrganisationListCollectionViewCell
        let connection = viewModel?.searchedConnections?[indexPath.row]
        cell.orgName.text = connection?.value?.theirLabel != "" ? connection?.value?.theirLabel : "No Name".localized()
        cell.orgImage.layer.cornerRadius = 30
        UIApplicationUtils.shared.setRemoteImageOn(cell.orgImage, url: connection?.value?.imageURL ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - (5 * 3))/3, height: 120.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel?.searchedConnections?[indexPath.row]
        UIPasteboard.general.string = item?.value?.myDid ?? ""
        if item?.value?.isIgrantAgent == "1" {
            if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "IgrantAgentOrgDetailViewController") as? IgrantAgentOrgDetailViewController {
                controller.viewModel = IgrantAgentOrgDetailViewModel.init(walletHandle: viewModel?.walletHandle,reqId: item?.value?.requestID, isiGrantOrg: item?.value?.isIgrantAgent == "1")
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "CertificateListViewController") as? CertificateListViewController {
                controller.viewModel = CertificateListViewModel.init(walletHandle: viewModel?.walletHandle, reqId: item?.value?.requestID,connectionModel:item?.value)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
    }
}

//Cloud connection
extension OrganisationListViewController: QRScannerViewDelegate {
    func initaiateNewConnectionToCloudAgent(){
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
        let dataDID = UIApplicationUtils.shared.convertToDictionary(text: value)
        let recipientKey = (dataDID?["recipientKeys"] as? [String])?.first ?? ""
        let label = dataDID?["label"] as? String ?? ""
        let serviceEndPoint = dataDID?["serviceEndpoint"] as? String ?? ""
        let routingKey = (dataDID?["routingKeys"] as? [String]) ?? []
        let imageURL = dataDID?["imageUrl"] as? String ?? (dataDID?["image_url"] as? String ?? "")
        NetworkManager.shared.baseURL = serviceEndPoint
        
        if serviceEndPoint == "" {
            SVProgressHUD.show()
            if code.contains("igrantio-operator/connection/qr-link") {
                NetworkManager.shared.baseURL = code
                NetworkManager.shared.getQRCodeDetails { (newInvitationData) in
                    let newInv = String(decoding: newInvitationData ?? Data(), as: UTF8.self)
                    print("QRData ... \(newInv)")
                    let newDict = UIApplicationUtils.shared.convertToDictionary(text: newInv)
                    let invitationURL = newDict?["invitation_url"] as? String ?? ""
                    let newValue = "\(invitationURL.split(separator: "=").last ?? "")".decodeBase64() ?? ""
                    let newInvDict = UIApplicationUtils.shared.convertToDictionary(text: newValue)
                    let newRecipientKey = (newInvDict?["recipientKeys"] as? [String])?.first ?? ""
                    let newLabel = newInvDict?["label"] as? String ?? ""
                    let newServiceEndPoint = newInvDict?["serviceEndpoint"] as? String ?? ""
                    let newRoutingKey = (newInvDict?["routingKeys"] as? [String]) ?? []
                    let newImageURL = newInvDict?["imageUrl"] as? String ?? (newInvDict?["image_url"] as? String ?? "")
                    SVProgressHUD.dismiss()
                    NetworkManager.shared.baseURL = newServiceEndPoint
                    if newServiceEndPoint == "" {
                        UIApplicationUtils.showErrorSnackbar(message: "Sorry, could not open scan content".localized())
                        return
                    }
                    self.viewModel?.newConnectionConfigCloudAgent(label: newLabel, theirVerKey: newRecipientKey, serviceEndPoint: newServiceEndPoint,routingKey: newRoutingKey,imageURL: newImageURL,completion: {[unowned self] (success) in
                        self.viewModel?.fetchOrgList(completion: { [unowned self] (success) in
                            self.collectionView.reloadData()
                        })
                    })
                    return
                }
            } else {
                SVProgressHUD.dismiss()
                UIApplicationUtils.showErrorSnackbar(message: "Sorry, could not open scan content".localized())
                return
            }
        } else {
            self.viewModel?.newConnectionConfigCloudAgent(label: label, theirVerKey: recipientKey, serviceEndPoint: serviceEndPoint,routingKey: routingKey,imageURL: imageURL,completion: {[unowned self] (success) in
                self.viewModel?.fetchOrgList(completion: { [unowned self] (success) in
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        
    }
    
}

extension OrganisationListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.updateSearchedItems(searchString: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.cancelButton.isEnabled = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.cancelButton.isEnabled = false
    }
}

extension OrganisationListViewController: OrganisationListDelegate {
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

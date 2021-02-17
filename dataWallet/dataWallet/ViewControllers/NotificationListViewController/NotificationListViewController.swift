//
//  ExchangeDataListViewController.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 14/12/20.
//

import UIKit

class NotificationListViewController: AriesBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel : NotificationsListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchAllnotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchAllnotifications), name: Constants.didRecieveCertOffer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchAllnotifications), name: Constants.didRecieveDataExchangeRequest, object: nil)
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
    
    @objc func fetchAllnotifications(){
            viewModel?.fetchNotifications(completion: {[unowned self] (success) in
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
            })
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.title = "Notifications".localized()
    }
//    @objc func addButtonPressed() {
//        self.initaiateNewExchangeData()
//    }
}

extension NotificationListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NotificationTableViewCell",for: indexPath) as! NotificationTableViewCell
        
        let inboxData = viewModel?.notifications?[indexPath.row]
        let type = inboxData?.value?.type
        if type == InboxType.certOffer.rawValue {
            let offer = inboxData?.value?.offerCredential
            let schemeSeperated = offer?.value?.schemaID?.split(separator: ":")
            cell.certName?.text = "\(schemeSeperated?[2] ?? "")"
            cell.notificationType.text = "Data agreement".localized()
            let dateFormat = DateFormatter.init()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS'Z'"
            if let notifDate = dateFormat.date(from: offer?.value?.updatedAt ?? "") {
                cell.time.text = notifDate.timeAgoDisplay()
            }
        } else {
            let req = inboxData?.value?.presentationRequest
            cell.certName?.text = req?.value?.presentationRequest?.name ?? ""
            cell.notificationType.text = "Data exchange".localized()
            let dateFormat = DateFormatter.init()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS'Z'"
            if let notifDate = dateFormat.date(from: req?.value?.updatedAt ?? "") {
                cell.time.text = notifDate.timeAgoDisplay()
            }
        }
       
        UIApplicationUtils.shared.setRemoteImageOn(cell.orgImage, url: inboxData?.value?.connectionModel?.value?.imageURL ?? "")
        cell.shadowView.layer.cornerRadius = 20
//        cell.shadowView.layer.shadowColor = UIColor.lightGray.cgColor
//        cell.shadowView.layer.shadowOpacity = 0.5
//        cell.shadowView.layer.shadowOffset = .zero
//        cell.shadowView.layer.shadowRadius = 5
        cell.selectionStyle = .none
        if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width , bottom: 0, right: 0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel?.notifications?.count ?? 0 == 0 {
            self.tableView.setEmptyMessage("No new notification available".localized())
        } else {
            self.tableView.restore()
        }
        return viewModel?.notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inboxData = viewModel?.notifications?[indexPath.row]
        let type = inboxData?.value?.type
        if type == InboxType.certOffer.rawValue {
            let offer = inboxData?.value?.offerCredential
            if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "CertificatePreviewViewController") as? CertificatePreviewViewController {
                controller.viewModel = CertificatePreviewViewModel.init(walletHandle: viewModel?.walletHandle, reqId: inboxData?.value?.connectionModel?.id ?? "", certDetail: offer, inboxId: inboxData?.id)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            let req = inboxData?.value?.presentationRequest
            if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "ExchangeDataPreviewViewController") as? ExchangeDataPreviewViewController {
                controller.viewModel = ExchangeDataPreviewViewModel.init(walletHandle: viewModel?.walletHandle, reqDetail: req, inboxId: inboxData?.id,connectionModel:inboxData?.value?.connectionModel)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
       
    }
}


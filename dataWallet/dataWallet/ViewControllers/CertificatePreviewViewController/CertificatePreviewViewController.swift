//
//  AcceptCertificateViewController.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 06/12/20.
//

import UIKit
import Foundation

class CertificatePreviewViewController: AriesBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var certificateName: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    var viewModel: CertificatePreviewViewModel?
    var isCertDetail: Bool = false
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var infoText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel?.delegate = self
        self.tableView.estimatedRowHeight(40)
        self.tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
//        certificateName.text = "\(viewModel?.certDetail?.value?.schemaID?.split(separator: ":")[2] ?? "")"
        acceptButton.layer.cornerRadius = 25
        rejectButton.layer.cornerRadius = 25
        acceptButton.backgroundColor = AriesMobileAgent.themeColor
        rejectButton.backgroundColor = AriesMobileAgent.themeColor.withAlphaComponent(0.7)
        if isCertDetail {
            buttonView.isHidden = true
            infoText.isHidden = true
        }
        tableView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.performWithoutAnimation {
            tableView.alpha = 1
            tableView.beginUpdates()
            tableView.endUpdates()
           }
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.title = "Data agreement".localized()
        if isCertDetail {
            self.title = "Certificate Detail".localized()
        }
        self.infoText.text = "Your data certificate is available to be added to your wallet. Click accept to confirm.".localized()
        self.acceptButton.setTitle("Accept".localized(), for: .normal)
    }
    
    @IBAction func acceptButtonTapped(sender: Any) {
        viewModel?.acceptCertificate()
    }
    
    @IBAction func rejectButtonTapped(sender: Any) {
        if isCertDetail {
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this item?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { [self] action in
                self.viewModel?.deleteCredentialWith(id: self.viewModel?.certModel?.value?.referent?.referent ?? "", walletRecordId: viewModel?.certModel?.id)
                alert.dismiss(animated: true, completion: nil)
                  }))
            alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: { action in
                alert.dismiss(animated: true, completion: nil)
                  }))
            self.present(alert, animated: true, completion: nil)
         return
        }
        viewModel?.rejectCertificate()
    }
}

extension CertificatePreviewViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1//viewModel?.certDetail?.value?.credentialProposalDict?.credentialProposal?.attributes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CertificateWithDataTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CertificateWithDataTableViewCell") as? CertificateWithDataTableViewCell
        cell?.certData = viewModel?.certDetail?.value?.credentialProposalDict?.credentialProposal?.attributes ?? []
        let schemeSeperated = viewModel?.certDetail?.value?.schemaID?.split(separator: ":")
        cell?.certName.text = "\(schemeSeperated?[2] ?? "")".uppercased()
        cell?.addButton.isHidden = true
        cell?.selectionStyle = .none
        cell?.layoutSubviews()
        return cell ?? UITableViewCell()
    }
}

extension CertificatePreviewViewController: CertificatePreviewDelegate{
    func popVC() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

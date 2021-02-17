//
//  ExchangeDataPreviewViewController.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 14/12/20.
//

import UIKit

class ExchangeDataPreviewViewController: AriesBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var reqName: UILabel!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    var viewModel: ExchangeDataPreviewViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel?.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        
        //        reqName.text = viewModel?.isFromQR ?? false ? "\(viewModel?.QRData?.proofRequest?.name ?? "")" : "\(viewModel?.reqDetail?.value?.presentationRequest?.name ?? "")"
        viewModel?.getCredsForProof(completion: {[unowned self] (success) in
            self.tableView.reloadData()
            self.infoText.attributedText = NSMutableAttributedString().normal("By choosing exchange you agree to share the requested data to".localized()).bold(" " + (self.viewModel?.orgName ?? "" ))
        })
        infoText.attributedText = NSMutableAttributedString().normal("By choosing exchange you agree to share the requested data to".localized()).bold(" " + (viewModel?.orgName ?? "" ))
        acceptButton.layer.cornerRadius = 25
        rejectButton.layer.cornerRadius = 25
        acceptButton.backgroundColor = AriesMobileAgent.themeColor
        rejectButton.backgroundColor = AriesMobileAgent.themeColor.withAlphaComponent(0.7)
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.title = "Data agreement".localized()
        self.infoText.text = "You requested the following data to be issued. By choosing accept you agree to add the data to your wallet.".localized()
        self.acceptButton.setTitle("Accept".localized(), for: .normal)
        self.tableView.reloadData()
        self.tableView.contentInset = UIEdgeInsets(top: -(navigationController?.navigationBar.frame.height ?? 44), left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func acceptButtonTapped(sender: Any) {
        viewModel?.checkConnection()
    }
    
    @IBAction func rejectButtonTapped(sender: Any) { //delete
        let alert = UIAlertController(title: "Alert", message: "Do you want to cancel the exchange request?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { [self] action in
            viewModel?.rejectCertificate()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ExchangeDataPreviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CertificateWithDataTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CertificateWithDataTableViewCell") as? CertificateWithDataTableViewCell
        let attrArray = viewModel?.attributelist.map({ (item) -> SearchCertificateAttribute in
            return SearchCertificateAttribute.init(name: item.name, value: item.value)
        }) ?? []
        cell?.certData = attrArray
        cell?.addButton.isHidden = true
        cell?.certName.text = viewModel?.isFromQR ?? false ? "\(viewModel?.QRData?.proofRequest?.name ?? "")" : "\(viewModel?.reqDetail?.value?.presentationRequest?.name ?? "")"
        cell?.selectionStyle = .none
        cell?.layoutIfNeeded()
        return cell ?? UITableViewCell()
    }
}

extension ExchangeDataPreviewViewController: ExchangeDataPreviewViewModelDelegate {
    
    func goBack() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Constants.reloadWallet, object: nil)
            if (self.viewModel?.isFromQR ?? false) {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: Constants.didRecieveDataExchangeRequest, object: nil)
            }
        }
    }
    
    func showError(message: String) {
        
    }
    
    func refresh() {
        //        reqName.text = "\(viewModel?.reqDetail?.value?.presentationRequest?.name ?? "")"
        self.tableView.reloadData()
    }
    
}

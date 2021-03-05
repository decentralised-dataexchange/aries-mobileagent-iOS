//
//  WalletCertificateDetailViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 22/01/21.
//

import UIKit

class WalletCertificateDetailViewController: AriesBaseViewController,UITableViewDelegate, UITableViewDataSource,WalletCertificateDetailDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel: WalletCertificateDetailViewModel?
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet var topConstraint : NSLayoutConstraint!
    @IBOutlet var topBarItemConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel?.getOrgInfo(completion: {[unowned self] (success) in
            self.tableView.reloadData()
        })
        viewModel?.delegate = self
        setupUI()
    }
    
    func setupUI() {
        if UIDevice.current.hasNotch {
            topConstraint.constant = -45.0
            topBarItemConstraint.constant = -15.0
        }
        tableView.estimatedRowHeight = 40
        self.tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        backBtn.layer.cornerRadius =  backBtn.frame.size.height/2
        moreBtn.layer.cornerRadius =  moreBtn.frame.size.height/2
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
        
    func popVC() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backButtonClicked(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let orgCell = tableView.dequeueReusableCell(withIdentifier:"WalletDetailTopSectionTableViewCell",for: indexPath) as! WalletDetailTopSectionTableViewCell
                orgCell.nameLbl.text = viewModel?.orgInfo?.name ?? (viewModel?.certModel?.value?.connectionInfo?.value?.theirLabel ?? "")
                orgCell.locationLbl.text = viewModel?.orgInfo?.location ?? ""
                UIApplicationUtils.shared.setRemoteImageOn(orgCell.logoImageView, url: viewModel?.orgInfo?.logoImageURL ?? (viewModel?.certModel?.value?.connectionInfo?.value?.imageURL ?? ""))
                UIApplicationUtils.shared.setRemoteImageOn(orgCell.orgImageView, url: viewModel?.orgInfo?.coverImageURL ?? (viewModel?.certModel?.value?.connectionInfo?.value?.orgDetails?.coverImageURL ?? ""),placeholderImage: #imageLiteral(resourceName: "00_Default_CoverImage_02-min"))
                orgCell.selectionStyle = .none
                return orgCell
            case 1:
                let cell:CertificateWithDataTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CertificateWithDataTableViewCell") as? CertificateWithDataTableViewCell
                cell?.certData = viewModel?.certDetail?.value?.credentialProposalDict?.credentialProposal?.attributes ?? []
                let schemeSeperated = viewModel?.certDetail?.value?.schemaID?.split(separator: ":")
                cell?.certName.text = "\(schemeSeperated?[2] ?? "")".uppercased()
                cell?.selectionStyle = .none
                return cell ?? UITableViewCell()
            default:
                let cell:WalletDetailDeleteTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "WalletDetailDeleteTableViewCell") as? WalletDetailDeleteTableViewCell
                cell?.selectionStyle = .none
                cell?.name.text = "Remove data card".localized()
                if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
                    cell?.separatorInset = UIEdgeInsets(top: 0, left: cell?.bounds.size.width ?? 0, bottom: 0, right: 0)
                }
                return cell ?? UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch  indexPath.row {
            case 0: return 235
            case 1: return UITableView.automaticDimension
//                CGFloat(((viewModel?.certDetail?.value?.credentialProposalDict?.credentialProposal?.attributes ?? []).count * 45 + 60))
            default:
                return 70
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{ //delete
            let alert = UIAlertController(title: "Alert", message: "Do you want to delete the certificate?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self] action in
                self.viewModel?.deleteCredentialWith(id: self.viewModel?.certModel?.value?.referent?.referent ?? "", walletRecordId: viewModel?.certModel?.id)
                alert.dismiss(animated: true, completion: nil)
                  }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                alert.dismiss(animated: true, completion: nil)
                  }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

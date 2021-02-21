//
//  LedgerListViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 18/01/21.
//

import UIKit

class LedgerListViewController: AriesBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    public static var ledgers = [Constants.ledger_igrant_sandbox,Constants.ledger_igrant_old_sandbox, Constants.ledger_sovrin_builder, Constants.ledger_sovrin_live, Constants.ledger_sovrin_sandbox]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.borderWidth = 10
        self.tableView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.title = "Ledger".localized()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        heightConstraint.constant = CGFloat(55 * LedgerListViewController.ledgers.count) + 5
    }
}

extension LedgerListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = LedgerListViewController.ledgers[indexPath.row]
        let selectedLedgerindex = UserDefaults.standard.value(forKey: Constants.userDefault_ledger) as? Int ?? 0
        if (LedgerListViewController.ledgers[selectedLedgerindex] == LedgerListViewController.ledgers[indexPath.row]){
            cell.accessoryView = UIImageView.init(image: #imageLiteral(resourceName: "checked"))
        } else {
            cell.accessoryView = nil
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LedgerListViewController.ledgers.count 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if let walletHandler = WalletViewModel.openedWalletHandler {
            UserDefaults.standard.setValue(index, forKey: Constants.userDefault_ledger)
            AriesPoolHelper.shared.configurePool(walletHandler: walletHandler) {[unowned self] (success) in
                
            }
            self.tableView.reloadData()
        }
    }
}

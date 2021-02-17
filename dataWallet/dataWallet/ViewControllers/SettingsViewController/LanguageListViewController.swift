//
//  LanguageListViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 18/01/21.
//

import UIKit
import Localize_Swift

class LanguageListViewController: AriesBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    public static var language = ["English", "Svenska", "Dansk"]
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var languageCode = ["en", "sv", "da"]
    
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
        self.title = "Language".localized()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        heightConstraint.constant = CGFloat(55 * LanguageListViewController.language.count)
    }
}

extension LanguageListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = LanguageListViewController.language[indexPath.row]
        let index = (UserDefaults.standard.value(forKey: Constants.userDefault_language) as? Int ?? 0)
        if (LanguageListViewController.language[index] == LanguageListViewController.language[indexPath.row]){
            let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            cell.accessoryType = UITableViewCell.AccessoryType.none
            icon.image = #imageLiteral(resourceName: "checked")
            cell.accessoryView = icon
        } else {
            cell.accessoryView = nil
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LanguageListViewController.language.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        UserDefaults.standard.setValue(index, forKey: Constants.userDefault_language)
        Localize.setCurrentLanguage(languageCode[index])
        self.tableView.reloadData()
    }
}

//
//  SettingsViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 16/01/21.
//

import UIKit
import Localize_Swift

class SettingsViewController: AriesBaseViewController {
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var ledgerLabel: UILabel!
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var ledgerButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!

    @IBOutlet weak var poweredByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        languageButton.layer.borderColor = UIColor.gray.cgColor
//        ledgerButton.layer.borderColor = UIColor.gray.cgColor
//        languageButton.layer.borderWidth = 0.5
//        ledgerButton.layer.borderWidth = 0.5
        languageButton.layer.cornerRadius = 8
        ledgerButton.layer.cornerRadius = 8
        aboutButton.layer.cornerRadius = 8
        
        if UserDefaults.standard.value(forKey: Constants.userDefault_language) == nil {
            UserDefaults.standard.setValue(0, forKey: Constants.userDefault_language)
            self.languageButton.setTitle(LanguageListViewController.language.first, for: .normal)
        } else {
            if let index = UserDefaults.standard.value(forKey: Constants.userDefault_language) as? Int {
                self.languageButton.setTitle(LanguageListViewController.language[index], for: .normal)
            }
        }
       
        if UserDefaults.standard.value(forKey: Constants.userDefault_ledger) == nil {
            UserDefaults.standard.setValue(0, forKey: Constants.userDefault_ledger)
            self.ledgerButton.setTitle(LedgerListViewController.ledgers.first, for: .normal)
        } else {
            if let index = UserDefaults.standard.value(forKey: Constants.userDefault_ledger) as? Int {
                self.ledgerButton.setTitle(LedgerListViewController.ledgers[index], for: .normal)
            }
        }
       
    }
    
    override func localizableValues() {
        super.localizableValues()
        self.title = "Settings".localized()
        self.languageLabel.text = "LANGUAGE".localized()
        self.ledgerLabel.text = "LEDGER NETWORK".localized()
        self.poweredByLabel.text = "Powered by iGrant.io, Sweden".localized()
        let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.appVersion.text = "Version".localized() + ": " + appVersionString
        self.aboutButton.setTitle("About".localized(), for: .normal)
        if UserDefaults.standard.value(forKey: Constants.userDefault_language) == nil {
            UserDefaults.standard.setValue(0, forKey: Constants.userDefault_language)
            self.languageButton.setTitle(LanguageListViewController.language.first, for: .normal)
        } else {
            if let index = UserDefaults.standard.value(forKey: Constants.userDefault_language) as? Int {
                self.languageButton.setTitle(LanguageListViewController.language[index], for: .normal)
            }
        }
       
        if UserDefaults.standard.value(forKey: Constants.userDefault_ledger) == nil {
            UserDefaults.standard.setValue(0, forKey: Constants.userDefault_ledger)
            self.ledgerButton.setTitle(LedgerListViewController.ledgers.first, for: .normal)
        } else {
            if let index = UserDefaults.standard.value(forKey: Constants.userDefault_ledger) as? Int {
                self.ledgerButton.setTitle(LedgerListViewController.ledgers[index], for: .normal)
            }
        }
    }
    
    @IBAction func tappedOnLanguageButton(_ sender: Any) {
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "LanguageListViewController") as? LanguageListViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func tappedOnAboutButton(_ sender: Any) {
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "AboutViewController") as? AboutViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func tappedOnLedgerButton(_ sender: Any) {
        if let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "LedgerListViewController") as? LedgerListViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

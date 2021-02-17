//
//  AboutViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 27/01/21.
//

import UIKit

class AboutViewController: AriesBaseViewController {
    @IBOutlet weak var appVersion: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func localizableValues() {
        let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.appVersion.text = "Version".localized() + ": " + appVersionString
        self.title = "About".localized()
    }
    
    @IBAction func tappedOnAriesProtocolsButton(_ sender: Any) {
        if let webviewVC = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "WebViewVC") as? WebViewViewController {
            webviewVC.urlString = "https://datawallet.igrant.io/aries-supported-protocols.html"
            webviewVC.title = "Supported Protocols".localized()
            self.navigationController?.pushViewController(webviewVC, animated: true)
        }
    }
    
    @IBAction func tappedOnTermsAndConditionButton(_ sender: Any) {
        if let webviewVC = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "WebViewVC") as? WebViewViewController {
            webviewVC.urlString = "https://datawallet.igrant.io/wallet-terms.html"
            webviewVC.title = "Terms And Conditions".localized()
            self.navigationController?.pushViewController(webviewVC, animated: true)
        }
    }
    
    @IBAction func tappedOnPrivacyPolicyButton(_ sender: Any) {
        if let webviewVC = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateViewController( withIdentifier: "WebViewVC") as? WebViewViewController {
            webviewVC.urlString = "https://datawallet.igrant.io/wallet-privacy.html"
            webviewVC.title = "Privacy Policy".localized()
            self.navigationController?.pushViewController(webviewVC, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

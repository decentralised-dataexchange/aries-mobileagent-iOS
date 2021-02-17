//
//  AriesBaseViewController.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 18/01/21.
//

import UIKit
import Localize_Swift

class AriesBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(localizableValues), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        localizableValues()
        self.view.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9647058824, alpha: 1)
        // Do any additional setup after loading the view.
    }
    

    @objc func localizableValues(){}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

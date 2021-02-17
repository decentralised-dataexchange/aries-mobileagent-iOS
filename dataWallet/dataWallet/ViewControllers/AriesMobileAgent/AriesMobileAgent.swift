//
//  AriesMobileAgent.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 11/11/20.
//

import Foundation
import SVProgressHUD

public struct AriesMobileAgent {
    public static let shared = AriesMobileAgent()
    private init() { }
    static var themeColor = UIColor.AriesDefaultThemeColor()
    public func getAriesMobileAgentQRDemoViewController(themeColor: UIColor? = nil, navBarItemTintColor: UIColor? = nil) -> UINavigationController{
        let controller = UIStoryboard(name:"AriesMobileAgent", bundle:UIApplicationUtils.shared.getResourcesBundle()).instantiateInitialViewController() as? UINavigationController
        AriesMobileAgent.themeColor = themeColor ?? UIColor.AriesDefaultThemeColor()
        controller?.navigationBar.barTintColor = themeColor ?? UIColor.AriesDefaultThemeColor()
        controller?.navigationBar.tintColor = navBarItemTintColor ?? .white
        controller?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarItemTintColor ?? .white]
        SVProgressHUD.setDefaultMaskType(.black)
        return controller ?? UINavigationController();
    }
    
}

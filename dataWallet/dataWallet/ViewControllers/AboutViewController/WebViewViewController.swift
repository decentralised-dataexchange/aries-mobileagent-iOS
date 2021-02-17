//
//  WebViewViewController.swift
//  Lubax
//
//  Created by Ajeesh T S on 18/06/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class WebViewViewController: AriesBaseViewController , WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webview : WKWebView!
    var urlString  = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        webview.uiDelegate = self
        self.navigationController?.navigationBar.isHidden = false
        if let url =  URL.init(string: urlString){
            webview.load(URLRequest.init(url: url))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func webViewDidFinishLoad(_ webView: UIWebView){
//    }
    
    //Equivalent of webViewDidFinishLoad:
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.bounces = false
    }

    //Equivalent of didFailLoadWithError:
       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           let nserror = error as NSError
            SVProgressHUD.dismiss()
           if nserror.code != NSURLErrorCancelled {
               webView.loadHTMLString("Page Not Found", baseURL: URL(string: "https://developer.apple.com/"))
           }
       }

  

}

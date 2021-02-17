//
//  File.swift
//  Indy_Demo
//
//  Created by Mohamed Rebin on 17/10/20.
//

import Foundation
import UIKit

class QRTransportMode: TransportMode,QRScannerViewDelegate {
    
    var completion: ((String?) -> Void)?
    
    override func sendData(msg: String,completion: @escaping(Any?) -> Void) {
        let image = generateQRCode(from: msg)
        completion(image ?? "")
    }
    
    override func getData(completion: @escaping(String?) -> Void) {
        let newVC = UIViewController()
        let qrScannerView = QRScannerView(frame: newVC.view.bounds)
        newVC.view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self)
        qrScannerView.startRunning()
        self.completion = completion
        newVC.title = "Scan"
        let topVC = UIApplicationUtils.shared.getTopVC() as? UINavigationController
        
        topVC?.pushViewController(newVC, animated: true)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    //delegates
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        guard let completion = self.completion else {
            return
        }
        completion(code)
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        guard let completion = self.completion else {
            return
        }
        completion("")
    }
}

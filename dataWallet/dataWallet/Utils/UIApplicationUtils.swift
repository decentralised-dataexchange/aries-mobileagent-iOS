//
//  UIApplicationUtils.swift
//  Indy_Demo
//
//  Created by Mohamed Rebin on 20/10/20.
//

import Foundation
import UIKit
import SwiftMessages
import Kingfisher

class UIApplicationUtils {
    
    static let shared = UIApplicationUtils()
    private init(){}

     func getTopVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
            // topController should now be your topmost view controller
        }
        return nil
    }
    
     func getResourcesBundle() -> Bundle? {
        return nil
        
        //SDK
//        let bundle = Bundle(for: UIApplicationUtils.self)
//        guard let resourcesBundleUrl = bundle.resourceURL?.appendingPathComponent("AriesMobileAgent.bundle") else {
//            return nil
//        }
//        return Bundle(url: resourcesBundleUrl)
    }
    
     func getJsonString(for Dict: [String: Any?]) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: Dict, options: [])
        let valueString = String(data: jsonData!, encoding: .utf8) ?? ""
        return valueString
    }
    
    func convertToDictionary(text: String,boolKeys:[String]? = []) -> [String: Any?]? {
        if let data = text.data(using: .utf8) {
            do {
                if let dict = (try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) {
                    let newDict = decodeDict(dict:dict, boolKeys: boolKeys)
                    return newDict
                } else {
                    return nil
                }
            } catch {
//                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func decodeDict(dict: [String: Any?], boolKeys:[String]? = []) -> [String: Any] {
        var dictionary = [String: Any]()
        
        for key in dict.keys {
            if (boolKeys ?? []).contains(key){
                if let boolValue = dict[key] as? Bool {
                    dictionary[key] = boolValue
                }
            }else if let intValue = dict[key] as? Int {
                dictionary[key] = intValue
            } else if let stringValue = dict[key] as? String {
                if let isDict = UIApplicationUtils.shared.convertToDictionary(text: stringValue){
                    dictionary[key] = decodeDict(dict: isDict,boolKeys: boolKeys)
                }else{
                    dictionary[key] = stringValue
                }
            } else if let doubleValue = dict[key] as? Double {
                dictionary[key] = doubleValue
            } else if let nestedDictionary = dict[key] as? [String:Any] {
                dictionary[key] = decodeDict(dict: nestedDictionary,boolKeys: boolKeys)
            }else if let nestedArray = dict[key] as? [Any] {
                dictionary[key] = decodeArray(array: nestedArray,boolKeys: boolKeys)
            } else {
                dictionary[key] = dict[key] as Any?
            }
        }
        return dictionary
    }
    
    func decodeArray(array: [Any],boolKeys:[String]? = []) -> [Any] {
        var tempArray = [Any]()
        
        for key in array {
//            if let value = key as? Bool {
//                tempArray.append(value)
//            } else
            if let intValue = key as? Int {
                tempArray.append(intValue)
            } else if let stringValue = key as? String {
                if let isDict = UIApplicationUtils.shared.convertToDictionary(text: stringValue){
                    tempArray.append(decodeDict(dict: isDict,boolKeys:boolKeys))
                }else{
                    tempArray.append(stringValue)
                }
            } else if let doubleValue = key as? Double {
                tempArray.append(doubleValue)
            } else if let nestedDictionary = key as? [String:Any] {
                tempArray.append(decodeDict(dict: nestedDictionary,boolKeys:boolKeys))
            } else if let nestedArray = key as? [Any] {
                tempArray.append(decodeArray(array: nestedArray,boolKeys: boolKeys))
            } else {
            }
        }
        return tempArray
    }
    
    func setRemoteImageOn(_ imageView:UIImageView, url:String?, forceDownload: Bool = false,showPlaceholder: Bool = true,placeholderImage: UIImage? = nil ){
        let placeholder = placeholderImage ?? UIImage(named: "placeholder", in: self.getResourcesBundle(), compatibleWith: nil)
        if let imageUrl = url, let URL = URL(string: imageUrl ) {
            var options: KingfisherOptionsInfo = []
            options.append(KingfisherOptionsInfoItem.transition(.fade(1)))
            if forceDownload {
                options.append(KingfisherOptionsInfoItem.forceRefresh)
            }
              imageView.kf.setImage(with: URL,
                                    placeholder: showPlaceholder ? placeholder : nil,
                                             options: options)
        } else {
            imageView.image = showPlaceholder ? placeholder : nil
        }
    }
    
    internal static func showErrorSnackbar(withTitle: String? = "", message: String) {
        let error = MessageView.viewFromNib(layout: .messageView)
        error.configureTheme(.error)
        error.configureContent(title: withTitle!, body: message)
        error.button?.isHidden = true
        error.configureDropShadow()
//        SwiftMessages.sharedInstance.defaultConfig.dimMode = .none
//        SwiftMessages.sharedInstance.defaultConfig.duration = .seconds(seconds: 3)
        
        SwiftMessages.show(view: error)
    }
    
    internal static func showSuccessSnackbar(withTitle: String? = "", message: String) {
        let success = MessageView.viewFromNib(layout: .messageView)
        success.configureTheme(.success)
        success.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.5803921569, blue: 0.2666666667, alpha: 1)
        success.configureContent(title: withTitle!, body: message)
        success.configureDropShadow()
        success.button?.isHidden = true
//        SwiftMessages.sharedInstance.defaultConfig.dimMode = .none
//        SwiftMessages.sharedInstance.defaultConfig.duration = .seconds(seconds: 3)
        
        SwiftMessages.show(view: success)
    }
}

extension String {

    func decodeBase64() -> String? {
        do {
            var st = self
                .replacingOccurrences(of: "_", with: "/")
                .replacingOccurrences(of: "-", with: "+")
            let remainder = self.count % 4
            if remainder > 0 {
                st = self.padding(toLength: self.count + 4 - remainder,
                                  withPad: "=",
                                  startingAt: 0)
            }
            let data = try Base64.decode(st)
            return String.init(decoding: data, as: UTF8.self)
        }catch{
            print(error)
            return nil
        }
    }

    func decodeBase64_first8bitRemoved() -> String? {
        do {
            var st = self
                .replacingOccurrences(of: "_", with: "/")
                .replacingOccurrences(of: "-", with: "+")
            let remainder = self.count % 4
            if remainder > 0 {
                st = self.padding(toLength: self.count + 4 - remainder,
                                  withPad: "=",
                                  startingAt: 0)
            }
            var data = try Base64.decode(st)
            data.removeFirst(8)
            return String.init(decoding: data, as: UTF8.self)
        }catch{
            print(error)
            return nil
        }
    }

    func encodeBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
//    Here is a string extension for Swift 5 that you can convert a string to UnsafePointer<UInt8> and UnsafeMutablePointer<Int8>

        func toUnsafePointer() -> UnsafePointer<UInt8>? {
            guard let data = self.data(using: .utf8) else {
                return nil
            }

            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            let stream = OutputStream(toBuffer: buffer, capacity: data.count)
            stream.open()
            let value = data.withUnsafeBytes {
                $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            }
            guard let val = value else {
                return nil
            }
            stream.write(val, maxLength: data.count)
            stream.close()

            return UnsafePointer<UInt8>(buffer)
        }

        func toUnsafeMutablePointer() -> UnsafeMutablePointer<Int8>? {
            return strdup(self)
        }

}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}


extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return  UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func error(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.red,
            .backgroundColor : UIColor.white
            
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension UIDevice {
    var hasNotch: Bool {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
    }
}

extension UIColor {
    class func AriesDefaultThemeColor() -> UIColor{
        return UIColor(red:0, green:0.2, blue:0.55, alpha:1)
    }
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let height = self.frame.height/2 - 50
        let iconHeight: CGFloat = 40.0
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let messageLabel = UILabel.init(frame: CGRect.init(x: 0, y: height + iconHeight + 5, width: self.frame.width, height: 40))
        messageLabel.text = message
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        
        let noDataIcon = UIImageView.init(frame: CGRect.init(x: 0, y: height, width:  self.frame.width, height: iconHeight))
        noDataIcon.image = UIImage.init(named: "ic_block", in: UIApplicationUtils.shared.getResourcesBundle(), compatibleWith: nil)
        noDataIcon.contentMode = .scaleAspectFit
        view.addSubview(noDataIcon)
        view.addSubview(messageLabel)
        self.backgroundView = view
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let height = self.frame.height/2 - 50
        let iconHeight: CGFloat = 40.0
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let messageLabel = UILabel.init(frame: CGRect.init(x: 0, y: height + iconHeight + 5, width: self.frame.width, height: 40))
        messageLabel.text = message
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        
        let noDataIcon = UIImageView.init(frame: CGRect.init(x: 0, y: height, width:  self.frame.width, height: iconHeight))
        noDataIcon.image = UIImage.init(named: "ic_block", in: UIApplicationUtils.shared.getResourcesBundle(), compatibleWith: nil)
        noDataIcon.contentMode = .scaleAspectFit
        
        view.addSubview(noDataIcon)
        view.addSubview(messageLabel)
        self.backgroundView = view
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension UIView {
    func setShadowWithColor(color: UIColor?, opacity: Float?, offset: CGSize?, radius: CGFloat?, viewCornerRadius: CGFloat?) {
            //layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: viewCornerRadius ?? 0.0).CGPath
        layer.shadowColor = color?.cgColor ?? UIColor.black.cgColor
        layer.shadowOpacity = opacity ?? 1.0
        layer.shadowOffset = offset ?? CGSize.zero
        layer.shadowRadius = radius ?? 0
        layer.cornerRadius = viewCornerRadius ?? 0
        }
}

extension UIColor {
    func inverse () -> UIColor {
        var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return .black // Return a default colour
    }
}

extension UISearchBar {

    private func getViewElement<T>(type: T.Type) -> T? {

        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }

    func setTextFieldColor(color: UIColor) {
        self.searchTextField.backgroundColor = color
    }
    
    func removeBg(){
        if let view = self.subviews.first?.subviews.last?.subviews.first?.subviews.first?.subviews.first {
            view.isHidden = true
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

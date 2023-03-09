//
//  MyUtils.swift
//  NearbyStores
//
//  Created by Amine on 5/21/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SystemConfiguration
import ImageSlideshow
import AssistantKit


class AppDesignUtils {

    static func defaultModeColor(dark: UIColor, light: UIColor) -> UIColor {

        if (AppConfig.Design.uiColor == AppStyle.uiColor.dark) {
            return dark
        } else {
            return light
        }

    }

    static func darkColor() -> UIColor {

        if (AppConfig.Design.uiColor == AppStyle.uiColor.dark) {
            return Colors.darkIconColor
        } else {
            return Colors.Appearance.primaryColor.withAlphaComponent(0.6)
        }

    }

    static func isDarkMode() -> Bool {

        if (AppConfig.Design.uiColor == AppStyle.uiColor.dark) {
            return true
        }

        return false
    }
}


extension UIView {

    static func loadFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}

extension UILabel {


    func calculateMaxLines2() -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = self.text! as NSString

        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }

    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }
}

extension String {

    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }

    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }

    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }

    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter {
            CharacterSet.decimalDigits.contains($0)
        }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }

    func makeACall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

class Connectivity {

    class func isConnected() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }


        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}

class Utils {


    static func formatPhone(string: String) -> String {

        var phone = string

        if let regex = try? NSRegularExpression(pattern: "-", options: .caseInsensitive) {
            phone = regex.stringByReplacingMatches(in: phone, options: [], range: NSRange(location: 0, length: phone.count), withTemplate: "")

        }

        if let regex = try? NSRegularExpression(pattern: " ", options: .caseInsensitive) {
            phone = regex.stringByReplacingMatches(in: phone, options: [], range: NSRange(location: 0, length: phone.count), withTemplate: "")
        }

        return phone

    }

    static func getIdFromPath(path: String, prefix: String) -> Int? {

        var list = path.components(separatedBy: "/")

        //clear list
        for (key, value) in list.enumerated() {
            if (value == "") {
                list.remove(at: key)
            }
        }

        var lenght = Int(list.count - 1)

        if (lenght < 0) {
            lenght = 0
        }

        for key in 0...lenght {
            if list[key] == prefix {
                let next_index = key + 1
                if (list[next_index] == "dp" || list[next_index] == "id") {
                    let last_index = key + 2
                    if let id = Int(list[last_index]) {
                        if id > 0 {
                            return id
                        }
                    }
                }
            }
        }

        return nil

    }


    static func getMethod(nspath: String, nsmodule: String) -> String? {

        var list = nspath.components(separatedBy: "/")

        var lenght = list.count - 1

        if (lenght < 0) {
            lenght = 0
        }

        for key in 0...lenght {
            if list[key] == nsmodule {
                let next_index = key + 1
                return list[next_index]
            }
        }

        return nil

    }

    static func isRTL() -> Bool {

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return true
        }

        return false
    }


    static func convertToDictionary(text: String) -> JSON? {

        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {

            do {
                return try JSON(data: dataFromString)
            } catch {
                print(error.localizedDescription)
            }
        }

        return nil
    }


    static func setFontRegular(labels: UILabel...) {

        for view in labels {
            let font = UIFont(name: AppConfig.Design.Fonts.regular, size: view.font.pointSize)
            view.font = font
        }

    }

    static func setFontBold(labels: UILabel...) {

        for view in labels {
            let font = UIFont(name: AppConfig.Design.Fonts.bold, size: view.font.pointSize)
            view.font = font
        }

    }


    static func printDebug(_ message: String) {

        if AppConfig.DEBUG {
            print(message)
        }

    }

    static func printDebug(_ tag: String, _ message: String) {

        if AppConfig.DEBUG {
            print("Debug ***\(tag) ****===> ", message)
        }

    }

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
        )
    }

}


extension UILabel {

    func useFontRegular() {

        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: self.font.pointSize)
        self.font = font

    }


    func useFontBold() {

        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: self.font.pointSize)
        self.font = font

    }
}


extension UIButton {

    func useFontRegular() {

        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: (self.titleLabel?.font.pointSize)!)
        self.titleLabel?.font = font

    }


    func useFontBold() {

        let font = UIFont(name: AppConfig.Design.Fonts.bold, size: (self.titleLabel?.font.pointSize)!)
        self.titleLabel?.font = font


    }


    /*
    private func actionHandleBlock(action:(() -> Void)? = nil) {
        struct __ {
            static var action :(() -> Void)?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?()
        }
    }
    
    @objc private func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func actionHandle(controlEvents control :UIControlEvents, ForAction action:@escaping () -> Void) {
        self.actionHandleBlock(action: action)
        self.addTarget(self, action: #selector(UIButton.triggerActionHandleBlock), for: control)
    }*/
}


extension UIView {


}

extension UITextView {
    func initDefaultFont() {

        guard self.font?.fontName != AppConfig.Design.Fonts.regular else {
            return
        }

        if let font = self.font {
            let size = font.pointSize
            self.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size)
        }
    }

    func initDefaultFont(size: CGFloat) {
        if self.font != nil {
            self.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size)
        }
    }

    func initBolodFont() {

        guard self.font?.fontName != AppConfig.Design.Fonts.bold else {
            return
        }

        if let font = self.font {
            let size = font.pointSize
            self.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size)
        }
    }

    func initBolodFont(size: CGFloat) {
        if self.font != nil {
            self.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size)
        }
    }
}


extension UITextField {


    func initDefaultFont() {

        guard self.font?.fontName != AppConfig.Design.Fonts.regular else {
            return
        }

        let size = self.font?.pointSize
        self.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size!.adaptScreen())

    }

    func initDefaultFont(size: CGFloat) {
        self.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size.adaptScreen())
    }

    func initBolodFont() {

        guard self.font?.fontName != AppConfig.Design.Fonts.bold else {
            return
        }

        let size = self.font?.pointSize
        self.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size!.adaptScreen())
    }

    func initBolodFont(size: CGFloat) {
        self.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size.adaptScreen())
    }

    func initItalicFont() {

        guard self.font?.fontName != AppConfig.Design.Fonts.italic else {
            return
        }

        let size = self.font?.pointSize
        self.font = UIFont(name: AppConfig.Design.Fonts.italic, size: size!.adaptScreen())
    }

    func initItalicFont(size: CGFloat) {
        self.font = UIFont(name: AppConfig.Design.Fonts.italic, size: size.adaptScreen())
    }

}

extension UIButton {

    func initDefaultFont() {

        guard self.titleLabel?.font.fontName != AppConfig.Design.Fonts.regular else {
            return
        }

        let size = self.titleLabel?.font.pointSize
        self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size!.adaptScreen())
    }

    func initDefaultFont(size: CGFloat) {
        self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size.adaptScreen())
    }

    func initBolodFont() {

        guard self.titleLabel?.font.fontName != AppConfig.Design.Fonts.bold else {
            return
        }

        let size = self.titleLabel?.font.pointSize
        self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size!.adaptScreen())
    }

    func initBolodFont(size: CGFloat) {
        self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size.adaptScreen())
    }

    func initItalicFont() {

        guard self.titleLabel?.font.fontName != AppConfig.Design.Fonts.italic else {
            return
        }

        let size = self.titleLabel?.font.pointSize
        self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.italic, size: size!.adaptScreen())
    }

    func initItalicFont(size: CGFloat) {
        self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.italic, size: size.adaptScreen())
    }

}


extension UILabel {


    func initDefaultFont() {

        guard self.font.fontName != AppConfig.Design.Fonts.regular else {
            return
        }

        let size = self.font.pointSize
        self.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size.adaptScreen())
    }

    func initDefaultFont(size: CGFloat) {


        self.font = UIFont(name: AppConfig.Design.Fonts.regular, size: size.adaptScreen())
    }

    func initBolodFont() {

        guard self.font.fontName != AppConfig.Design.Fonts.bold else {
            return
        }

        let size = self.font.pointSize
        self.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size.adaptScreen())
    }

    func initBolodFont(size: CGFloat) {
        self.font = UIFont(name: AppConfig.Design.Fonts.bold, size: size.adaptScreen())
    }

    func initItalicFont() {

        guard self.font.fontName != AppConfig.Design.Fonts.italic else {
            return
        }

        let size = self.font.pointSize
        self.font = UIFont(name: AppConfig.Design.Fonts.italic, size: size.adaptScreen())
    }

    func initItalicFont(size: CGFloat) {
        self.font = UIFont(name: AppConfig.Design.Fonts.italic, size: size.adaptScreen())
    }

    func setLeftIcon(image: UIImage) {

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffsetY: CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string
        completeText.append(attachmentString)
        //Add your text to mutable string
        let textAfterIcon = NSMutableAttributedString(string: self.text!)
        completeText.append(textAfterIcon)

        if Utils.isRTL() {
            self.textAlignment = .right;
        } else {
            self.textAlignment = .left;
        }

        self.attributedText = completeText;
    }


    func setRightIcon(image: UIImage) {

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffsetY: CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string

        //Add your text to mutable string
        let textAfterIcon = NSMutableAttributedString(string: self.text!)
        completeText.append(textAfterIcon)
        completeText.append(attachmentString)

        if Utils.isRTL() {
            self.textAlignment = .right;
        } else {
            self.textAlignment = .left;
        }

        self.attributedText = completeText;
    }


}


extension UITableView {

    func scrollToLast() {

        let lastSectionIndex = self.numberOfSections - 1 // last section
        if (lastSectionIndex >= 0) {
            let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1 // last row
            self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: true)
        }

        //let scrollPoint = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
        //self.setContentOffset(scrollPoint, animated: true)
    }

    func scrollToLast(offset: Bool) {


        //let lastSectionIndex = self.numberOfSections - 1 // last section
        //let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1 // last row
        //self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: true)

        let scrollPoint = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
        self.setContentOffset(scrollPoint, animated: false)

    }


}

extension UICollectionView {


//    func getLastIndexPath() -> IndexPath{
//
//        guard numberOfSections > 0 else {
//            return
//        }
//
//        let lastItemIndex = numberOfItems(inSection: 0) > 0 ? numberOfItems(inSection: lastSection) - 1 : 0
//
//
//        let lastItemIndexPath = IndexPath(item: lastItemIndex,
//                                          section: 0)
//
//        return lastItemIndexPath
//    }
//
//
//    func getLastIndex() -> Int{
//
//        guard numberOfSections > 0 else {
//            return
//        }
//
//        let lastItemIndex = numberOfItems(inSection: 0) > 0 ? numberOfItems(inSection: lastSection) - 1 : 0
//
//
//        return lastItemIndex
//    }

    func scrollToLast() {
        guard numberOfSections > 0 else {
            return
        }

        let lastItemIndex = numberOfItems(inSection: 0) > 0 ? numberOfItems(inSection: 0) - 1 : 0

        guard numberOfItems(inSection: 0) > 0 else {
            return
        }

        let lastItemIndexPath = IndexPath(item: lastItemIndex,
                section: 0)

        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
    }

}

class Localization {
    static var list_to_translate: [String: String] = [:]
}


extension UIScrollView {

    func resizeScrollViewContentSize() {

        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }

        self.contentSize = contentRect.size

    }

}


extension String {

    var localized: String {

        let value = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")

        if AppConfig.DEBUG && self == value{
            Localization.list_to_translate[self] = self
        }
        
        return value
    }

    func localized(withComment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }

    func format(arguments: CVarArg...) -> String {
        let text: String = self
        return String(format: text, arguments: arguments)
    }

}


extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }

    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }

    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }

    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }

    func addMiddleBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width / 2, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIView {

    func addShadowView(width: CGFloat = 1, height: CGFloat = 0.9, opcaity: Float = 0.1, maskToBounds: Bool = false, radius: CGFloat = 5) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opcaity
        self.layer.masksToBounds = maskToBounds
    }

}

extension UIView {
    func roundCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius.adaptScreen()
        self.layer.masksToBounds = true
    }

    func roundedCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius/UIScreen.main.nativeScale
        self.layer.masksToBounds = true
    }


    func border(with: CGFloat, color: UIColor) {
        self.layer.borderWidth = with
        self.layer.borderColor = color.cgColor
    }
}

extension UIView {

    func addTopRoundedCornerToView(desiredCurve: CGFloat?) {

        let offset: CGFloat = self.frame.width / desiredCurve!
        let bounds: CGRect = self.bounds

        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height / 2, width: bounds.size.width, height: bounds.size.height / 2)

        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)

        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath

        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer
    }
}


extension ImageSlideshow {
    @discardableResult
    open func presentFullScreenControllerForIos13(from controller: UIViewController) -> FullScreenSlideshowViewController {
        let fullscreen = FullScreenSlideshowViewController()
        fullscreen.pageSelected = { [weak self] (page: Int) in
            self?.setCurrentPage(page, animated: false)
        }

        fullscreen.initialPage = currentPage
        fullscreen.inputs = images
        // slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: self, slideshowController: fullscreen)
        fullscreen.transitioningDelegate = slideshowTransitioningDelegate
        fullscreen.modalPresentationStyle = .fullScreen
        controller.present(fullscreen, animated: true, completion: nil)

        return fullscreen
    }
}


extension Float {
    func adaptScreen() -> Float {
        var ratio = 1.0
        switch Device.screen {
        case .inches_3_5:  ratio = 1.2
        case .inches_4_0:  ratio = 1.18
        case .inches_4_7:  ratio = 1.12
        case .inches_5_5:  ratio = 1.10
        case .inches_7_9:  ratio = 1.09
        case .inches_9_7:  ratio = 1.05
        case .inches_12_9: ratio = 0.9
        default:        ratio = 1.0
        }
        return self / Float(ratio)
    }
}

extension CGFloat {
    func adaptScreen() -> CGFloat {
        var ratio = 1.0
        switch Device.screen {
        case .inches_3_5:  ratio = 1.2
        case .inches_4_0:  ratio = 1.18
        case .inches_4_7:  ratio = 1.12
        case .inches_5_5:  ratio = 1.10
        case .inches_7_9:  ratio = 1.09
        case .inches_9_7:  ratio = 1.05
        case .inches_12_9: ratio = 0.9
        default:        ratio = 1.0
        }
        return self / CGFloat(ratio)
    }
}





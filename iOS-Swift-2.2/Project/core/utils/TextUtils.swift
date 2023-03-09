//
//  TextUtils.swift
//  NearbyStores
//
//  Created by Amine on 5/31/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika
import libPhoneNumber_iOS


extension String{
    
    
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return self
        }
        return String(self[index...])
    }
    
    func phoneFormat() -> String {
        var string = self.replacingOccurrences(of: "\\s*(\\p{Po}\\s?)\\s*",with: "$1",options: [.regularExpression])
        string = string.replacingOccurrences(of: " ", with: "")
        string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return string.removingLeadingSpaces()
    }
    
}

extension String{


    func encode(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }

    func decode(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
    
    func toHtml() -> AttributedText {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        
        
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 14)
        let all = Style.font(font!)
        let b = Style("b").font(.boldSystemFont(ofSize: 14))
        let u = Style("u").underlineStyle(NSUnderlineStyle.single)
        let i = Style("i").font(.italicSystemFont(ofSize: 14))
        
        let bred = Style("bred").font(.boldSystemFont(ofSize: 14)).foregroundColor(.red)
        let bgreen = Style("bgreen").font(.boldSystemFont(ofSize: 14)).foregroundColor(Colors.green)


        let h1 = Style("h3").font(.boldSystemFont(ofSize: 18))
        let h2 = Style("h3").font(.boldSystemFont(ofSize: 16))
        let h3 = Style("h3").font(.boldSystemFont(ofSize: 14))
        let h4 = Style("h3").font(.boldSystemFont(ofSize: 12))
        let h5 = Style("h3").font(.boldSystemFont(ofSize: 10))
        
        


        let link = Style("a")
            .foregroundColor(Colors.Appearance.primaryColor, .normal)
            .foregroundColor(.brown, .highlighted)
        
    
        return self.style(tags: b,u,i,h1,h2,h3,h4,h5,link,bred,bgreen)
            .styleLinks(link)
            .styleHashtags(link)
            .styleMentions(link)
            .styleAll(all)
    }
    
    
    
    
}

extension String {
    
    
    
    var htmlToAttributedString: NSAttributedString? {
        
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
        
        
    }
    var htmlToString: String {
        
        
        return htmlToAttributedString?.string ?? ""
    }
}



extension String {
    
    
    
    
    
    
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}


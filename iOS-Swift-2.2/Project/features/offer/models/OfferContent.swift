//
//  OfferContent.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class OfferContent: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var desc: String  = ""
    @objc dynamic var price: Float = 0
    @objc dynamic var percent: Float = 0
    @objc dynamic var currency: Currency? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class Currency: Object {
    @objc dynamic var code: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var format: Int = 1
}


extension Currency{
    
    //float price,String cData
    func parseCurrencyFormat(price: Float) -> String? {
        
        let decimal_price = String(format: "%.2f", price)
        
        switch self.format {
        case 1:
            return "\(self.symbol)\(decimal_price)"
        case 2:
            return "\(decimal_price)\(self.symbol)"
        case 3:
            return "\(self.symbol) \(decimal_price)"
        case 4:
            return "\(decimal_price) \(self.symbol)"
        case 5:
            return String(decimal_price)
        case 6:
            return "\(self.symbol)\(decimal_price) \(self.code)"
        case 7:
            return "\(self.code)\(decimal_price)"
        case 8:
            return "\(decimal_price)\(self.code)"
        default:
            return String(decimal_price);
        }
        
    }
    
    
    
}

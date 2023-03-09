//
//  UserParser.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

//
//  JobParser.swift
//  AppTest
//
//  Created by Amine on 5/15/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class OfferParser: Parser {
    
    
    func parse() -> [Offer] {
        
        var list = [Offer]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                   
                    let myObject = Offer()
                    
                    myObject.id = object["id_offer"].intValue
                    myObject.name = object["name"].stringValue
                    
                    myObject.date_start = object["date_start"].stringValue
                    myObject.date_end = object["date_end"].stringValue
                    
                    myObject.status = object["status"].intValue
                    
                    myObject.store_id = object["store_id"].intValue
                    myObject.store_name = object["store_name"].stringValue
                    
                    myObject.link = object["link"].stringValue
                    
                    
                    myObject.lat = object["latitude"].doubleValue
                    myObject.lng = object["longitude"].doubleValue
                    
                   
                     myObject.distance = object["distance"].doubleValue
                    
                     myObject.user_id = object["user_id"].intValue
                    
                     myObject.featured = object["featured"].intValue
                    myObject.short_description = object["short_description"].stringValue
                    
                    
                    if object["saved"].intValue == 1{
                        myObject.saved = true
                    }else{
                        myObject.saved = false
                    }
                    
                
                    let icontent = object["images"]
                    let imageParser = ImagesParser(json: icontent)
                    let images = imageParser.parse()
                    let listImages: List<Images> = List<Images>()
                    
                    for el in images {
                        listImages.append(el)
                    }
                    
                    myObject.listImages = listImages
                    
                    
                    myObject._description = object["description"].stringValue
                    myObject.offer_value = object["offer_value"].doubleValue
                    myObject.value_type = object["value_type"].stringValue
              
                     Utils.printDebug("\(object["currency"])")
                    
                    if  object["value_type"] == "price"{
                        Utils.printDebug("\(object["currency"])")
                        
                        let currencyJSON = object["currency"]
                        let currencyParser = CurrencyParser(json: currencyJSON)
                        
                        if let currency = currencyParser.parse() {
                            myObject.currency = currency
                        }
                        
                    }
                
                    
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
    
}

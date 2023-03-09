//
//  CategoryParser.swift
//  NearbyStores
//
//  Created by Amine on 7/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class LocationParser: Parser {
    
    func parse() -> [LocationModel] {
        
        var list = [LocationModel]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                    let myObject = LocationModel()
                    
                    myObject.id_location = object["id_location"].stringValue
                    myObject.name = object["name"].stringValue
                    myObject.country_code = object["country_code"].stringValue
                    myObject.country_name = object["country_name"].stringValue
                    myObject.country_name = object["city"].stringValue
                    myObject.latitude = object["latitude"].doubleValue
                    myObject.longitude = object["longitude"].doubleValue
                   
                  
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
}

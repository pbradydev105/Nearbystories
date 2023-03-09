//
//  CategoryParser.swift
//  NearbyStores
//
//  Created by Amine on 7/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class ModulesParser: Parser {
    
    func parse() -> [ModuleConfig] {
        
        var list = [ModuleConfig]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                    let myObject = ModuleConfig()
                    
                    myObject.module_name = object["module_name"].stringValue
                
                    let enabled =  object["enabled"].intValue
                    
                    if(enabled == 1){
                        myObject._enabled = true
                    }else{
                         myObject._enabled = false
                    }
                  
                    
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
}

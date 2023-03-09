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

class BookmarksParser: Parser {
    
    
    func parse() -> [Bookmark] {
        
        var list = [Bookmark]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
               
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    let myObject = Bookmark()
                    
                    myObject.id = object["id"].intValue
                    myObject.label = object["label"].stringValue
                    myObject.label_description = object["label_description"].stringValue
                    myObject.module = object["module"].stringValue
                    myObject.module_id = object["module_id"].intValue
                    myObject.createdAt = object["created_at"].stringValue
                    
                    let icontent = object["image"]
                    let imageParser = ImagesParser(json: icontent)
                    let images = imageParser.parse()
                    let listImages: List<Images> = List<Images>()
                    
                    for el in images {
                        listImages.append(el)
                    }
                    
                    if images.count > 0{
                        myObject.images = images[0]
                    }
                    
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
    
}

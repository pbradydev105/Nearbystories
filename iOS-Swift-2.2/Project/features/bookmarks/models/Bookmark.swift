//
//  Category.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Bookmark: Object{
    
    @objc dynamic var id: Int = 0
    @objc dynamic var label: String = ""
    @objc dynamic var label_description: String = ""
    @objc dynamic var module: String = ""
    @objc dynamic var module_id: Int = 0
    @objc dynamic var images: Images? = nil
    @objc dynamic var createdAt: String = ""
    

    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}


extension Array where Element:Bookmark {
    
    func getindex(id: Int) -> Int? {
        
        var users: [Bookmark] = self
        
        
        //resfresh item to the top
        let size = users.count - 1
        
        if size >= 0 {
            
            for index in 0...users.count {
                
                if users[index].id == id{
                    return index
                }
                
            }
            
        }
        
        
        return nil
        
    }
}

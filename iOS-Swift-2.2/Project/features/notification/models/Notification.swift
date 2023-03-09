//
//  Category.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Notification: Object{
    
    @objc dynamic var id: Int = 0
    @objc dynamic var label: String = ""
    @objc dynamic var label_description: String = ""
    @objc dynamic var module: String = ""
    @objc dynamic var module_id: Int = 0
    @objc dynamic var auth_type: String = ""
    @objc dynamic var auth_id: Int = 0
    @objc dynamic var detail: String = ""
    @objc dynamic var images: Images? = nil
    @objc dynamic var createdAt: String = ""
    
    @objc dynamic var status: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}

extension Notification{
    public static var unread_notifications = 0
}

extension Array where Element:Notification {
    
    func getindex(id: Int) -> Int? {
        
        let users: [Notification] = self
        
        
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

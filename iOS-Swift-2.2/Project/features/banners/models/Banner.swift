//
//  Category.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Banner: Object{
    
    
    @objc dynamic var id: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var images: Images? = nil
    
    @objc dynamic var title: String = ""
    @objc dynamic var detail: String = ""
    
    @objc dynamic var module: String = ""
    @objc dynamic var module_id: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    

}

extension Banner{
    
    func save() {
        
        if self.id > 0 {
            let banner = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(banner,update: .all)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Banner? {
        
        let realm = try! Realm()
        
        if let banner = realm.objects(Banner.self).filter("id == \(id)").first {
            return banner
        }
        
        return nil
    }
    
    static func findAll() -> [Banner] {
        
        let realm = try! Realm()
        
        var banners: [Banner] = []
        
        let result = realm.objects(Banner.self)
        
        for value in result{
            banners.append(value)
        }
        
        return banners
    }
    
    static func removeAll() {
        
        let realm = try! Realm()
        
        let result = realm.objects(Banner.self)
        
        realm.beginWrite()
        for value in result{
            realm.delete(value)
        }
        try! realm.commitWrite()
    }
}

extension Array where Element:Banner {
    
    func saveAll(){
        
        let banners: [Banner] = self
        
        if banners.count > 0 {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.add(banners,update: .all)
            try! realm.commitWrite()
            
        }
        
    }
        
}

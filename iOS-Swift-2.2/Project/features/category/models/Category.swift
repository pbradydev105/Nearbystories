//
//  Category.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Category: Object{
    
    
    @objc dynamic var numCat: Int = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var nameCat: String = ""
    @objc dynamic var parentCategory: Int = 0
    @objc dynamic var icon: Images? = nil
    @objc dynamic var menu: Bool = false
    @objc dynamic var nbr_stores: Int = 0
    @objc dynamic var images: Images? = nil
    @objc dynamic var color: String? = nil
    
    override static func primaryKey() -> String? {
        return "numCat"
    }
    

}

extension Category{
    
    func save() {
        
        if self.numCat > 0 {
            let category = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(category,update: .all)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Category? {
        
        let realm = try! Realm()
        
        if let category = realm.objects(Category.self).filter("numCat == \(id)").first {
            return category
        }
        
        return nil
    }
    
    static func getAll() -> [Category] {
        
        let realm = try! Realm()
        
        let realmResults = realm.objects(Category.self)
        
        return Array(realmResults)
    }
    
    
    static  func removeAllFromRealm(){
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
        
    }
}

extension Array where Element:Category {
    
    func saveAll(){
        
        let categories: [Category] = self
        
        if categories.count > 0 {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.add(categories,update: .all)
            try! realm.commitWrite()
            
        }
        
    }
    
    
   
        
}

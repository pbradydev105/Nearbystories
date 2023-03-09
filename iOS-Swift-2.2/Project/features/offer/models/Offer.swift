//
//  Offer.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Offer: Object {
    

    @objc dynamic var id: Int = 0
    @objc dynamic var store_id: Int = 0
    @objc dynamic var user_id: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var date_start: String = ""
    @objc dynamic var date_end: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var store_name: String = ""
    var listImages: List<Images> = List<Images>()
    @objc dynamic var distance: Double = 0
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
    @objc dynamic var featured: Int = 0
    @objc dynamic var link: String = ""
    
    @objc dynamic var value_type: String = ""
    @objc dynamic var offer_value: Double = 0
    @objc dynamic var currency: Currency? = nil
    @objc dynamic var _description: String = ""
    @objc dynamic var short_description: String = ""
     @objc dynamic var saved: Bool=false

    override static func primaryKey() -> String? {
        return "id"
    }
}


extension Offer{
    
    func save() {
        if self.id > 0 {
            
            let offer = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(offer,update: .all)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Offer? {
        
        let realm = try! Realm()
        
        if let offer = realm.objects(Offer.self).filter("id == \(id)").first {
            return offer
        }
        
        return nil
    }
}



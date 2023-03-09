//
//  CityModel.swift
//  NearbyStores
//
//  Created by Amine on 3/20/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class LocationModel: Object{
    
    @objc dynamic var id_location: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var country_code: String = ""
    @objc dynamic var country_name: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    
    override static func primaryKey() -> String? {
        return "id_location"
    }
}



extension LocationModel{
    
    static func findById(id: String) -> LocationModel? {
        
        let realm = try! Realm()
        
        if let city = realm.objects(LocationModel.self).filter("id_location contains '\(id)'").first {
            return city
        }
        
        return nil
    }
    
    func save() {
        
        let city = self
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(city,update: .all)
        try! realm.commitWrite()
        
    }
    
  
}

extension Array where Element:LocationModel {
    
    
    func getFromCache() -> [LocationModel]{
        
        let realm = try! Realm()
        let result = realm.objects(LocationModel.self)
        
        var _cities:[LocationModel] = []
        
        for city in result{
            _cities.append(city)
        }
        
        return _cities
    }
    
    func saveAll(){
        
        let cities: [LocationModel] = self
        
        if cities.count > 0 {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.add(cities,update: .all)
            try! realm.commitWrite()
            
        }
        
    }
    
    func clear(){
        
        let realm = try! Realm()
        let cities = realm.objects(LocationModel.self)
        
        if cities.count > 0 {
            realm.beginWrite()
            realm.delete(cities)
            try! realm.commitWrite()
        }
        
    }
    
    func remove(){
        
        let cities: [LocationModel] = self
        
        if cities.count > 0 {
            let realm = try! Realm()
            realm.beginWrite()
            realm.delete(cities)
            try! realm.commitWrite()
        }
        
    }
    
}


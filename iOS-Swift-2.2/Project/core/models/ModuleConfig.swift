//
//  ModuleConfig.swift
//  NearbyStoresPro
//
//  Created by Amine  on 3/8/20.
//  Copyright © 2020 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class ModuleConfig: Object{
    
    @objc dynamic var module_name: String = ""
    @objc dynamic var _enabled: Bool = false
    
    override static func primaryKey() -> String? {
        return "module_name"
    }
    

}


extension ModuleConfig{
    
    static func isEnabled(module: String) -> Bool{
        if let _module = ModuleConfig.findById(id: module){
            return _module._enabled
        }
        return false
    }
    
    func save() {
        if self.module_name != "" {
            let module = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(module, update: .all)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: String) -> ModuleConfig? {
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "module_name = %@", (id))
        if let module = realm.objects(ModuleConfig.self).filter(predicate).first {
            return module
        }
        
        return nil
    }
}



extension Array where Element:ModuleConfig {

    func saveAll(){
        let modules: [ModuleConfig] = self
            if modules.count > 0 {
                let realm = try! Realm()
                realm.beginWrite()
                realm.add(modules,update: .all)
                try! realm.commitWrite()
            }
    }
    

}


//
//  Store.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Store: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var distance: Double = 0
    @objc dynamic var desc: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var detail: String = ""
    @objc dynamic var user: User? = nil
    @objc dynamic var user_id: Int = 0
    @objc dynamic var imageJson: String = ""
    @objc dynamic var voted: Bool = false
    @objc dynamic var votes: Double = 0
    @objc dynamic var nbr_votes: String = ""
    var listImages: List<Images> = List<Images>()
    @objc dynamic var phone: String = ""
    @objc dynamic var saved: Bool=false
    @objc dynamic var nbrOffers: Int = 0
    @objc dynamic var lastOffer: String = ""
    
    @objc dynamic var category_id: Int = 0
    @objc dynamic var category_name: String = ""
    @objc dynamic var category_color: String = ""
    
    @objc dynamic var featured: Int = 0
    @objc dynamic var link: String = ""
    @objc dynamic var gallery: Int = 0
    @objc dynamic var canChat: Int = 0
    

    @objc dynamic var opening: Int = 0
    var opening_time_table_list: List<OpeningTime> = List<OpeningTime>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Store{
    
    func save() {
        if self.id > 0 {
            let store = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(store, update: .all)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Store? {
        
        let realm = try! Realm()
        
        if let store = realm.objects(Store.self).filter("id == \(id)").first {
            return store
        }
        
        return nil
    }
}


struct Distance {
    
   
    enum Types  {
        static let Kilometers = "KM"
        static let Miles = "Miles"
        static let Meters = "M"
        static let Feets = "feet"
    }
    
    init(distance: Double) {
        self.distanceMeter = distance
    }
    var distanceKM: Double {
        get {
            if let m = distanceMeter {

                return Double(m/1000)
            }
            return 0
        }
    }
    var distanceMILE: Double {
        get {
            if let m = distanceMeter {
                return Double(m/1609)
            }
            return 0
        }
    }
    var distanceMeter: Double? = nil
    
   /* func getCurrent(type: String) -> String {
        
        if type == Distance.Types.Kilometers {
            
            if Int(distanceMeter!) > 1000 &&  Int(distanceMeter!) <= (AppConfig.distanceMaxValue*1000) {
               
                let formatter = NumberFormatter()
                formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 1
                
                if let d = formatter.string(from: NSNumber(value: distanceKM)){
                    return "\(d) \(type.localized)"
                }else{
                    return "\(Int(distanceKM)) \(type.localized)"
                }
                
            
            }else if Int(distanceMeter!) > (AppConfig.distanceMaxValue*1000) {
                return "+100 \(type.localized)"
            }else{
                return "\(Int(distanceMeter!)) \(Distance.Types.Meters.localized)"
            }
            
        }else if type == Distance.Types.Meters {
            
            return "\(String(describing: distanceMeter)) \(type.localized)"
            
        }else if type == Distance.Types.Miles {
            
            if Int(distanceMeter!) > 1609 &&  Int(distanceMeter!) <= (AppConfig.distanceMaxValue*1609) {
                
                let formatter = NumberFormatter()
                formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                
                if let d = formatter.string(from: NSNumber(value: distanceMILE)){
                    return "\(d) \(type.localized)"
                }else{
                    return "\(Int(distanceMILE)) \(type.localized)"
                }
                
            
            }else if Int(distanceMeter!) > (AppConfig.distanceMaxValue*1609) {
                return "+100 \(type.localized)"
            }else{

                //let feet = Int(3.28084*distanceMeter)
                return "Less than Mile".localized
                //return "\(Int(distanceMeter!)) \(Distance.Types.Meters.localized)"
            }

            //return "\(distanceMILE) \(type.localized)"
            
        }
        
        return "\(String(describing: distanceMeter)) \(Distance.Types.Meters)"
    }*/
    
    func getCurrent(type: String) -> String {
        
        if type == Distance.Types.Kilometers {
            
            if Int(distanceMeter!) > 1000 &&  Int(distanceMeter!) <= (AppConfig.distanceMaxValue*1000) {
                return "\(distanceKM) \(type.localized)"
            }else if Int(distanceMeter!) > (AppConfig.distanceMaxValue*1000) {
                return "+\(AppConfig.distanceMaxValue) \(type.localized)"
            }else{
                return "\(Int(distanceMeter!)) \(Distance.Types.Meters.localized)"
            }
            
        }else if type == Distance.Types.Meters {
            
            return "\(String(describing: distanceMeter)) \(type.localized)"
            
        }else if type == Distance.Types.Miles {
            
            if Int(distanceMeter!) > 1609 &&  Int(distanceMeter!) <= (AppConfig.distanceMaxValue*1609) {
                
                let formatter = NumberFormatter()
                formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                
                if let d = formatter.string(from: NSNumber(value: distanceMILE)){
                      return "\(d) \(type.localized)"
                }else{
                     return "\(Int(distanceMILE)) \(type.localized)"
                }
                
              
            }else if Int(distanceMeter!) > (AppConfig.distanceMaxValue*1609) {
                return "+\(AppConfig.distanceMaxValue) \(type.localized)"
            }else{
                let feet = Int(3.28084*distanceMeter!)
                return "\(feet) "+"feet".localized
                //return "\(Int(distanceMeter!)) \(Distance.Types.Meters.localized)"
            }
            
            //return "\(distanceMILE) \(type.localized)"
            
        }
        
        return "\(String(describing: distanceMeter)) \(Distance.Types.Meters)"
    }
    
    
    
    func getObject(type: String) -> DistanceObjetc{
        
        var dobj = DistanceObjetc()
                                             
        
        if type == Distance.Types.Kilometers {
            
            if Int(distanceMeter!) > 1000 &&  Int(distanceMeter!) <= (AppConfig.distanceMaxValue*1000) {
                
               
                dobj.distance = String(distanceKM)
                dobj.unit =  Types.Kilometers
                
                return dobj
               
            }else if Int(distanceMeter!) > (AppConfig.distanceMaxValue*1000) {
            
                dobj.distance = "+\(AppConfig.distanceMaxValue)"
                dobj.unit =  type.localized
                
                return dobj
                
            }else{
                
              
                dobj.distance = "\(Int(distanceMeter!))"
                dobj.unit =  "\(Distance.Types.Meters.localized)"
                
                return dobj
            
            }
            
        }else if type == Distance.Types.Meters {

            dobj.nearby = true
            
            dobj.distance = "\(String(describing: distanceMeter)) "
            dobj.unit =  "\(type.localized)"
            
            return dobj
            
        }else if type == Distance.Types.Miles {
            
            if Int(distanceMeter!) > 1609 &&  Int(distanceMeter!) <= (AppConfig.distanceMaxValue*1609) {
                
                let formatter = NumberFormatter()
                formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
              
                
                if let d = formatter.string(from: NSNumber(value: distanceMILE)){
                     
                    dobj.distance = "\(d)"
                    dobj.unit =  "\(type.localized)"
                    
                }else{
                    
                    dobj.distance = "\(Int(distanceMILE)) "
                    dobj.unit =  "\(type.localized)"
                    
                }
                
                
                return dobj
                
              
            }else if Int(distanceMeter!) > (AppConfig.distanceMaxValue*1609) {
                
               
                dobj.distance = "+\(AppConfig.distanceMaxValue)"
                dobj.unit =  "\(type.localized)"
                
                return dobj
                
            }else{
                
                dobj.nearby = true
              
                dobj.distance = "\(Int(3.28084*distanceMeter!))"
                dobj.unit =  "\("feet".localized)"
                               
                return dobj
                
            }
            
            //return "\(distanceMILE) \(type.localized)"
            
        }
        
        

        dobj.distance = "\(String(describing: distanceMeter))"
        dobj.unit =  "\(Distance.Types.Meters)"
                                      
        return dobj
        
    }
    
}

struct DistanceObjetc {
    var distance:String=""
    var unit:String = ""
    var nearby:Bool = false
}


extension Double {
    
    func calculeDistance() -> Distance {
        
        return Distance(distance: self)
    }
    
}








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

class StoreParser: Parser {
    

    func parse() -> [Store] {
        
        var list = [Store]()
        
        if let myResult = self.result {
            
          
            if myResult.count > 0 {
               
                let size = myResult.count-1
            
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    let myObject = Store()
                    
                    myObject.id = object["id_store"].intValue
                    myObject.name = object["name"].stringValue
                    myObject.address = object["address"].stringValue
                    
                     myObject.category_id = object["category_id"].intValue
                    
                    myObject.latitude = object["latitude"].doubleValue
                    myObject.longitude = object["longitude"].doubleValue
                    myObject.distance = object["distance"].doubleValue
                   
                    myObject.status = object["status"].intValue
                    
                    myObject.phone = object["telephone"].stringValue
                    
                    myObject.link = object["link"].stringValue
                    
                
                    myObject.voted = object["voted"].boolValue
                    myObject.votes = object["votes"].doubleValue
                    myObject.nbr_votes = object["nbr_votes"].stringValue
                    
                    myObject.nbrOffers = object["nbrOffers"].intValue
                    myObject.gallery = object["gallery"].intValue
                    
                    myObject.canChat = object["canChat"].intValue
                    
                    if object["saved"].intValue == 1{
                        myObject.saved = true
                    }else{
                        myObject.saved = false
                    }
                    
                    
                    myObject.lastOffer = object["lastOffer"].stringValue
                    
                    myObject.user_id = object["user_id"].intValue
                    myObject.featured = object["featured"].intValue
                    myObject.desc = object["description"].stringValue
                    myObject.detail = object["detail"].stringValue
                    
                    myObject.category_name = object["category_name"].stringValue
                    myObject.category_color = object["category_color"].stringValue
                    
                    myObject.opening = object["opening"].intValue

                    let ucontent = object["user"]
                    let userParser = UserParser(json: ucontent)
                    let users = userParser.parse()
                    if users.count > 0 {
                         myObject.user = users[0]
                    }
                   
                    
                   
                    /*
                    * Parse images
                    */

                    let icontent = object["images"]
                    let imageParser = ImagesParser(json: icontent)
                    let images = imageParser.parse()
                    
                    let listImages: List<Images> = List<Images>()
                    
                    for el in images {
                        listImages.append(el)
                    }
                    
                    myObject.listImages = listImages
                  

                    /*
                    * END parse images
                    */


                    /*
                     * Parse opening time
                     */

                    let optcontent = object["opening_time_table"]


                    let optParser = OpeningTimeParser(json: optcontent)
                    let optList = optParser.parse()

                    let optMyList: List<OpeningTime> = List<OpeningTime>()

                    for opt in optList {
                        optMyList.append(opt)
                    }

                    myObject.opening_time_table_list = optMyList

                    /*
                     * END opening time
                     */
                   
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
    
}

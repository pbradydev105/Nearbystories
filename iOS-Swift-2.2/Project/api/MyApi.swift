//
//  MyApi.swift
//  NearbyStores
//
//  Created by Amine on 7/25/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire

class MyApi {
    
    var headers = [
        "Api-key-ios": AppConfig.Api.ios_api,
        "Debug": "\(AppConfig.DEBUG)",
        "Token": LocalData.getValue(key: "token", defaultValue: ""),
        "Language": LocalData.getValue(key: "language", defaultValue: ""),
        "Current-date": DateUtils.getCurrent(format: DateFomats.defaultFormatUTC),
        "Timezone":TimeZone.current.abbreviation()!
    ]
    
 
    func prepareRequest (url: String, parameters: Parameters) {
        
        if let sess = Session.getInstance(), let user = sess.user{
            self.headers["Session-user-id"] = String(user.id)
        }
       
        if let guest = Guest.getInstance(){
            self.headers["Session-guest-id"] = String(guest.id)
        }
        
       
        Utils.printDebug("header \(self.headers)")
    }

}

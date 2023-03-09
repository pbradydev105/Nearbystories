//
//  CampaignApiCall.swift
//  NSApplication1.8
//
//  Created by Amine  on 2/24/20.
//  Copyright © 2020 Amine. All rights reserved.
//

import UIKit
import Alamofire

class CampaignApiCall {
    
    static func markReceive(cid: Int){
           
           var parameters = [
               "cid":  ""
           ]
           
            parameters["cid"] = "\(cid)"
           
           if(Session.isLogged()){
               if let user = Session.getInstance()?.user {
                   parameters["user_id"] = "\(user.id)"
               }
           }
                      
           if let guest = Guest.getInstance(){
               parameters["guest_id"] = "\(guest.id)"
           }
        
        Utils.printDebug("markReceive: \(parameters)")
           
           let api = SimpleLoader()
           api.run(url: Constances.Api.API_MARK_RECEIVE, parameters: parameters, compilation: { (parser) in
               if parser?.success == 1 {
                   
               }
           })
       }
       
       static func markView(cid: Int){
           
           var parameters = [
               "cid":  ""
           ]
           
           parameters["cid"] = "\(cid)"
           
           if(Session.isLogged()){
               if let user = Session.getInstance()?.user {
                   parameters["user_id"] = "\(user.id)"
               }
           }
                      
           if let guest = Guest.getInstance(){
               parameters["guest_id"] = "\(guest.id)"
           }
        
        Utils.printDebug("markView: \(parameters)")
           
           let api = SimpleLoader()
           api.run(url: Constances.Api.API_MARK_VIEW, parameters: parameters, compilation: { (parser) in
               if parser?.success == 1 {
                   
               }
           })
       }
    
    
    static func guest_api_refresh(token: String){
       
       let api = MyApi()
       let headers = api.headers
       
       
       let parameters = [
           "fcm_id": token,
           "sender_id": Token.getDeviceId(),
           "mac_adr": Token.getDeviceId(),
           "platform": "ios",
       ]
       
       
       Utils.printDebug("headers: \(headers)")
       Utils.printDebug("parameters: \(parameters)")
       
       
       Alamofire.request(Constances.Api.API_USER_REGISTER_TOKEN,method: .post,parameters: parameters, headers: headers).responseJSON { response in
           
           
           if let error = response.error{
               Utils.printDebug("\(error)")
           }
          
           
           
           if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
               
               Utils.printDebug("\(utf8Text)")
               
               let parser = GuestParser(content: utf8Text)
               
               if parser.success == 1 {
                   
                   let guests = parser.parse()
                   
                   if guests.count > 0 {
                       
                       Guest.saveGuest(guest: guests[0])
                       
                       if let g = Guest.getInstance() {
                           Utils.printDebug("Guest Instance ==> \(g)")
                       }
                       
                   }
                   
                   
               }else if parser.success == -1{
                   
                   if let errors = parser.errors{
                       Utils.printDebug("Error ==> \(errors)")
                   }
                   
               }
               
           }else {
               
              
           }
           
           
           
       }
       
   }

}









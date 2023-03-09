//
//  UserApi.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire

protocol BookmarksApiDelegate:class  {
    //func successUtf8(data: String)
    func success(parser: BookmarksParser,response: String)
    func error(error: Error?,response: String)
}

class BookmarksApi: MyApi  {
    
    
    var TAG: String = "Api.swift"
   
    var delegate: BookmarksApiDelegate? = nil
    
    func setDelegate(context: BookmarksApiDelegate) {
        delegate = context
    }
    
    func load (url: String, parameters: Parameters) {
        
        self.prepareRequest(url: url, parameters: parameters)
       
        Alamofire.request(url,method: HTTPMethod.post,parameters: parameters, headers: self.headers).responseJSON { response in
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    if AppConfig.DEBUG {
                        print("Load success")
                    }
                default:
                    if AppConfig.DEBUG {
                        print("error with response status: \(status)")
                    }
                    
                }
            }
            
            
            if self.delegate != nil {
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    
                    if let jsonDataToVerify = utf8Text.data(using: String.Encoding.utf8)
                    {
                        do {
                            _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                            
                            
                            let  parser = self.parser(json: utf8Text)
                            
                            if self.delegate != nil {
                                self.delegate?.success(parser: parser,response: utf8Text)
                            }
                            
                        } catch {
                            
                            Utils.printDebug("Error deserializing JSON: \(error.localizedDescription)")
                            
                            if self.delegate != nil {
                                self.delegate?.error(error: nil,response: utf8Text)
                            }
                        }
                    }
                    
                    
                }
                
            }
            
            
            if let error = response.error {
                
                var resp = ""
                
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    resp = utf8Text
                }
                
                if self.delegate != nil {
                    self.delegate?.error(error: error,response: resp)
                }
                
            }
            
            
        }
        
        
        
    }
    
    
    func markMessagesAsLoaded(url: String, parameters: Parameters,compilation: @escaping (Parser?) -> () ) {
        
         compilation(nil)
        
        Alamofire.request(url,method: HTTPMethod.post,parameters: parameters, headers: self.headers).responseJSON { response in
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    if AppConfig.DEBUG {
                        print("Load success")
                    }
                default:
                    if AppConfig.DEBUG {
                        print("error with response status: \(status)")
                    }
                }
            }
            
            
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                if let jsonDataToVerify = utf8Text.data(using: String.Encoding.utf8)
                {
                    do {
                        _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                        
                        let  parser = Parser(content: utf8Text)
                        compilation(parser)
                        //compilation(parser)
                        
                    } catch {
                        Utils.printDebug("Error deserializing JSON: \(error.localizedDescription)")
                    }
                }
                
                
            }
            
            
            
        }
        
    }
    
    
    
    var result: BookmarksParser? = nil
    
    func parser(json: String) ->  BookmarksParser {
        
        let mParser = BookmarksParser(content: json)
        
        result = mParser
        
        return mParser
    }
    
    
    
    
}





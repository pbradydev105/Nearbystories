//
//  DateUtils.swift
//  NearbyStores
//
//  Created by Amine on 6/13/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Foundation

class DateFomats {
    static let simpleDateFormat = "dd-MM-yyyy HH:mm:ss"
    static let defaultFormatTimeUTC = "yyyy-MM-dd HH:mm:ss"
    static let defaultFormatUTC = "yyyy-MM-dd HH:mm"
    static let defaultFormatDate = "dd MMM yyyy"
    static let defaultFormatDateTime = "dd EE yyyy HH:mm"
    static let defaultFormatTime = "HH:mm"
    
}

class DateUtils: NSObject {
    
    static let defaultFormatUTC = "yyyy-MM-dd HH:mm:ss"
    static let defaultFormatDate = "dd MMM yyyy"
    static let defaultFormatDateTime = "dd MMM yyyy HH:mm"
    static let defaultFormatTime = "HH:mm"
    
    static func isLessThan24(components: DateComponents) -> Bool {
        
        guard components.year! == 0 else { return false }
        guard components.month! == 0 else { return false }
        guard components.day! == 0 else { return false }
        guard components.hour! <= 24  else { return false }
        
        return true
    }
    
    static func isLessThan60seconds(components: DateComponents) -> Bool {

        guard components.year! >= 0 else { return false }
        guard components.month! >= 0 else { return false }
        guard components.day! >= 0 else { return false }
        guard components.hour! >= 0  else { return false }
        guard components.minute! >= 0  else { return false }
        
        return true
    }
    
    

    
    
    static func isLessThan24(dateUTC: String) -> Bool{
        
        let dateRangeStart = Date()
        
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateRangeStart, to: dateEnd)
            
            
            if isLessThan24(components: components) {
                return true
            }
            
        }
        
        return false
    }
    
    static func getPreparedDateDT(dateUTC: String) -> String{
        
        let dateRangeStart = Date()
        
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateRangeStart, to: dateEnd)
            

            if isLessThan60seconds(components: components){
                return "Just Now".localized
            }else if isLessThan24(components: components) {
                return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatTime)
            }
            
            
        }
        
        
        return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatDate)
        
    }
    
    
    static func getPreparedDateDT(dateUTC: String, dateFormat: String) -> String{
        
        let dateRangeStart = Date()
        
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateRangeStart, to: dateEnd)
            
            
            if isLessThan60seconds(components: components){
                return "Just Now".localized
            }else if isLessThan24(components: components) {
                return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: dateFormat)
            }
            
            
        }
        
        
        return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatDate)
        
    }
    
    
    static func getPreparedDateSimple(dateUTC: String) -> String{

        
        return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatDateTime)
        
    }

    static func getPreparedDateSimple(dateUTC: String, dateFormat: String) -> String{

        return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: dateFormat)
    }
    
    
    static func getPreparedDateSimple2(dateUTC: String, dateFormat: String) -> String{
        
        return self._UTC(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: dateFormat)
    }

    static func getCurrentDay() -> String{

        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.locale =  Locale(identifier: "en_US")
        dateFormatter.dateFormat  = "EEEE" // "EE" to get short style
        return dateFormatter.string(from: date as Date) // "Sunday"

    }




    static func convertToDate(dateUTC: String) -> Date?{
        
        //convert date to current timezone
        
        let dateByCTZ = self.UTCToLocal(date: dateUTC,
                                        fromFormat: self.defaultFormatUTC,
                                        toFormat: self.defaultFormatUTC)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.defaultFormatUTC
        dateFormatter.calendar = NSCalendar.current
        
        return dateFormatter.date(from: dateUTC)
    }
    
    static func getCurrent(format: String) -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    static func getCurrentUTC(format: String) -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format
        
        if(Utils.isRTL()){
            formatter.locale = Locale(identifier: "ar_MA")
        }
        
        return formatter.string(from: date)
    }
    
    static func localToUTC(date:String, fromFormat: String, toFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = toFormat

        if let _dt = dt{
            
            if(Utils.isRTL()){
                dateFormatter.locale = Locale(identifier: "ar_MA")
            }
            
            return dateFormatter.string(from: _dt)
        }else{
            return date
        }
    }
    
    static func UTCToLocal(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let dt = dateFormatter.date(from: date){
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = toFormat
            
            if(Utils.isRTL()){
                dateFormatter.locale = Locale(identifier: "ar_MA")
            }
            
            return dateFormatter.string(from: dt)
        }else{
            return date
        }
    
    }


    static func _UTC(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let dt = dateFormatter.date(from: date){
            //dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = toFormat
            
            if(Utils.isRTL()){
                dateFormatter.locale = Locale(identifier: "ar_MA")
            }
            
            return dateFormatter.string(from: dt)
        }else{
            return date
        }

    }
    
    
}

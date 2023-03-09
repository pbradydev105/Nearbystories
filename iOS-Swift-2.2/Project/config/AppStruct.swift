//
//  AppDesign.swift
//  NearbyStores
//
//  Created by Amine  on 7/26/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit

class AppStyle {

    static var isDarkModeEnabled = false
    static var radius_size = 25
    static var padding_size_item = 10

    struct Listing {

        enum itemStore {
            static let V1 = 1
            static let V2 = 2
            static let V2_2 = 3
        }

        enum itemOffer {

            static let V2 = 2
            //static let V2_2 = 3
        }

        enum itemEvent {
            static let V2 = 2
            static let V2_2 = 3
        }

        enum itemUser {
            static let V2 = 2
            static let V2_2 = 3
        }

    }


    struct Content {

        enum contentStore {
            static let V2 = 2
        }

        enum contentOffer {
            static let V1 = 1
            static let V2 = 2
        }

        enum contentEvent {
            static let V2 = 2
        }

        enum contentUser {
            static let V2 = 2
        }
    }

    enum HomeUI {
        static let V2 = 2
    }


    enum uiColor {
        static let light = 1
        static let dark = 2
    }

    
    struct TabsV2 {
        
        enum Tags {
            static let TAG_HOME = "home"
            static let TAG_CATEGORIES = "categories"
            static let TAG_NOTIFICATION = "notification"
            static let TAG_SETTING = "setting"
            static let TAG_ACCOUNT = "account"
            static let TAG_FAVORITES = "favorites"
            static let TAG_MORE = "more"
        }
        
     
        static let Pages: [NSv2Page] = [
            NSv2Page(name: Tags.TAG_HOME, icon:  .linearIcons(.home)),
            NSv2Page(name: Tags.TAG_CATEGORIES, icon: .linearIcons(.list)),
            NSv2Page(name: Tags.TAG_FAVORITES, icon: .ionicons(.iosBookOutline)),
            NSv2Page(name: Tags.TAG_ACCOUNT, icon: .linearIcons(.user)),
            //NSv2Page(name: Tags.TAG_NOTIFICATION, icon: .linearIcons(.alarm)),
            //NSv2Page(name: Tags.TAG_SETTING, icon: .ionicons(.iosSettingsStrong)),
            NSv2Page(name: Tags.TAG_MORE, icon: .googleMaterialDesign(.moreHoriz)),
        ]
        
        
        static let MenuV2 = [
            MenuIDList.CATEGORIES : true,
            MenuIDList.GEO_STORES : true,
            MenuIDList.CHAT_LOGIN : true,
            MenuIDList.PEOPLE_AROUND_ME : true,
            MenuIDList.FAVOURITES : true,
            MenuIDList.MY_EVENTS : true,
            MenuIDList.EDIT_PROFILE : true,
            MenuIDList.LOGOUT : true,
            MenuIDList.MANAGE_STORES : false,
            MenuIDList.SETTING : true,
            MenuIDList.ABOUT : true,
            MenuIDList.CLOSE : true,
        ]
        

    }


}



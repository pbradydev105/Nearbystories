//
//  AppConfig.swift
//  AppTest
//
//  Created by Amine on 5/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class AppConfig: NSObject {
    
    //AppConfiguration
    static let DEBUG: Bool = false
    
    //Maps Config
    static let GOOGLE_MAPS_KEY = "**** GOOGLE MAPS HERE ****"
    static let GOOGLE_PLACES_KEY = "**** GOOGLE PLACES HERE ****"
       
    
    
    //API SERVER CONFIG
    struct Api {
        static let ios_api              = "4bd46da9c50e16d0cbde203088b62f5d"    // get it from dashboard
        static let base_url             = "http://mymdcannabis.com/johnk/index.php"
        static let base_url_api         = "http://mymdcannabis.com/johnk/index.php/api"
        static let terms_of_use_url     = "http://mymdcannabis.com/johnk/term_of_uses.html"
        static let privacy_policy_url   = "http://mymdcannabis.com/johnk/privacy_policy.html"
    }
    
    struct DeepLinking {
        
        static let host                   = "mymdcannabis.com"
        
    }
    
    //ADMOB CONFIG
    struct Ads {
        
        static let AD_APP_ID            = "ca-app-pub-3182239915045123~xxxxx"
        static let AD_BANNER_ID         = "ca-app-pub-3182239915045123/xxxxx"
        static let AD_INTERSTITIEL_ID   = "ca-app-pub-3182239915045123/xxxxx"
        
        
        //Enable/Disable
        static let ADS_ENABLED                  = false //enable/disable all ads
        static let ADS_BANNER_ENABLED           = false
        static let ADS_INTERSTITIEL_ENABLED     = false
        
        static let BANNER_IN_STORE_DETAIL_ENABLED   = true
        static let BANNER_IN_OFFER_DETAIL_ENABLED   = true
        static let BANNER_IN_EVENT_DETAIL_ENABLED   = true
        
    }
    
    //App Name
    static let APP_NAME = Bundle.main.infoDictionary?["CFBundleName"] as! String
    
    
    //Enable/Disable Chat in your App
    static let CHAT_ENABLED = true
    
  
    //Config Colors & Fonts
    struct Design {
        
        //Some proposed colors from google
        //https://material.io/design/color/the-color-system.html
        enum Colors {
            static let primaryColor = "#E53935"
            static let accentColor = "#F44336"
            static let darkColor = "#C62828"
            static let darkIconColor = "#B71C1C"
            static let featuredTagColor = "#1565C0"
            static let promoTagColor = "#E53935"
            static let upComingColor = "#E65100"
        }
        
        //See how to set custom font
        //https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app
        enum Fonts {
            static let regular = Constances.FontsList.Montserrat.regular
            static let italic = Constances.FontsList.Montserrat.italic
            static let bold = Constances.FontsList.Montserrat.bold
        }
    
        
        /*
        * UI configuration
        */


        //UI configuration mode light/dark
        static var uiColor = AppStyle.uiColor.dark

        //UI home page V1/V2
        static let homeStyle = AppStyle.HomeUI.V2
        static let homeHeaderBackgounds = ["header_bg_1","header_bg_2","header_bg_3"]
        static let loginBackgounds = ["login_bg_1","login_bg_2","login_bg_3","login_bg_4","login_bg_5","login_bg_6"]

        //UI listing cards V1/V2
        static let listingStyle: [String:Int] = [
            Tabs.Tags.TAG_STORES: AppStyle.Listing.itemStore.V1,
            Tabs.Tags.TAG_OFFERS: AppStyle.Listing.itemOffer.V2,
            Tabs.Tags.TAG_EVENTS: AppStyle.Listing.itemEvent.V2,
            Tabs.Tags.TAG_USER: AppStyle.Listing.itemUser.V2
        ]

        //UI content V1/V2
        static let contentStyle: [String:Int] = [
            Tabs.Tags.TAG_STORES: AppStyle.Content.contentStore.V2,
            Tabs.Tags.TAG_OFFERS: AppStyle.Content.contentOffer.V2,
            Tabs.Tags.TAG_EVENTS: AppStyle.Content.contentEvent.V2,
            Tabs.Tags.TAG_USER: AppStyle.Content.contentUser.V2
        ]

        
        //HOME page V2
        static let homeList: [CardStyle] = [
            CardHorizontalStyle(width: 320, height: 200, type: .SponsoredBanners),
            //CardHorizontalStyle(width: 290, height: 280, type: .FeaturedStores,title: CardTags.TAG_FEATURED_STORES),
            //CardHorizontalStyle(width: 300, height: 320, type: .Top_Nearby_Stores,title: CardTags.TAG_TOP_RATED),
            CardHorizontalStyle(width: 180, height: 180, type: .TopCategories,title: CardTags.TAG_TOP_CATEGORIES),
            CardHorizontalStyle(width: 300, height: 320, type: .Nearby_Stores,title: CardTags.TAG_NEARBY_STORES),
            CardHorizontalStyle(width: 280, height: 240, type: .Recent_Offers,title: CardTags.TAG_RECENT_OFFERS),
            CardHorizontalStyle(width: 290, height: 280, type: .Nearby_Events,title: CardTags.TAG_NEARBY_EVENTS),
            CardHorizontalStyle(width: 210, height: 190, type: .Nearby_Users,title: CardTags.TAG_NEARBY_USERS),
        ]
        

    }
    
    
    //Main Config V1
    struct Tabs {
        
        enum Tags {
            static let TAG_STORES = "stores"
            static let TAG_OFFERS = "offers"
            static let TAG_EVENTS = "events"
            static let TAG_INBOX = "inbox"
            static let TAG_USER = "user"
        }
        
        static let Pages: [String] = [
            Tags.TAG_STORES, // stores
            Tags.TAG_EVENTS, // Events
            Tags.TAG_OFFERS, // offers
            Tags.TAG_INBOX,  // Inbox
        ]
        
        static let TabIcons: [String: FontType] = [
            Tags.TAG_STORES: .linearIcons(.store),
            Tags.TAG_OFFERS: .linearIcons(.tag),
            Tags.TAG_EVENTS: .linearIcons(.calendarFull),
            Tags.TAG_INBOX:  .linearIcons(.inbox),
        ]
        
    }
    
    struct CardTags {
        
        static let TAG_RECENT_STORES = "recent_stores"
        static let TAG_RECENT_OFFERS = "recent_offers"
        static let TAG_RECENT_EVENTS = "recent_events"
        
        static let TAG_TOP_CATEGORIES = "top_categories"
        static let TAG_TOP_RATED = "top_rated"
        static let TAG_NEARBY_STORES = "nearby_stores"
        static let TAG_NEARBY_OFFERS = "nearby_offers"
        static let TAG_NEARBY_EVENTS = "nearby_events"
        static let TAG_NEARBY_USERS = "nearby_users"
        
        static let TAG_FEATURED_OFFERS = "featured_offers"
        static let TAG_FEATURED_EVENTS = "featured_events"
        static let TAG_FEATURED_STORES = "featured_stores"
        
        static let TAG_PHOTOS = "photos"
       
        static let TAG_SPONSORED_BANNERS = "sponsored_banners"
    }
    
    static let distanceMaxValue = 100 //By distanceUnit
    static let distanceUnit = Distance.Types.Miles
    
    
    
    
    //About Company Or Project
    struct About {
        
        static let ABOUT_US = "NEARBYSTORES is an innovative local business search app with an intelligent search functionality that can help you find different businesses in an area easily. It has a powerful store locator admin that allows you to manage stores, categories, notification, business owner, events and offers"
        
        static let EMAIL = "contact@droidev-tech.com"
        static let TEL = "+1 000 000 00"
    }
    
    //Enable/Disable Menu Items
    struct Menu {
        /*
         to manage menu list, should remove each id from the list
         */
        static let list = [
            MenuIDList.CATEGORIES : true,
            MenuIDList.CHAT_LOGIN : true,
            MenuIDList.GEO_STORES : true,
            MenuIDList.PEOPLE_AROUND_ME : true,
            MenuIDList.FAVOURITES : true,
            MenuIDList.MY_EVENTS : true,
            MenuIDList.EDIT_PROFILE : true,
            MenuIDList.LOGOUT : true,
            MenuIDList.MANAGE_STORES : true,
            MenuIDList.SETTING : true,
            MenuIDList.ABOUT : true,
            MenuIDList.CLOSE : true,
        ]
    }
    
    let app_version = "2.0" // please don't touch this
    
    
    
    
}

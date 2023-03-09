//
//  Constances.swift
//  NearbyStores
//
//  Created by Amine on 5/21/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit


class Constances {
    


    enum  Global{
        static let GPS_REQUIRE_ENABLE = false
    }

   
    
    enum Api{
        
    
        static let API_VERSION: String = "1.0";
        static let BASE_IMAGES_URL: String = AppConfig.Api.base_url_api+"/uploads/images/";
        //store API's
        static let API_USER_GET_STORES: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/store/getStores";
        static let API_USER_GET_REVIEWS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/store/getComments";
        static let API_USER_CREATE_STORE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/store/createStore";
        static let API_USER_UPDATE_STORE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/webservice/updateStore";
        static let API_RATING_STORE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/store/rate";
        static let API_SAVE_STORE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/store/saveStore";
        static let API_REMOVE_STORE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/store/removeStore";
        //event API's
        static let API_USER_GET_EVENTS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/event/getEvents";
        static let API_SAVE_EVENT: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/event/saveEventBK";
        static let API_REMOVE_EVENT: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/event/removeEventBK";
        
        //category API's
        static let API_USER_GET_CATEGORY: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/category/getCategories";
        //uploader API's
        static let API_USER_UPLOAD64: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/uploader/uploadImage64";
        //user API's
        static let API_USER_LOGIN: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/signIn";
        static let API_USER_SIGNUP: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/signUp";
        static let API_USER_CHECK_CONNECTION: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/checkUserConnection";
        static let API_BLOCK_USER: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/blockUser";
        static let API_GET_USERS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/getUsers";
        static let API_UPDATE_ACCOUNT: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/updateAccount";
        static let API_UPDATE_ACCOUNT_PASSWORD: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/updateAccountPassword";
        static let API_USER_REGISTER_TOKEN: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/registerToken";
        static let API_REFRESH_POSITION: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/user/refreshPosition";
        //setting API's
        static let API_APP_INIT: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/setting/app_initialization";
        //messenger API's
        static let API_LOAD_MESSAGES: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/messenger/loadMessages";
        static let API_LOAD_DISCUSSION: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/messenger/loadDiscussion";
        static let API_INBOX_MARK_AS_SEEN: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/messenger/markMessagesAsSeen";
        static let API_INBOX_MARK_AS_LOADED: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/messenger/markMessagesAsLoaded";
        static let API_SEND_MESSAGE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/messenger/sendMessage";
        static let API_COUNT_UNREAD_MESSAGES: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/messenger/countMessages";
        //offer API's
        static let API_GET_OFFERS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/offer/getOffers";
        //campaign API's
        static let API_MARK_VIEW: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/campaign/markView";
        static let API_MARK_RECEIVE: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/campaign/markReceive";
        static let API_NOTIFICATION_AGGREMENT: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/campaign/notification_agreement";
        
        
        //historic
        static let API_GET_NOTIF_HISTORIC: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/nshistoric/getNotifications";
        static let API_CHANGE_NOTIF_STATUS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/nshistoric/changeStatus";
        static let API_REMOVE_NOTIF: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/nshistoric/remove";
        static let API_TURNOFF_NOTIF: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/nshistoric/turnOff";
        static let API_GET_NOTIFICATIONS_COUNT: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/nshistoric/getCount";
        
        //bookmarks
        static let API_GET_BOOKMARKS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/bookmark/getBookmarks";
        static let API_EMOVE_FROM_BOOKMARKS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/bookmark/remove";
        
        //Gallery API's
        static let API_LOAD_GALLERY: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/gallery/getGallery";

        //Banners API's
        static let API_GET_BANNERS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/nsbanner/getBanners";
        static let API_GET_MODULES: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/modules_manager/availableModules";
        
        //Location Picker API's
        static let API_LPICKER_GET_LOCATIONS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/location_picker/getLocations";
        
        
        //Logs Server
        static let API_SAVE_LOGS: String = AppConfig.Api.base_url_api+"/"+API_VERSION+"/setting/saveLogs";
        
        
    }
    
    
    enum CustomSize {
        static let CUSTOM_HEIGHT_TEXTFIELDS = 40
        static let CUSTOM_HEIGHT_BUTTON = 35
    }
    
    struct FontsList {
        
        struct OpenSans {
            static let regular = "OpenSans"
            static let italic = "OpenSans-Italic"
            static let bold = "OpenSans-Bold"
        }
        
        struct SF_Pro_Display {
            static let regular = "SF-Pro-Display-Regular"
            static let italic = "SF-Pro-Display-Italic"
            static let bold = "SF-Pro-Display-Bold"
        }
        
        struct ProductSans{
            static let regular = "ProductSans-Regular"
            static let italic = "ProductSans-Italic"
            static let bold = "ProductSans-Bold"
        }
        
        struct Montserrat{
            static let regular = "Montserrat-Regular"
            static let italic = "Montserrat-Italic"
            static let bold = "Montserrat-Medium"
        }
        
    }
    
}

class ExtendedConfig{
    
    static let notify_me_ask = true
    
}

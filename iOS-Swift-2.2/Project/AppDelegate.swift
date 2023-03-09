//
//  AppDelegate.swift
//  NearbyStores
//
//  Created by Amine on 5/19/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import SwiftEventBus
import GoogleMaps
import GoogleMobileAds
import RealmSwift
import GooglePlaces
import AssistantKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

   
    func setupAppearenceColors() {
        
        
        //setup tabBar appearance
        UITabBar.appearance().tintColor = Colors.Appearance.primaryColor
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.Appearance.primaryColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
               
        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 10){
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
        }
               
               
        //setup searchbar appearance
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: Colors.white, NSAttributedString.Key.font: UIFont(name: AppConfig.Design.Fonts.regular, size: 15)]
               // Color of the default search text.
        let attributedPlaceholder = NSAttributedString(string: "Search".localized, attributes: placeholderAttributes as [NSAttributedString.Key : Any])
               UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
               

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = convertToNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
               
        
        if(AppConfig.Design.uiColor == AppStyle.uiColor.dark){
            UINavigationBar.appearance().barTintColor = Colors.Appearance.primaryColor
        }else{
            UINavigationBar.appearance().barTintColor = Colors.Appearance.white
        }
        
    
        
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        } else {
            // Fallback on earlier versions
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]

        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
             
        setupAppearenceColors()
        
        GMSPlacesClient.provideAPIKey(AppConfig.GOOGLE_PLACES_KEY)
        GMSServices.provideAPIKey(AppConfig.GOOGLE_PLACES_KEY)
       
        
        //init app settings
        let first_time = LocalData.getValue(key: "first_time", defaultValue: 1)
        if first_time == 0{
            LocalData.setValue(key: Settings.Keys.OFFERS_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.STORES_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.EVENTS_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.CEVENTS_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.MESSENGER_NOTIFICATION, value: true)
            LocalData.setValue(key: "first_time", value: 1)
        }
        
       
        //UIApplication.shared.statusBarStyle = .lightContent
        
        GMSServices.provideAPIKey(AppConfig.GOOGLE_MAPS_KEY)
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
    
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })

        } else {

            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)

        }
        
       application.registerForRemoteNotifications()
        
        self.setup(application: application)

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 44,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        
        
        if AppConfig.DEBUG{
            switch Device.screen {
            case .inches_3_5:  print("Device.screen => 3.5 inches")
            case .inches_4_0:  print("Device.screen => 4.0 inches")
            case .inches_4_7:  print("Device.screen => 4.7 inches")
            case .inches_5_5:  print("Device.screen => 5.5 inches")
            case .inches_7_9:  print("Device.screen => 7.9 inches")
            case .inches_9_7:  print("Device.screen => 9.7 inches")
            case .inches_12_9: print("Device.screen => 12.9 inches")
            default:           print("Device.screen => Other display")
            }
            
            print("Device.screen UIScreen.main.nativeScale => \(UIScreen.main.nativeScale)")
            
        }
        

        
        return true
    }
    
    //deep linking
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        Utils.printDebug("Deep Linking \(url.absoluteURL)")
        Utils.printDebug("Deep Linking \(url.path)")
        
        if let hurl = url.host{
             Utils.printDebug("Deep Linking \(url.path)")
            if hurl == AppConfig.DeepLinking.host{
                //check paths
                    //check dtore
                if let id = Utils.getIdFromPath(path: url.path, prefix: "store"){
                    //open store activity
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        SwiftEventBus.post("open_view_store", sender:["oid":id] )
                    }
                    
                }else if let id = Utils.getIdFromPath(path: url.path, prefix: "offer"){
                    //open offer activity
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        SwiftEventBus.post("open_view_offer", sender:["oid":id] )
                    }
                    
                }else if let id = Utils.getIdFromPath(path: url.path, prefix: "event"){
                    //open event activity
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        SwiftEventBus.post("open_view_event", sender:["oid":id] )
                    }
                    
                }else if let method = Utils.getMethod(nspath: url.path, nsmodule: "user"){
                    
                    if method == "login"{
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            SwiftEventBus.post("open_view_login", sender: true )
                        }
                    }else if method == "signup"{
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            SwiftEventBus.post("open_view_signup", sender: true )
                        }
                    }
                    
                }
                
                
                
            }
        }
        
        return true
    }
    
   
    

    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
         Messaging.messaging().apnsToken = deviceToken
    }

    
    func setup(application: UIApplication)  {
        

        let statusBarBackgroundView = UIView()
        statusBarBackgroundView.backgroundColor = Colors.Appearance.darkColor
        
        
        if(AppConfig.Design.uiColor == AppStyle.uiColor.dark){
            window?.backgroundColor = Colors.Appearance.primaryColor
        }else{
             window?.backgroundColor = Colors.Appearance.white
        }
        
        
        
        window?.addSubview(statusBarBackgroundView)
        window?.addConstraintsWithFormat(format: "H:|[v0]|", views: statusBarBackgroundView)
        window?.addConstraintsWithFormat(format: "V:|[v0(20)]", views: statusBarBackgroundView)
        
    }
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    

    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        //save token in the local database
        LocalData.setValue(key: "firebase_fcm", value: fcmToken)
        
        //refresh token in the server
        CampaignApiCall.guest_api_refresh(token: fcmToken)
        
        
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage)")
        
    }
    
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
     
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let text = userInfo["text"] {
            
            let icdParser = InComingDataParser(content: text as? String)
            icdParser.proccess()
            
        }
        
        // Print full message.
        print(userInfo)
        
    }
    

    /*
    * RECEIVE NOTIFICATION WHEN THE APP RUNNING IN THE BACKGROUND
    */
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        
        if let messageID = userInfo[gcmMessageIDKey] {
            Utils.printDebug("Message ID: \(messageID)")
        }
        
        if let text = userInfo["text"] {
            let icdParser = InComingDataParser(content: text as? String)
            icdParser.proccess(pushNotification: true)
            completionHandler(UIBackgroundFetchResult.newData)
            return
           
        }
        
        Utils.printDebug("\(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
   
    /*
     * RECEIVE NOTIFICATION WHEN THE APP RUNNING IN THE FOREGROUND
     */
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        

        // With swizzling disabled you must let Messaging know about the message, for Analytics

        Messaging.messaging().appDidReceiveMessage(userInfo)
     
        if let text = userInfo["text"] {
            Utils.printDebug("__userNotificationCenter: \(text)")
            let icdParser = InComingDataParser(content: text as? String)
            icdParser.proccess()
            return
        }
        completionHandler([.alert,.sound])
    }
    
    
    /*
     * CLICK EVENT ON NOTIFICATION
     */
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        
        if let text = userInfo["text"] {
            Utils.printDebug("_RePush DATA: \(text)")
            let icdParser = InComingDataParser(content: text as? String)
            icdParser.proccess(pushNotification: true)
            return
        }
        
        
        let notification_identifier:String = response.notification.request.identifier
        
        let status: UIApplication.State = UIApplication.shared.applicationState // or use  let state =  UIApplication.sharedApplication().applicationState
    
        if notification_identifier == InComingDataParser.tag_new_message {
            
            //update badge
            SwiftEventBus.post("on_badge_refresh", sender: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                for index in 0...AppConfig.Tabs.Pages.count{
                    if AppConfig.Tabs.Pages[index] == AppConfig.Tabs.Tags.TAG_INBOX{
                        SwiftEventBus.post("on_main_redirect", sender: index)
                        break
                    }
                }
            }
  
            
        }else if notification_identifier ==  CampaignParser.OFFER {
            
            if let cid = NotificationManager.last_received_cid{
                CampaignApiCall.markView(cid: cid)
            }
            
            
            if status == .active{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftEventBus.post("open_view_"+CampaignParser.OFFER, sender:["oid":oid,"cid":cid])
                }

            }else if status == .background{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    SwiftEventBus.post("open_view_"+CampaignParser.OFFER, sender:["oid":oid,"cid":cid])
                }
                
            }else{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    SwiftEventBus.post("open_view_"+CampaignParser.OFFER, sender:["oid":oid,"cid":cid])
                }
                
            }
            
            
        }else if notification_identifier == CampaignParser.STORE {
            
            if let cid = NotificationManager.last_received_cid{
                CampaignApiCall.markView(cid: cid)
            }
            
            if status == .active{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftEventBus.post("open_view_"+CampaignParser.STORE, sender:["oid":oid,"cid":cid])
                }
                
            }else{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    SwiftEventBus.post("open_view_"+CampaignParser.STORE, sender:["oid":oid,"cid":cid])
                }
                
            }
            
        }else if notification_identifier ==  CampaignParser.EVENT {
            
        
            if let cid = NotificationManager.last_received_cid{
               CampaignApiCall.markView(cid: cid)
            }
            
            if status == .active{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftEventBus.post("open_view_"+CampaignParser.EVENT, sender:["oid":oid,"cid":cid])
                }
                
            }else if status == .background{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    SwiftEventBus.post("open_view_"+CampaignParser.EVENT, sender:["oid":oid,"cid":cid])
                }
            }else{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    SwiftEventBus.post("open_view_"+CampaignParser.EVENT, sender:["oid":oid,"cid":cid])
                }
            }
            
            
            
        }else if notification_identifier ==  "upcomingevents" {
         
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                SwiftEventBus.post("open_view_list_event", sender:ListEventCell.EventsListRequestOrder.upcoming)
            }
            
       }
        
        
        NotificationManager.last_received_cid = nil
        NotificationManager.last_received_oid = nil
        NotificationManager.last_received_type = nil
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }


}


extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let view = UIView(frame: UIApplication.shared.statusBarFrame)
            view.backgroundColor = Colors.Appearance.darkColor
            return view
        }else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
            return nil
        }
    }
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
